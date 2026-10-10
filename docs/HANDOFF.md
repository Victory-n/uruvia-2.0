# Uruvia design hand-off

Source of truth for how a screen should look: the **Uruvia Design Reference** doc in the Claude Project.
Source of truth for what data exists: `supabase/migrations/` and `docs/SUPABASE_PLAN.md`.
This file connects the two: which screen goes in which feature folder, where its data comes from, and in what order we build.

## 1. Rules that apply to every screen

1. Colours come from `AppPalette` and `StatusColors` only. Fonts: Plus Jakarta Sans for headings, Inter for body and every figure (tabular numerals).
2. Money is integer kobo. Format only with `formatNaira`. Debits and credits carry a sign as well as colour.
3. Layout: design at 390 x 844 and check at 360 x 800. 4 pt grid, side margin 20 (16 under 360), minimum touch target 48, card padding 16, section gap 24.
   Radius: chips 8, buttons and inputs 12, cards 16, sheet top corners 24. Primary button 52 high.
4. Every screen ships with its states: loading, empty, error with Retry, and offline (read-only banner). See screen 14.
5. Widgets never call Supabase. Screen, then controller (Riverpod), then repository.
6. Business-only screens are blocked in the router for Individual accounts. The database enforces it as well.
7. Navigation is a sidebar drawer on phones, never a bottom bar.
8. Respect the system reduce-motion setting. Smallest text 12 sp. Sentence case.

## 2. Data mode for each feature

- **LIVE**: repository talks to Supabase (tables and functions already exist).
- **DUMMY**: repository returns fixed sample data from a `fake_*_repository.dart`. Nothing is saved. Used for everything that touches the wallet or an undecided business rule.

Each feature gets one abstract repository, a `Fake...` and (when LIVE) a `Supabase...` implementation. A single Riverpod provider chooses which one, so switching DUMMY to LIVE later changes one line and no screens.

## 3. Screen map

| # | Screen | Feature folder | Route | Mode | Data source |
|---|---|---|---|---|---|
| 1 | Splash and onboarding | auth, onboarding | `/`, `/onboarding` | LIVE | session check |
| 2 | Authentication | auth | `/auth/*` | LIVE | Supabase Auth (email, phone OTP) |
| 3 | Account type selection | account | `/account-type` | LIVE | `create_account()` |
| 4 | Business setup (3 steps) | account | `/business-setup` | LIVE | `business_profiles` |
| 5 | KYC | kyc | `/kyc/*` | LIVE (provider later) | `kyc_tiers`, `kyc_submissions`, `kyc_documents`, `kyc` bucket |
| 6 | Create PIN and biometrics | auth | `/pin` | LIVE | `set_transaction_pin()`; app-lock PIN is device-only |
| 7 | Home: Individual | home | `/home` | LIVE + DUMMY wallet card | `budget_progress`, `expenses`, `notifications` |
| 8 | Home: Business | home | `/home` | LIVE + DUMMY wallet card | `invoices`, `sales`, `products`, `notifications` |
| 9 | Notifications centre | notifications | `/notifications` | LIVE | `notifications` |
| 10 | Profile and settings | settings | `/settings/*` | LIVE | `profiles`, `devices`, `notification_preferences` |
| 11 | Account switcher | account | sheet | LIVE | `accounts`, `profiles.last_active_account_id` |
| 12 | Subscription | subscription | `/plan` | DUMMY checkout | `plans`, `subscriptions` (read) |
| 13 | Support | support | `/support/*` | LIVE | `support_tickets`, `support_messages` |
| 14 | Empty, loading, error, offline | core/widgets | n/a | n/a | shared components |
| 15 | Wallet overview | wallet | `/wallet` | DUMMY | none yet |
| 16 | Fund wallet | wallet | `/wallet/fund` | DUMMY | none yet |
| 17 | Send and withdraw | wallet | `/wallet/send` | DUMMY | none yet |
| 18 | Transaction history and detail | wallet | `/wallet/transactions` | DUMMY | none yet |
| 19 | Bills and airtime | wallet | later | not started | needs payment partner |
| 20 | Budget overview | budget | `/budgets` | LIVE | `budget_progress` |
| 21 | Create budget | budget | `/budgets/new` | LIVE | `budgets`, `expense_categories` |
| 22 | Budget detail | budget | `/budgets/:id` | LIVE | `budget_progress`, `expenses` |
| 23 | Edit, delete, alerts | budget | sheet | LIVE | `budgets`, `notification_preferences` |
| 24 | Savings overview | savings | `/savings` | DUMMY | tables on hold |
| 25 | Choose savings type | savings | `/savings/new` | DUMMY | on hold |
| 26 | Create a pocket | savings | `/savings/new/:type` | DUMMY | on hold |
| 27 | Pocket detail | savings | `/savings/:id` | DUMMY | on hold |
| 28 | Locked savings confirmation | savings | `/savings/:id/confirm` | DUMMY | on hold |
| 29 | Group savings | savings | `/savings/groups/*` | DUMMY | on hold; screens to be revised with Victory |
| 30 | Expense list | expenses | `/expenses` | LIVE | `expenses` |
| 31 | Add or edit expense | expenses | `/expenses/new` | LIVE | `expenses`, `receipts` upload later |
| 32 | Voice logging | expenses | `/expenses/voice` | DUMMY | speech provider not chosen |
| 33 | Expense insights | expenses | `/expenses/insights` | LIVE | `expenses`, `budget_progress` |
| 34 | Inventory list | inventory | `/inventory` | LIVE | `products` |
| 35 | Add or edit product | inventory | `/inventory/new` | LIVE | `products`, `product_categories` |
| 36 | Product detail | inventory | `/inventory/:id` | LIVE | `products`, `stock_movements`, `stock_reservations`, `restock_product()`, `adjust_product_stock()` |
| 37 | Reserve (book down) stock | inventory | sheet | LIVE | `reserve_product_stock()`, `release_product_reservation()` |
| 38 | Category management | inventory | `/inventory/categories` | LIVE | `product_categories` |
| 39 | Low stock and reminders | inventory | `/inventory/low` | LIVE | `products`, `restock_reminders` |
| 40 | Invoice list | invoices | `/invoices` | LIVE | `invoices` |
| 41 | Create invoice | invoices | `/invoices/new` | LIVE | `invoices`, `invoice_items` |
| 42 | Invoice preview | invoices | `/invoices/:id/preview` | LIVE | `issue_invoice()` |
| 43 | Invoice detail | invoices | `/invoices/:id` | LIVE | `invoices`, `cancel_invoice()`, `revert_invoice_to_draft()` |
| 44 | Record a payment | invoices | sheet | LIVE (no wallet method) | `record_invoice_payment()` |
| 45 | Updated invoice after payment | invoices | `/invoices/:id` | LIVE | `invoice_payments` |
| 46 | Verify payment, mark as paid | invoices | sheet | LIVE | `record_invoice_payment()` (balance to zero creates the sale) |
| 47 | Share invoice | invoices | sheet | LIVE | PDF generated on the phone, shared to WhatsApp |
| 48 | Customers | customers | `/customers/*` | LIVE | `customers`, `archive_customer()` |
| 49 | Sales list and summary | sales | `/sales` | LIVE | `sales` |
| 50 | Sale detail | sales | `/sales/:id` | LIVE | `sales`, `sale_items`, `stock_movements` |
| 51 | Quick sale and receipt | sales | later | not started | optional, board to decide |
| 52 | Smart notifications feed (Pro) | notifications | `/notifications` | LIVE for existing kinds | `notifications`, `is_pro` |
| 53 | Business Health (Pro) | health | `/health` | DUMMY | bands and factors undecided |
| 54 | Loan eligibility (Pro) | health | `/health/loan` | DUMMY | lender terms undecided |
| 55 | Reports | reports | `/reports` | DUMMY | free vs Pro split undecided |
| 56 | Business Hub | hub | `/hub` | DUMMY | listing rule undecided |
| 57 | Hub locked state | hub | `/hub` | DUMMY | UI only |
| 58 | Upgrade touchpoints | subscription | shared widget | DUMMY | at most one prompt per screen, never during payment, invoice or sale flows |

## 4. Build order

Each step ends with `flutter analyze` clean, tests for the domain rules, and the screens in all their states.

1. **Foundation:** theme with the two fonts, shared components (buttons, fields, amount field, keypad, status chip, bottom sheet, empty/loading/error/offline), sidebar shell. Screen 14.
2. **Auth and onboarding:** screens 1, 2, 3, 4, 6, then the app-lock behaviour (device PIN, 3-minute idle lock).
3. **Home and navigation:** 7, 8, 9, 10, 11 with the account switch animation.
4. **Budgets and expenses:** 20 to 23, 30, 31, 33.
5. **Inventory:** 34 to 39.
6. **Customers, invoices, sales:** 40 to 50.
7. **KYC screens:** 5, with upload to the private `kyc` bucket.
8. **Support, subscription (dummy checkout), settings details:** 12, 13, rest of 10.
9. **Wallet (dummy):** 15 to 18.
10. **Savings (dummy):** 24 to 29.
11. **Pro screens (dummy):** 52 to 58, voice logging 32.

Wallet, savings, voice and Pro screens switch from DUMMY to LIVE only after the payment partner and the board decisions are settled (see the open-decisions checklist in the Project).

## 5. Known gaps

- Payment partner, KYC tier limits, billing period and grace days: not decided. Tables hold placeholders.
- Group savings screens will be revised with Victory before they are built.
- Fonts need a check that the naira sign renders in Plus Jakarta Sans; if it does not, amounts stay in Inter (already the rule).
