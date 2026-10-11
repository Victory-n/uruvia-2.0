# Pre-launch checklist (11 Oct 2026)

## Permissions policy
Do NOT ask for everything at launch. Google Play and Apple both expect permissions to be requested in context, only when the feature is used, after a plain-language explanation, with a working alternative if the user says no.
Apple 5.1.1 / 5.1.2: purpose strings must be clear, the app must not require push/location/tracking to work.
Google Play: prominent in-app disclosure right before a sensitive permission; request incrementally.

| Permission | Status | When to add / ask |
|---|---|---|
| INTERNET, ACCESS_NETWORK_STATE | kept | normal, no prompt |
| USE_BIOMETRIC / NSFaceIDUsageDescription | kept | ask when user turns on biometric unlock in Settings |
| RECORD_AUDIO, speech recognition, microphone | REMOVED for now | add with the real voice feature; ask when user taps the mic |
| Camera, photo library | REMOVED for now | add with KYC / attachments; ask when user taps "Take photo" |
| POST_NOTIFICATIONS (Android 13+), iOS notifications | not added | add with real push; ask after the user's first useful moment, never on first launch |
| Contacts, SMS, location, storage | never | not needed; banned for loan apps on Play |

Re-add the removed keys together with the feature that uses them.

## Store requirements
- [ ] Privacy policy URL https://uruvia.com/privacy and terms https://uruvia.com/terms: in-app done; also enter them in App Store Connect and Play Console. Make sure both pages are live and mention account deletion.
- [x] In-app account deletion (Apple 5.1.1(v)): built, Settings > Delete my account.
- [ ] Play: Data safety form, Financial features declaration, content rating.
- [ ] Play: target Android 16 (API 36) for new apps/updates from 31 Aug 2026. Check `flutter --version`, set targetSdk explicitly if needed.
- [ ] Play: check 16 KB page-size support (plugins and NDK; ndkVersion is 29, good).
- [ ] Apple: Sign in with Apple capability in Xcode; bundle ID registered in Supabase Client IDs.
- [ ] Apple 3.1.1: Pro subscription on iOS must use In-App Purchase. Play Billing on Android.
- [ ] Apple 3.2.1/5.1.1(ix): finance apps are expected to come from a legal entity (company account), not an individual.
- [ ] Loan features: Play needs FCCPC digital lending approval in Nigeria; show max APR and repayment period; no repayment under 60 days. Apple 3.2.2(ix): APR max 36%.
- [ ] Release: signing key backed up, R8/ProGuard checked, icons, splash, screenshots, listing text.
- [ ] Supabase: custom SMTP/domain, reset-password template with `{{ .Token }}`, Google/Apple providers fixed, RLS review of migrations 0014 and 0015.
- [ ] Run apply_0015_only.sql (quick sale) in the SQL Editor.

## Sources
Google Play prominent disclosure and permissions policy; Google Play Financial Services policy; Android target API requirements; Apple App Review Guidelines (4.8, 5.1.1, 5.1.2, 3.1.1, 3.2.1, 3.2.2).
