<p align="center">
  <img src="assets/branding/subly_icon_1024.png" alt="Subly Logo" width="110" style="border-radius: 22px;" />
</p>

<h1 align="center">Subly</h1>

<p align="center">
  <strong>Know where your money recurs.</strong><br>
  A modern, high-craft monochrome subscription ledger and renewal tracker for Android.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.47.0-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.13.0-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Target-Android%20Only-3DDC84?logo=android" alt="Android" />
  <img src="https://img.shields.io/badge/Tests-158%20Passing-brightgreen" alt="Tests" />
  <img src="https://img.shields.io/badge/License-MIT-blue" alt="License" />
</p>

---

## Overview

**Subly** is an Android-first subscription manager engineered around financial clarity and visual calm. It provides an interactive dual-view dashboard (Calendar + Ledger) for tracking recurring commitments, calculating per-currency monthly and annual burn rates, scheduling on-device notifications before trial and renewal deadlines, and accessing a curated directory of one-tap cancellation links.

---

## Features

- **Dual-Mode Interactive Dashboard**:
  - **Calendar View**: Interactive month-by-month grid with visual renewal clusters, brand mark badges, density counter caps, and current-day glow.
  - **Ledger View**: Hero spend ring, 7-day upcoming renewal strip, and Quick Filters (`All`, `Renewing Soon`, `Monthly`, `Annual`, `Inactive`).
- **Subscription Lifecycle & Actions**:
  - Full active and canceled state tracking. Inactive items display with strikethrough cost and are excluded from spend calculations and notification schedules.
  - 1-tap quick actions modal: Mark Paid / Advance Cycle (with safe month-end date clamping), Edit, Mark as Canceled / Reactivate, and Delete.
- **Monochrome Dark & Light Design**: Built from a unified token sheet (`lib/core/theme.dart`) with deep obsidian surfaces, warm-white ink, hairline borders, and zero gratuitous shadows.
- **Dynamic Theme Inversion**: The `SublyLogoBadge` dynamically adapts with theme inversion (dark mode: white badge with black "S"; light mode: black badge with white "S").
- **Dual Authentication**:
  - **Continue with Google**: One-tap authentication using Google Identity Services.
  - **Manual Account Creation**: Email/password registration paired with a modern 6-box OTP verification flow powered by Brevo SMTP (with zero-config local Demo Mode fallback).
- **Accurate Date & Burn Calculations**:
  - Weekly, Monthly, and Annual cycles.
  - Safe month-end date clamping (e.g. Jan 31 &rarr; Feb 28/29).
  - Isolated per-currency totals without arbitrary conversions.
- **35+ Curated Presets**: Netflix, Spotify, ChatGPT, Claude, Midjourney, Cursor, Canva, Adobe CC, Prime, and more with official vector marks, brand accent colors, and live category/name search.
- **Local On-Device Reminders**: Exact alarm notifications scheduled via `flutter_local_notifications` 3 days before renewal or trial expiration (no FCM or background server dependencies).
- **Cancellation Directory**: 35-service directory with direct unsubscribe links and instructions, automatically backed by built-in offline fallbacks.
- **Simulated Premium Tier**: Free tier allows up to 5 subscriptions; exceeding the cap directs to the sleek paywall with CSV export capability.

---

## Getting Started

### Prerequisites

Ensure the following are installed on your workstation:

1. **Flutter SDK**: `3.47.0` (Dart `3.13.0` or newer on the `stable` channel).
   ```bash
   flutter --version
   ```
2. **Android SDK & Platform Tools**: Android Studio with Android SDK API 34+ and build tools `36.0.0`.
3. **Java Development Kit**: JDK 17+ (bundled with Android Studio).
4. **Android Device or Emulator**: A physical Android device with USB debugging enabled, or an Android Virtual Device (AVD).

---

### Step-by-Step Guide to Run Subly

#### 1. Clone the Repository

```bash
git clone https://github.com/your-username/subtracker.git
cd subtracker
```

#### 2. Install Flutter Dependencies

```bash
flutter pub get
```

#### 3. Configure Firebase Backend

Subly requires a Firebase project for Authentication and Firestore. 

##### Option A: Using FlutterFire CLI (Recommended)
1. Install the FlutterFire CLI if you haven't already:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Configure your Firebase project for the app:
   ```bash
   flutterfire configure
   ```
   Select your Firebase project and enable the Android platform. This automatically generates `lib/firebase_options.dart` and `android/app/google-services.json`.

##### Option B: Manual Setup from Templates
1. Copy the template files:
   ```bash
   # Windows PowerShell:
   Copy-Item lib/firebase_options.example.dart lib/firebase_options.dart
   Copy-Item android/app/google-services.json.example android/app/google-services.json

   # macOS / Linux:
   cp lib/firebase_options.example.dart lib/firebase_options.dart
   cp android/app/google-services.json.example android/app/google-services.json
   ```
2. Fill in your project keys in `lib/firebase_options.dart` and `android/app/google-services.json`.
3. For Google Sign-In, provide your Web Client ID via compile-time argument:
   ```bash
   flutter run -d android --dart-define=GOOGLE_SERVER_CLIENT_ID="your-web-client-id.apps.googleusercontent.com"
   ```

#### 4. Configure Email Verification (Optional / Recommended)

Subly supports email OTP verification for manual account creation using Brevo (formerly Sendinblue).

1. Copy the example configuration template:
   ```bash
   # Windows PowerShell:
   Copy-Item lib/core/config/email_config.example.dart lib/core/config/email_config.dart

   # macOS / Linux:
   cp lib/core/config/email_config.example.dart lib/core/config/email_config.dart
   ```
2. Open `lib/core/config/email_config.dart` (which is git-ignored) and insert your Brevo API key and sender details:
   ```dart
   class EmailConfig {
     static const String brevoApiKey = 'xkeysib-YOUR-API-KEY';
     static const String brevoSenderEmail = 'your-verified-sender@example.com';
     static const String brevoSenderName = 'Subly';
   }
   ```
   > **Note:** If you do not configure a Brevo API key, Subly automatically operates in **Demo Mode**: OTP codes are logged directly to the debug console (`BrevoService: Demo mode OTP code is: 123456`) so you can test account creation immediately without an external API key.

Alternatively, you can provide the API key at runtime using `--dart-define`:
```bash
flutter run -d android --dart-define=BREVO_API_KEY="your-api-key"
```

#### 5. Launch an Android Emulator

List all configured Android emulators:
```bash
flutter emulators
```

Launch your emulator (for example, `Medium_Phone`):
```bash
flutter emulators --launch Medium_Phone
```

#### 6. Run the Application

Execute on your connected Android device or running emulator:

```bash
flutter run -d android
```

To build a standalone debug APK:
```bash
flutter build apk --debug
# Install to device via ADB:
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## Seeding Cancellation Links (Optional)

The directory of cancellation links is stored in Firestore (`cancellation_links` collection). Because `firestore.rules` makes this collection read-only for clients, seeding is performed via the admin script:

1. In Firebase Console &rarr; **Project Settings** &rarr; **Service Accounts** &rarr; click **Generate new private key**.
2. Save the downloaded JSON file as `scripts/serviceAccountKey.json` (this file is git-ignored).
3. Run the seed script:
   ```bash
   cd scripts
   npm install firebase-admin
   node seed_cancellation_links.js
   cd ..
   ```

---

## Running Tests & Code Quality

Subly maintains comprehensive test coverage across domain logic, repositories, and UI widgets:

```bash
# Run the entire test suite (158 tests)
flutter test

# Run static analysis (zero errors, zero warnings)
flutter analyze

# Regenerate UI visual QA screenshots
flutter test test/design/screenshot_test.dart

# Re-render the launcher app icon from branding SVGs
flutter test test/design/generate_app_icon_test.dart
dart run flutter_launcher_icons
```

---

## Architecture

Subly follows a clean three-layer architecture powered by **Riverpod 3**:

```
lib/
├── main.dart                  # App bootstrap, Firebase initialization & repository overrides
├── firebase_options.dart      # FlutterFire generated platform configurations
├── core/
│   ├── theme.dart             # Central design tokens (SublyColors, SublyTypography, SublyMotion)
│   ├── brand/                 # SublyLogoBadge, SublyMark, and brand color lookup
│   ├── config/                # App configuration (EmailConfig, Brevo API integration)
│   ├── router.dart            # GoRouter configuration & authentication guards
│   └── notifications/         # Local alarm reminder service (flutter_local_notifications)
└── features/
    ├── auth/                  # Google Sign-In, Email/Password, and Brevo 6-digit OTP UI
    ├── subscriptions/         # Dashboard, Calendar/Ledger view, presets catalog, creation form
    ├── directory/             # Cancellation directory & direct URL launcher
    ├── settings/              # Account details, dark/light theme switcher, CSV export
    └── premium/               # Simulated paywall & tier enforcement
```

---

## Security & Best Practices

- `lib/firebase_options.dart` and `android/app/google-services.json` are git-ignored to prevent backend quota/auth pollution. Example templates (`lib/firebase_options.example.dart`, `android/app/google-services.json.example`) are provided.
- `scripts/serviceAccountKey.json` is strictly git-ignored.
- `lib/core/config/email_config.dart` contains private keys and is strictly git-ignored (template: `lib/core/config/email_config.example.dart`).
- `firestore.rules` enforces strict user isolation: users can only read and write their own documents under `users/{uid}/...`.
- Local notification reminders run entirely on-device without remote tracking or push notification servers.

---

## Academic Project Notice & Disclaimer

This project is developed solely as an educational, non-commercial academic assignment:
- **Trademarks & Logos:** All third-party product names, logos, brands, and registered trademarks displayed in this application (such as Netflix, Spotify, Canva, ChatGPT, etc.) are the property of their respective owners. Their inclusion is purely for academic prototyping and identification purposes under educational fair use, and does not imply any affiliation, sponsorship, or endorsement.
- **Simulated Billing:** The premium upgrade flow and pricing tiers shown in the app are simulated software features designed to showcase UI/UX and full-stack entitlement state flows. No real financial transactions or billing occur.
- **Cancellation Directory:** Cancellation links and instructional notes are compiled for general educational reference. Users are responsible for directly verifying cancellation terms with their respective service providers.

---

## Plans & Documentation

- `docs/superpowers/plans/2026-09-06-subly-mvp.md` — MVP architecture plan
- `docs/superpowers/plans/2026-09-06-subly-design.md` — Design system specification
- `AGENTS.md` — Architecture map, design rules, and framework constraints for development

