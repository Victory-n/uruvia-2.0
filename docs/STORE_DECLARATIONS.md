# Google Play declarations: answers for today's app (12 Oct 2026)

Both forms are filled in on the Play Console (Policy > App content). Nothing here goes in the app code.
These answers match the app as built today (no wallet, KYC, push or analytics yet). Re-check the form wording in the console, Google changes it. Update the Data safety form before each release that adds data collection.

## 1. Data safety form

**Top-level questions**
- Does the app collect or share required user data types? Yes.
- Is all user data encrypted in transit? Yes (HTTPS to Supabase).
- Do you provide a way for users to request data deletion? Yes.
  - In-app: Settings > Delete my account.
  - Web link (required): publish a page, e.g. https://uruvia.com/delete-account, explaining how to delete (open the app > Settings > Delete my account, or email support). Put that URL in Play Console > App content > Data safety > Data deletion.
- Independent security review: No (optional).

**Data types** (collected = yes for all below; none of it is sold; sent to Supabase, our hosting provider, which acts as a service provider, so it is not counted as "shared")

| Category | Type | Collected | Shared | Required | Purpose |
|---|---|---|---|---|---|
| Personal info | Name | Yes | No | Required | App functionality, account management |
| Personal info | Email address | Yes | No | Required | App functionality, account management |
| Personal info | User IDs (account id) | Yes | No | Required | App functionality |
| Personal info | Phone number | Not yet (add when KYC ships) | | | |
| Financial info | Other financial info (expenses, budgets, savings goals, invoices, sales, prices) | Yes | No | Required for those features | App functionality |
| Financial info | User payment info / purchase history | No (until wallet/Providus and Pro billing ship) | | | |
| Messages | Other in-app messages (support tickets) | Yes | No | Optional | App functionality, customer support |
| App info and performance | Crash logs, diagnostics | No | | | |
| Device or other IDs | Device ID / push token | No (add when push ships) | | | |
| Photos, files, audio, location, contacts, calendar, health | No | | | | |

Notes
- Customers a business enters (name, phone, email, address) are the business owner's data stored for them. Declare it as Personal info (name, email, phone, address) collected, not shared, optional.
- If you add analytics or crash reporting (Firebase, Sentry), add App activity and App info and performance, and mark them shared with that provider.
- Sign in with Google: Google processes the sign-in itself. No extra data type is needed beyond name and email.
- Security practices to tick: data encrypted in transit; users can request deletion.

## 2. Financial features declaration

Pick the option that matches the app as shipped.

**If the first release ships as it is today** (expense tracking, budgets, invoices, sales, stock; wallet, savings and loan screens are previews)
- Select: "My app doesn't provide any financial features" if the form offers it for budgeting and bookkeeping tools; otherwise choose "Personal finance management / budgeting" or the closest tracking option.
- Do NOT select banking, payments, money transfer, loans or investments.
- To avoid a reviewer reading the preview screens as real products, either hide Wallet, Savings and Health/Loan from the first store build, or keep the "Preview: sample figures" banners clearly visible. Safer: hide them.

**When the Providus wallet goes live** (holding or moving money)
- Declare payments/wallet or banking features, name the licensed partner (Providus Bank), and be ready for Google to ask for licence or partner evidence.
- Update Data safety: financial info (user payment info, transaction history), phone number, government ID or BVN (KYC), photos of ID.

**If a loan feature ever goes live** (offering or linking to loans, not only an "eligibility" screen)
- Select personal loans, category must be Finance, show max APR and repayment period, no repayment under 60 days.
- Nigeria: upload the FCCPC digital lending approval letter.
- Banned permissions for loan apps: contacts, photos/videos, external storage, fine location, phone numbers, installed-apps list.

## 3. Other App content forms to complete
- Privacy policy URL: https://uruvia.com/privacy
- App access: give Google a test account (email + password + PIN) with sample data, since the app needs sign-in.
- Ads: No ads.
- Content rating questionnaire: finance/utility, no user-generated public content.
- Target audience: 18 and over (keeps you out of the Families policy).
- News app, COVID, government app: No.
- Account deletion (the Data safety deletion link above).

## 4. App Store Connect equivalents (for iOS later)
- App Privacy "nutrition label": same data types as the table above, all "linked to the user", none used for tracking.
- Privacy policy URL and (if asked) terms URL.
- Account deletion: in-app, done.
- Sign in with Apple: done alongside Google.
- Notes for review: provide a demo account.
