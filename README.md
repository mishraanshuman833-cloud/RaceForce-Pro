# RaceForce Pro 🏃

**Version 1.0** — Your official exam running companion.

> Train Smart. Run Fast. Clear the Cut-Off.

---

## Features (v1.0)

| Feature | Description |
|---|---|
| 🌍 Live GPS Tracking | Real-time route, distance, and speed via device GPS |
| ⏱ Live Run Metrics | Timer, current speed, avg speed, current pace, avg pace |
| 🔥 Estimated Calories | MET-formula calorie estimate (clearly labelled) |
| 👟 Step Counter | Live steps if device supports pedometer sensor |
| 🎙 Voice Coach | Start, halfway, 30-sec, and finish audio alerts |
| 🏅 Official Standards | SSC GD, UP Police, Delhi Police, CISF, CRPF |
| 📋 Run History | Every completed run saved locally with full stats |
| 👤 Profile | Name, age, height, weight, gender, target exam |
| ⚙️ Settings | Theme (Light/Dark/System), Voice on/off, Units (km/miles) |
| 🌙 Light & Dark Mode | Premium Material Design 3 UI |

---

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── services/        # GPS, step counter, voice coach
│   ├── theme/           # Light + dark Material 3 theme
│   └── utils/           # Formatting + calculation helpers
├── data/
│   ├── datasources/     # SQLite database helper
│   ├── models/          # Run, Profile, Standard models
│   └── repositories/    # Run, Profile, Settings, Standards repos
├── features/
│   ├── splash/          # Animated splash screen
│   ├── home/            # Dashboard + bottom nav
│   ├── run/             # Live GPS run tracking + summary
│   ├── history/         # Run history list + detail
│   ├── standards/       # Official exam running standards
│   ├── profile/         # User profile view + edit
│   ├── settings/        # App settings
│   └── about/           # About screen + credits
├── providers/           # ChangeNotifier state (run, profile, settings)
└── main.dart
assets/
├── data/
│   └── running_standards.json   # ← Update this to add/change standards
└── fonts/
```

---

## Setup Instructions

### 1. Prerequisites
- Flutter SDK ≥ 3.0.0
- Android Studio / VS Code
- Android device or emulator (API 24+)

### 2. Clone and Install

```bash
git clone <your-repo>
cd raceforce_pro
flutter pub get
```

### 3. Fonts
Download and place these fonts in `assets/fonts/`:
- `Rajdhani-Regular.ttf`
- `Rajdhani-Medium.ttf`
- `Rajdhani-SemiBold.ttf`
- `Rajdhani-Bold.ttf`

Download from: https://fonts.google.com/specimen/Rajdhani

### 4. Google Maps API Key (optional for route display)
Replace `YOUR_GOOGLE_MAPS_API_KEY` in `AndroidManifest.xml` with your key from
https://console.cloud.google.com/

If you don't need map display, the app works fully without it — GPS tracking
still functions.

### 5. Run

```bash
flutter run
```

---

## Updating Running Standards

All exam standards live in a **single JSON file**:

```
assets/data/running_standards.json
```

To add a new exam or update a time standard, edit only that file — no Dart
code changes needed. The app reads it at runtime and caches it in memory.

---

## Permissions Required

| Permission | Why |
|---|---|
| `ACCESS_FINE_LOCATION` | Live GPS tracking |
| `ACTIVITY_RECOGNITION` | Step counter sensor |
| `FOREGROUND_SERVICE` | GPS tracking while screen is active |
| `WAKE_LOCK` | Prevent screen from sleeping mid-run |
| `POST_NOTIFICATIONS` | Run reminders (optional) |

---

## Calorie Disclaimer

Calorie values are **estimates** using the MET (Metabolic Equivalent of Task)
formula based on your weight and average running speed. Actual values vary
by terrain, fitness level, and individual physiology. Always labelled "est."
in the UI.

---

## Developer

**Anshuman Mishra**
contact@anshumanmishra.dev

---

## License

© 2024 Anshuman Mishra. All rights reserved.
