# Uruvia: Supabase plan

Status: 9 Oct 2026. Hosted Supabase project chosen (ref `mvisrdmdxbenuqezprdn`).
**On hold:** the payment partner and all wallet integration (section 4, and the wallet-linked parts of savings, invoices, subscriptions and loans).
The wallet screens are built as UI with dummy data only. No wallet tables, money functions or webhooks are written until the hold is lifted.
Migrations written and tested so far (7 files, 85 automated checks on a scratch Postgres, none yet run on the hosted project):
0001 helpers, 0002 identity and accounts, 0003 KYC config, 0004 budgets and expenses, 0005 inventory,
0006 customers, invoices and sales, 0007 notifications, support, plans and subscriptions, with scheduled stock and overdue jobs.
**Not written yet (touch the wallet, on hold):** wallet and ledger, savings pockets and group savings, loans, subscription charging.
**Not written yet (open board decisions):** Business Health scoring, report access, Hub listings.
Design note: an issued invoice with no payment is edited by `revert_invoice_to_draft()` (releases stock), then re-issued.
Source: the Uruvia Design Reference (58 screens). Items still waiting on the board are marked **[OPEN]** and are
handled with configuration tables, so a decision never needs a code change.

## 1. Principles

1. **Security lives in the database.** Row Level Security (RLS) is on for every table in `public`. The app only holds the publishable key.
2. **Money is `bigint` kobo.** No floats, no `numeric` for amounts. Matches `lib/core/utils/money.dart`.
3. **Money only moves through functions.** Clients can read their wallet and ledger but cannot insert or update them. Every movement is one database transaction.
4. **Ledger is append-only.** Balances are derived from, and always reconcile with, the ledger. Corrections are new entries, never edits.
5. **Business-only data is blocked by RLS**, not just hidden in the app (rule 5 in `ARCHITECTURE.md`).
6. **Rules that the board has not decided live in tables**, not in code: KYC limits, health bands, loan terms, free vs Pro report access, grace periods.
7. **Idempotency everywhere money or stock moves.** Each request carries a key; a retry never double-spends.
8. Snake_case, plural table names, `uuid` primary keys, `timestamptz` everywhere, index every foreign key.

## 2. Identity and accounts

One person, up to two accounts (Individual, Business), one wallet per account (accepted default).

| Table | Purpose |
|---|---|
| `profiles` | 1:1 with `auth.users`: full name, phone, avatar, language, kyc_tier, pro flags cache, `last_active_account_id` |
| `accounts` | `id, owner_id, type (individual\|business), name, status`. Unique `(owner_id, type)` |
| `account_members` | `account_id, user_id, role (owner\|staff)`. Owner row is created with the account. Staff is "later" but the table exists now so RLS never has to be rewritten |
| `business_profiles` | 1:1 with a business account: business name, category, address, logo path, invoice prefix, VAT rate, payment details shown on invoices, currency (₦ fixed) |
| `devices` | Trusted devices, push token, last seen. Supports remote sign-out (screen 10) |
| `user_security` | Transaction PIN hash, failed-attempt counter, locked-until, biometrics flag |

- Helper functions in a private schema: `private.is_account_member(account_id)`, `private.is_business_account(account_id)`. Policies call them as `(select private.is_account_member(account_id))` so Postgres caches the result per statement.
- Every domain table below carries `account_id`. Policies are always "member of this account", and Business-only tables add "and the account is a business".
- Account switching (screen 11) is a client concept plus `profiles.last_active_account_id`; the PIN or biometric check happens on the device.
- Never use `user_metadata` for any authorization. Account type and roles come from tables only.

### Auth settings
- Email plus phone OTP (SMS auto-fill per the sign-up design). No social sign-in at launch (accepted default).
- App lock PIN and the 3-minute idle lock are **device-side** (secure storage and biometrics). They are not stored on the server.
- **Transaction PIN** is server-side: bcrypt hash via `pgcrypto`, verified inside the money functions, 5 wrong tries locks for 15 minutes (`user_security`).
- Sign-in lockout (5 tries, 15 minutes) uses Supabase Auth rate limits first. If those do not give the "attempts left" message in the design, add a small `auth_attempts` table behind an Edge Function. Decide when we reach the auth module.

## 3. KYC

| Table | Purpose |
|---|---|
| `kyc_tiers` | Config: tier number, name, daily send limit, wallet balance cap, savings cap, allows_group_payout. **[OPEN]** limits come from the partner bank, so seed with placeholders marked `is_provisional` |
| `kyc_submissions` | `user_id, tier_target, status (pending\|approved\|action_needed\|rejected), reason, provider_ref` |
| `kyc_documents` | Storage paths for ID and selfie, BVN/NIN reference (stored by the provider reference only; never keep raw ID numbers if the provider can hold them) |

- Documents go in the private `kyc` bucket, path `{user_id}/...`, readable only by the owner and service role.
- Approval is written by a webhook Edge Function (service role), which updates `profiles.kyc_tier`. Users cannot set their own tier.
- Limit checks (send, fund, wallet cap) read `kyc_tiers` inside the money functions, so the "limit exceeded" screens always agree with the server.

## 4. Wallet and ledger (screens 15 to 18) **[ON HOLD: UI with dummy data only]**

| Table | Purpose |
|---|---|
| `wallets` | One per account: `balance_kobo`, `status (active\|restricted\|frozen)`, virtual account number and bank, `restricted_reason` |
| `wallet_transactions` | The ledger. `id, wallet_id, kind, direction (credit\|debit), amount_kobo, fee_kobo, status (initiated\|processing\|completed\|failed\|reversed), reference (unique), idempotency_key, counterparty (jsonb), narration, expense_category_id, budget_id, invoice_id, related_pocket_id, created_at, completed_at, balance_after_kobo` |
| `beneficiaries` | Saved bank accounts and own-account shortcuts |
| `banks` | Bank list for the picker (synced from the partner) |
| `daily_usage` (view or function) | Today's total against the tier limit for the slim bar |

`kind` values: `fund_bank`, `fund_card`, `send_bank`, `withdraw`, `transfer_own_account`, `savings_in`, `savings_out`, `interest`, `group_contribution`, `group_payout`, `subscription`, `loan_disbursement`, `loan_repayment`, `fee`, `refund`.

Functions (private, called through thin RPC wrappers):
- `wallet_send(account_id, amount, destination, idempotency_key, pin)`: checks PIN, limit, balance (row lock with `select ... for update`), writes debit plus fee, creates a `processing` row, returns it.
- `wallet_transfer_own(from_account, to_account, amount, key)`: both legs in one transaction (screen 17 "My other account").
- `wallet_credit_from_webhook(...)`: called only by the Edge Function with the service role. Deduplicates on the provider reference.
- A trigger keeps `wallets.balance_kobo` equal to the ledger. A nightly check job compares the two and raises an alert if they differ.
- Duplicate-transfer warning (same amount and recipient within a few minutes) is a read function the app calls before confirming.

**Payment partner [OPEN, not yet chosen]:** virtual accounts, card funding, bank transfers and name lookup all need one. Plan: a single `payment_provider` module in Edge Functions, so only that one function changes when the partner is chosen. Webhooks verify the provider signature, then call the service-role credit function.

## 5. Budgets and expenses (screens 20 to 23, 30 to 33)

| Table | Purpose |
|---|---|
| `expense_categories` | Per account. Seeded from templates: Individual (Feeding, Transport, Emergency fund, Rent, Airtime and data, School fees) and Business (Stock purchases, Salaries and others) |
| `budgets` | `category_id, amount_kobo, period (monthly\|yearly), starts_on, repeat, rollover, alert_80, alert_100, paused` |
| `expenses` | `amount_kobo, category_id, spent_at, source (wallet\|manual\|voice), wallet_transaction_id (nullable), note, receipt_path` |

- Unique budget per `(account_id, category_id, period, starts_on)` for the duplicate warning.
- `budget_progress` view (`security_invoker = true`): spent, remaining, days left, daily allowance, state (green below 80%, amber 80 to 100, red above).
- A trigger on `expenses` creates the 80% and 100% notification once per budget per period.
- Voice logging: audio is turned into fields by an Edge Function (the speech provider is a later choice). Nothing is saved until the user confirms.

## 6. Savings (screens 24 to 29)

| Table | Purpose |
|---|---|
| `savings_pockets` | `type (save_as_you_spend\|fixed\|locked\|group_link)`, name, target_kobo, balance_kobo, `rate_bps` snapshot at creation (300 or 1200), `matures_on`, `auto_frequency`, `spend_percent`, `status`, closed_at |
| `savings_entries` | Append-only: contribution, withdrawal, interest, with the wallet transaction id |
| `interest_runs` | One row per run, so a run is never applied twice |

Rules:
- Rates are stored per pocket (`rate_bps`) so a later rate change never rewrites existing pockets. Locked is 12% per year, Fixed and Save as you spend 3% per year, **simple interest**.
- Locked pockets: money in only at creation, withdrawal blocked by a check in the withdraw function until `matures_on`. Terms acceptance is recorded (`terms_accepted_at`).
- Save as you spend: an after-insert trigger on wallet debits that match the pocket rule moves `spend_percent` to the pocket in a second ledger entry.
- Maturity: a scheduled job sends the notification and sets the pocket to `matured` with the two choices (move to wallet or lock again).
- **[OPEN]** When 3% interest is credited (monthly or on close) and whether Fixed and Save as you spend allow withdrawal any time. Both are columns in a `savings_rules` config table (`interest_credit_mode`, `withdraw_any_time`), defaulting to "monthly" and "true" until confirmed.

### Group savings (Ajo and Esusu)
| Table | Purpose |
|---|---|
| `savings_groups` | name, organiser, monthly_amount_kobo, member_count, start_month, due_day (25), grace_days (3), missed_rule, status |
| `group_members` | group, user, account, payout_position, status (invited\|active\|left) |
| `group_cycles` | One per month: cycle_number, due_on, payout_on, recipient_member_id, status |
| `group_contributions` | cycle, member, amount, status (due\|paid\|late\|missed), wallet_transaction_id |
| `group_payouts` | cycle, recipient, amount, wallet_transaction_id |
| `group_invites` | token, phone or contact, status |

- The pot is simply the sum of paid contributions for the cycle; no interest on group pots.
- Payout runs in one transaction at cycle end: recipient credited, cycle closed, receipts notified to all members.
- **[OPEN, revise with Victory]** missed-payment outcome (pot waits, or taken from the next payout), leaving mid-cycle, KYC tier 2 to join. Stored as `savings_groups.missed_rule` and a `min_kyc_tier` config so changing them is a data change.

## 7. Inventory (screens 34 to 39), Business only

| Table | Purpose |
|---|---|
| `product_categories` | Unique name per account; cannot delete a non-empty category (FK `restrict`) |
| `products` | name, sku (unique per account), unit, cost_kobo, price_kobo, `qty_on_hand`, `qty_reserved`, `qty_available` as a generated column (on_hand minus reserved), low_stock_threshold, low_stock_alert, image_path, archived_at |
| `stock_movements` | Append-only: restock, reservation, release, sale, adjustment (damaged, lost, count_correction), with who did it and the linked invoice or sale |
| `stock_reservations` | product, invoice, customer, qty, `reserved_at`, `expires_at` (reserved_at + 10 days), status (active\|released\|consumed), `day8_notified_at` |
| `restock_reminders` | product, remind_at |

Integrity:
- Check constraints: `qty_on_hand >= 0`, `qty_reserved >= 0`, `qty_reserved <= qty_on_hand`. The database refuses to oversell even if the app has a bug.
- Reserve, release and consume are functions that lock the product row (`for update`) and write the movement in the same transaction.
- Release triggers: invoice cancelled, manual release, or expiry. Consuming happens when a sale is created.

## 8. Customers, invoices, sales (screens 40 to 51), Business only

| Table | Purpose |
|---|---|
| `customers` | name, phone (WhatsApp), email, address, notes, archived_at. Cannot archive while unpaid invoices exist (enforced in the archive function) |
| `invoice_counters` | Per business: prefix and last number, incremented atomically, so numbers never collide |
| `invoices` | number, customer, status (draft\|sent\|partially_paid\|paid\|overdue\|cancelled), issue/due dates, subtotal, discount, vat, charges, total, amount_paid, balance, notes, `issued_at`, `updated_revision_at` |
| `invoice_items` | invoice, product (nullable for custom lines), description, qty, unit_price, cost_snapshot |
| `invoice_payments` | invoice, amount, method (wallet\|transfer\|cash\|pos\|card), paid_on, reference, proof_path, wallet_transaction_id |
| `sales` | invoice (nullable for quick sale), customer, total, cost_total, profit, sold_at, receipt number |
| `sale_items` | product, qty, price_snapshot, cost_snapshot |

Rules from the design:
- **Draft holds no stock.** `issue_invoice()` reserves stock for every inventory line in one transaction and fails with the maximum available if any line is short.
- **No edits after a payment.** An update trigger blocks changes to totals and items once `amount_paid > 0`. Cancel and reissue instead.
- `record_payment()` rejects zero and anything above the balance, updates status to partially_paid or paid, and when the balance hits zero calls `create_sale_from_invoice()`: sale and sale_items created, reservations consumed (stock leaves `qty_on_hand` and `qty_reserved`), cost snapshotted so later price changes never alter past profit.
- Overdue: a daily job flips `sent` and `partially_paid` invoices past due date to overdue.
- No public invoice link (decision). WhatsApp sharing is a client feature using a generated PDF.
- **[OPEN] Sale reversals:** schema leaves room (`sales.reversed_at`, `reversal_reason`, stock movement kind `reversal`) but no function is written until the board decides.

## 9. Notifications and alerts (screens 52 and the alert features)

| Table | Purpose |
|---|---|
| `notifications` | account, kind, title, body, payload (jsonb), read_at, created_at |
| `notification_preferences` | Per user and kind: push on or off, weekly budget summary |
| `push_tokens` | Part of `devices` |

- Notifications are written by database functions and triggers (budget thresholds, reservation day 8 and day 10, overdue invoices, low stock, maturity, group due dates). A Database Webhook calls an Edge Function that sends the push (FCM).
- Realtime subscription on `notifications` and `wallets` for the live bell and balance.
- Pro smart notifications (restock suggestions, overdue alerts) are scheduled jobs gated by the account's Pro status.

## 10. Subscription and support (screens 12, 13)

| Table | Purpose |
|---|---|
| `plans` | Config: Individual Pro (₦5,000 or $5), Business Pro (₦10,000 or $8), `billing_period` and `grace_days` **[OPEN]** |
| `subscriptions` | account, plan, status (active\|past_due\|cancelled\|expired), current_period_end, payment_method, cancel_reason |
| `support_tickets` | reference number, category, related transaction or invoice, description, status (open\|in_progress\|resolved), attachments |
| `support_messages` | Thread replies |

- `is_pro(account_id)` is a function reading `subscriptions` (including the grace period). RLS and RPCs for Pro-only features call it, so locking after a failed renewal is automatic.
- Subscription charge goes through the wallet ledger (`kind = subscription`) or card via the provider webhook.

## 11. Pro and growth features (screens 53 to 58) **[mostly OPEN]**

Designed as configuration so nothing blocks the build:

| Table | Purpose |
|---|---|
| `health_factors` | Config: key (overdue_invoices, stockouts, payment_speed, sales_steadiness), weight, enabled. **[OPEN]** list and weights |
| `health_bands` | Config: name, min_score, max_score, colour token. **[OPEN]** boards use example ranges |
| `business_health_scores` | account, score, band, factor breakdown (jsonb), computed_at. Computed by a nightly job |
| `loan_products` | Config: lender, limit, rate, fee, tenor. **[OPEN]** seeded with the example terms (₦300,000, 3.5% a month flat, 1% fee, ₦60,500 x 6) flagged `is_example` |
| `loan_applications`, `loans`, `loan_repayments` | Application, schedule and repayments through the ledger |
| `report_access` | Config: report key to `free` or `pro`. **[OPEN]** |
| `hub_listings`, `hub_enquiries` | Business Hub provider/buyer listing and messages. Listing rule **[OPEN]** |

Reports (sales, profit, expenses, inventory valuation) are SQL views and functions with `security_invoker`, never separate stored copies.

## 12. Storage buckets

| Bucket | Public | Path | Notes |
|---|---|---|---|
| `kyc` | no | `{user_id}/...` | Owner and service role only |
| `product-images` | no | `{account_id}/...` | Signed URLs |
| `business-logos` | no | `{account_id}/...` | Used when generating invoice PDFs |
| `receipts` | no | `{account_id}/...` | Expense receipts, payment proof |
| `support` | no | `{user_id}/...` | Complaint screenshots |

Storage policies follow "folder name equals an account the user belongs to". Upsert needs INSERT, SELECT and UPDATE policies together.

## 13. Edge Functions (service role stays here, never in the app)

1. `payment-webhook`: verify signature, credit the wallet, update transfer status.
2. `kyc-webhook`: update submissions and `profiles.kyc_tier`.
3. `send-push`: fan out notifications to devices.
4. `voice-parse`: audio or transcript to structured expense, inventory or invoice fields.
5. `invoice-pdf` / `statement-pdf`: generate PDFs for sharing and loan applications.

## 14. Scheduled jobs (`pg_cron`)

| Job | When | Does |
|---|---|---|
| Reservation reminders | hourly | Day 8 notice and day 10 notice; release expired reservations |
| Invoice overdue | daily | Mark overdue, notify |
| Savings maturity | daily | Mature pockets, notify |
| Interest | per **[OPEN]** rule | Credit simple interest, write `interest_runs` |
| Group cycles | daily | Due reminders, grace expiry, payouts on the last day of the month |
| Budget renewals | daily | Roll over and repeat budgets |
| Health score | nightly | Recompute scores |
| Ledger reconcile | nightly | Compare wallet balances with the ledger and alert |
| Subscription renewals | daily | Charge, retry, grace, lock |

## 15. Migration order

Created with `supabase migration new <name>` (never hand-named):

1. extensions, enums, private schema, helper functions
2. profiles, accounts, account_members, business_profiles, devices, user_security
3. kyc_tiers, kyc_submissions, kyc_documents
4. wallets, wallet_transactions, beneficiaries, banks, money functions
5. expense_categories, budgets, expenses, views
6. savings pockets and entries, savings_rules, interest functions
7. group savings tables and functions
8. product_categories, products, stock tables and functions
9. customers, invoices, payments, sales and functions
10. notifications, preferences, support
11. plans, subscriptions, `is_pro()`
12. Pro and growth config tables (health, loans, reports, hub)
13. storage buckets and policies
14. cron jobs
15. seed: kyc_tiers (provisional), plans, templates, example loan product

`schema.sql` in the repo root is empty and stays unused; migrations in `supabase/migrations/` are the single source of truth.

## 16. Testing and checks

- pgTAP tests per module: RLS (a user cannot read or write another account's rows; an Individual account cannot touch Business tables), ledger reconciliation, oversell prevention, 10-day expiry, no edit after payment, locked savings withdrawal, idempotent retries.
- Run `supabase db advisors` before every migration is committed; fix every warning.
- Views use `security_invoker = true`. No `SECURITY DEFINER` in `public`.

## 17. Decisions needed from you to start Step 2 build

1. **Hosted project or local CLI?** Recommendation: use the existing hosted project (ref `mvisrdmdxbenuqezprdn`) with `supabase link` and `supabase db push`. It needs no Docker and uses fewer tokens and less laptop time. Local can be added later.
2. **Payment partner:** on hold by decision. Columns that will later point at wallet transactions (expenses, savings entries, invoice payments) are plain nullable `uuid` columns for now, with the foreign key added when the wallet migration is written.
3. Everything marked **[OPEN]** stays as configuration until the board answers; see `claude/uruvia-open-decisions.md` in the Project.
