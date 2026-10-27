# Dovix AI Call Center (Flutter)

A calling and CRM app built in Flutter for Android, iOS and the web.

> **There is no backend yet.** All data comes from `lib/data/mock_data.dart` and is kept in memory by
> `lib/store/app_store.dart`. Changes reset when the app restarts. Calls are simulated in the app.

## Run

Flutter is installed at `D:\src\flutter` but is not on PATH. Either add `D:\src\flutter\bin` to PATH or use the full path:

```bash
flutter pub get
flutter run                 # on a connected Android phone or emulator
flutter run -d chrome       # in the browser
flutter test                # widget tests
```

Sign in with any valid email or 10-digit mobile number and a password of at least 4 characters.

## Screens

| Design                 | File                                                                   |
| ---------------------- | ---------------------------------------------------------------------- |
| 1. Splash              | `lib/screens/splash_screen.dart`                                       |
| 2. Login               | `lib/screens/login_screen.dart`                                        |
| 3. Dashboard           | `lib/screens/home_screen.dart`                                         |
| 4. Leads list          | `lib/screens/leads_screen.dart`                                        |
| 5. Lead details        | `lib/screens/lead_details_screen.dart`                                 |
| 6. Ongoing call        | `lib/screens/call_screen.dart`                                         |
| 7. Call log            | `lib/screens/call_log_screen.dart`                                     |
| 8. Add new lead        | `lib/screens/add_lead_screen.dart`                                     |
| 9. Contacts            | `lib/screens/contacts_screen.dart`                                     |
| 10. Campaigns          | `lib/screens/campaigns_screen.dart`                                    |
| 11. Tasks              | `lib/screens/tasks_screen.dart`                                        |
| 12. Reports            | `lib/screens/reports_screen.dart`                                      |
| 13. Profile & settings | `lib/screens/profile_screen.dart`, `lib/screens/settings_screen.dart`  |
| Bottom nav + dialer    | `lib/screens/main_shell.dart`, `lib/screens/dialer_screen.dart`        |

## Icons and logo

- **Icons:** all icons come from the Dovix icon library in `assets/icons/*.svg`.
  Each is a 24px grid with 2px rounded strokes, named as on the icon sheet (`phone_end`, `lead_star`, `autodialer`, …).
  Use them with `AppIcon(AppIcons.phoneEnd, color: …)` from `lib/widgets/app_icon.dart`.
  To change an icon's look, replace its SVG file and keep the same name.
- **Logo:** `assets/images/dovix_logo.jpeg` is the Dovix AI logo from `attendance_app`.
  `dovix_logo.png` is a transparent cut-out of it, used inside the app.
  Launcher icons are generated from the JPEG with `dart run flutter_launcher_icons`.

## Connecting a backend later

Screens read state with `AppScope.of(context)` and change it with `AppScope.read(context)`.
Both go through `AppStore` in `lib/store/app_store.dart`.
To connect an API, replace the store's seed data and methods with API calls.
For real calling, replace `startCall` in `lib/utils/actions.dart` and the simulated connection in
`lib/screens/call_screen.dart` with your telephony SDK.
