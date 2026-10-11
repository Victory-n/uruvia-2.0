# Google and Apple sign-in: one-time setup

The buttons are in the app. They need these settings before they work.
Policy note: Apple requires "Sign in with Apple" only when an iOS app offers another social login. The app shows Google on Android and Apple on iOS, so each store's rule is met. Google Play does not require Google sign-in.

## Google (Android)
1. Google Cloud Console > APIs and Services > OAuth consent screen: set up the app (name, support email, logo).
2. Credentials > Create OAuth client ID:
   - **Web application**: copy its Client ID and Client secret. This is the one the app and Supabase use.
   - **Android**: package name `com.example.uruvia` (use your real applicationId) plus the SHA-1 of the debug key and, later, the Play App Signing key. Get the debug SHA-1 with `cd android && ./gradlew signingReport`.
3. Supabase dashboard > Authentication > Sign In / Providers > Google: turn on, paste the Web Client ID and secret, and turn on **Skip nonce checks** (the Android library does not send one).
4. Run or build the app with `--dart-define=GOOGLE_WEB_CLIENT_ID=<web client id>`. Without it the button says Google sign-in is not set up yet.

## Apple (iOS)
1. Apple Developer > Identifiers > your app ID: turn on the **Sign In with Apple** capability.
2. Open `ios/Runner.xcworkspace` in Xcode > Runner > Signing and Capabilities > + Capability > **Sign In with Apple**.
3. Supabase dashboard > Authentication > Providers > Apple: turn on and add your app's **Bundle ID** under Authorized Client IDs. The native flow needs no secret key.
4. Test on a real iPhone signed in to an Apple ID. The simulator is unreliable for this.

## After sign-in
New social users go through the same steps as email users: account type, then the transaction PIN.
