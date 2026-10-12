# Design reference vs app: gaps (12 Oct 2026)

Compared the Uruvia Design Reference (58 screens) with the code. This was a search through the code, not a run of the app, so each item should be confirmed on a device before it is built.
Left out on purpose: wallet, KYC, group savings, bills, real voice, loans, Business Health, the Hub marketplace, support attachments, Drift offline cache, dark mode, Android API 36.

## A. Before launch
1. **Change password** (Settings > Security): not in the app.
2. **Weak PIN rule** (screen 6): rejecting 0000, 1234 and repeated digits was not found.
3. **Force-update and maintenance screens**, and **session-expired** handling (screen 14): not built.
4. **Text size**: the spec scales text up to 130%; no limit is set, so very large system fonts may break layouts.
5. **Reports** (55) show sample figures. Real reports needed: profit and loss, sales, expenses, inventory valuation, receivables by age, customer statement, with PDF/CSV export.
6. **Photos and files** (DONE, migration 0018): product image, business logo, avatar, expense receipt, payment proof. No storage buckets exist except `kyc`. Needs camera/photo permission prompts with an explanation first.
7. **Trusted devices** with remote sign-out (settings): the `devices` table exists but the app never registers a device and there is no screen.
8. **Settings > Help**: app version, FAQs, and the Support hub contact cards (WhatsApp, call, email). Needs Uruvia's real contact details.

## B. Should fix
- **Smart alerts feed** (52) (AFTER LAUNCH, decided 12 Oct) with inline actions (send reminder, extend/release reservation, restock), alert-type choices, quiet hours and daily summary time. The `alerts` folder is empty.
- **Notifications** (9): All / Money / Business / System tabs, swipe to read or delete.
- **Expenses** (30, 31, 33): DONE: search, category filter, swipe edit/delete, receipt photo. Date range filter added too (source filter not needed: no source column in the UI); insights lack week/year choice, budget versus actual bars, tips, PDF/CSV export.
- **Budgets** (20 to 23): DONE (migration 0019): quick-start template chips, rollover switch (unspent money is added to the next period), weekly bars, apply now or from next period. Still open: weekly summary alert, emergency-fund pocket offer (needs real savings).
- **Invoices** (43, 44): DONE: send reminder, duplicate, 25%/50% chips, proof photo. Still open: timeline of events.
- **Customers** (48): DONE: Call, WhatsApp, billed/paid/outstanding, purchase history. Still open: import from contacts (adds a contacts permission, decide first).
- **Sales** (49, 50): DONE: 7-day bar chart, search, share receipt as text. Still open: stock effect (before and after), PDF receipt.
- **Inventory** (34, 35, 36): DONE: barcode scan (stored as the SKU), list/grid toggle, unit chips, save and add another. Still open: full history timeline.
- **Home** (7, 8): DONE: new-business checklist, upgrade card (hidden for Pro). Already there: wallet card, quick actions, budget summary (as a bar), business stat tiles, recent lists. Still open: budget as a ring, savings snapshot (needs real savings), quick-create sheet. The original screen 7 and 8 wording was not available to compare, so check on a device.
- **Savings extras**: Compare sheet, maturity reminder and the Move to wallet / Lock again screen (savings is still sample data).

## C. Where the spec and our decisions differ
- Spec: Budgets, Expenses and Savings are Individual only and Invoices Business only. We changed this: Budget, Expenses and Savings are on both; Invoices and Customers are on both.
- Spec: "Social sign-in: leave out at launch". We added Google and Apple sign-in.
- Spec Business Hub (56, 57) is a **marketplace** (providers, requests, listings). Our Hub is a Pro tools page (health, reports, alerts). The marketplace is untouched.
- Spec account deletion has two confirmation screens; ours is one screen with PIN and typed DELETE.
- Spec Wallet screens show a real balance and account number; ours are sample data until Providus.

## D. Open decisions in the spec that still need Victory
Business Health bands and factors, lender terms, sale reversals, free versus Pro reports, Hub listing rule, Pro billing and grace period, one wallet or two, interest credit timing, whether fixed and save-as-you-spend can be withdrawn, group missed-payment rules.
