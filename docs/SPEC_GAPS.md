# Design reference vs app: gaps (12 Oct 2026)

Compared the Uruvia Design Reference (58 screens) with the code. This was a search through the code, not a run of the app, so each item should be confirmed on a device before it is built.
Left out on purpose: wallet, KYC, group savings, bills, real voice, loans, Business Health, the Hub marketplace, support attachments, Drift offline cache, dark mode, Android API 36.

## A. Before launch
1. **Change password** (Settings > Security): not in the app.
2. **Weak PIN rule** (screen 6): rejecting 0000, 1234 and repeated digits was not found.
3. **Force-update and maintenance screens**, and **session-expired** handling (screen 14): not built.
4. **Text size**: the spec scales text up to 130%; no limit is set, so very large system fonts may break layouts.
5. **Reports** (55) show sample figures. Real reports needed: profit and loss, sales, expenses, inventory valuation, receivables by age, customer statement, with PDF/CSV export.
6. **Photos and files**: product image, business logo, avatar, expense receipt, payment proof. No storage buckets exist except `kyc`. Needs camera/photo permission prompts with an explanation first.
7. **Trusted devices** with remote sign-out (settings): the `devices` table exists but the app never registers a device and there is no screen.
8. **Settings > Help**: app version, FAQs, and the Support hub contact cards (WhatsApp, call, email). Needs Uruvia's real contact details.

## B. Should fix
- **Smart alerts feed** (52) with inline actions (send reminder, extend/release reservation, restock), alert-type choices, quiet hours and daily summary time. The `alerts` folder is empty.
- **Notifications** (9): All / Money / Business / System tabs, swipe to read or delete.
- **Expenses** (30, 31, 33): search and filters (date, category, source), swipe to edit/delete, receipt photo; insights lack week/year choice, budget versus actual bars, tips, PDF/CSV export.
- **Budgets** (20 to 23): template chips, rollover switch (column exists, no UI), weekly trend bars, "apply now or from next period" on edit, alert settings with weekly summary, emergency-fund pocket offer.
- **Invoices** (43, 44): send reminder, duplicate, 25% and 50% quick chips, proof photo, timeline of events.
- **Customers** (48): Call and WhatsApp buttons, import from contacts, billed/paid/outstanding totals and purchase history.
- **Sales** (49, 50): bar chart, search and filter, stock effect (before and after), share receipt and PDF.
- **Inventory** (34, 35, 36): barcode scan, list/grid toggle, unit choice, "save and add another", full history timeline.
- **Home** (7, 8): check against the spec: budget ring, savings snapshot, upgrade card, stat tiles, quick-create sheet, new-business checklist.
- **Savings extras**: Compare sheet, maturity reminder and the Move to wallet / Lock again screen (savings is still sample data).

## C. Where the spec and our decisions differ
- Spec: Budgets, Expenses and Savings are Individual only and Invoices Business only. We changed this: Budget, Expenses and Savings are on both; Invoices and Customers are on both.
- Spec: "Social sign-in: leave out at launch". We added Google and Apple sign-in.
- Spec Business Hub (56, 57) is a **marketplace** (providers, requests, listings). Our Hub is a Pro tools page (health, reports, alerts). The marketplace is untouched.
- Spec account deletion has two confirmation screens; ours is one screen with PIN and typed DELETE.
- Spec Wallet screens show a real balance and account number; ours are sample data until Providus.

## D. Open decisions in the spec that still need Victory
Business Health bands and factors, lender terms, sale reversals, free versus Pro reports, Hub listing rule, Pro billing and grace period, one wallet or two, interest credit timing, whether fixed and save-as-you-spend can be withdrawn, group missed-payment rules.
