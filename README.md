# Subly (working title)

An Android subscription tracker built with Flutter + Firebase: a dashboard of
manual-entry subscriptions with monthly/annual spend totals, on-device
reminders before renewals and free-trial end dates, a seeded directory of
cancellation links, and a simulated premium tier (unlimited subscriptions +
CSV export).

## Setup

```bash
flutter pub get
flutterfire configure --project=subly-dev --platforms=android   # already generated; re-run to refresh
flutter test        # full test suite (fake Cloud Firestore, no emulator needed)
flutter run -d android
```

Seed the cancellation directory (writes are blocked for clients by
firestore.rules, so seeding runs server-side):

1. Firebase console -> Project settings -> Service accounts -> Generate new
   private key -> save as `scripts/serviceAccountKey.json` (git-ignored).
2. `cd scripts && npm install firebase-admin && node seed_cancellation_links.js`

## Demo checklist

1. Fresh install -> sign-in wall -> Google Sign-In -> empty dashboard.
2. Add subscriptions; the 6th is blocked by the free limit -> paywall ->
   choose Monthly -> the 6th saves.
3. Add a subscription with a free trial; reminder fires before the trial ends.
4. Dashboard shows per-currency monthly/annual totals.
5. Directory (link icon) lists cancellation pages; tapping opens the browser.
6. Settings -> CSV export copies to clipboard; Sign out returns to the wall.
7. Cross-user Firestore access is rejected by security rules.

## Plans & docs

- `docs/superpowers/plans/2026-09-06-subly-mvp.md` — architecture phase (this build)
- `docs/superpowers/plans/2026-09-06-subly-design.md` — design phase (next)
