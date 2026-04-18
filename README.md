# Pokédex 

A Flutter app that connects to the Pokédex FastAPI backend, featuring a Pokémon grid, search, user authentication, and favorites.

>  **The backend must be running before launching the app.** Follow the README.md on the repo [pokedex_backend](https://github.com/jam-bri/pokedex_backend) first.

# Setup Guide


## Prerequisites

- **Flutter SDK** — [flutter.dev/docs/get-started/install](https://docs.flutter.dev/get-started/install)
- **Dart** (included with Flutter)
- A device or emulator to run the app on:
  - Chrome (web)
  - Android emulator (via Android Studio)
  - iOS simulator (macOS only, via Xcode)
  - Physical device

---

## Step 1 — Clone the project

```bash
git clone <https://github.com/jam-bri/pokedex>
cd <pokedex>
```

---

## Step 2 — Install Flutter dependencies

```bash
flutter pub get
```

---

## Step 3 — Configure the backend URL

Open `lib/services/auth.dart` and find this line near the top:

```dart
const String baseUrl = 'http://localhost:8000';
```

Update it depending on where you're running the app:

| Platform | URL to use |
|----------|------------|
| Chrome / Web | `http://localhost:8000`  (default, no change needed) |
| Android emulator | `http://10.0.2.2:8000` |
| iOS simulator | `http://localhost:8000`  (no change needed) |
| Physical device | `http://<your-computer-local-IP>:8000` |

>  To find your computer's local IP:
> - **macOS/Linux**: run `ifconfig` in a terminal and look for `inet` under your Wi-Fi interface
> - **Windows**: run `ipconfig` and look for `IPv4 Address`
>
> Example: `http://192.168.1.42:8000`

---

## Step 4 — Run the app

Make sure your backend is running (`uvicorn main:app --reload`), then:

```bash
flutter run
```

Flutter will ask you to pick a target device if multiple are available. You can also target one directly:

```bash
flutter run -d chrome        # Run in browser
flutter run -d emulator-5554 # Run on Android emulator (check name with: flutter devices)
```

---

## Project Structure

```
lib/
├── main.dart    # App entry point, Provider setup, routes
├── menu.dart        # Home page — Pokémon grid, search, favorites
├── services/
│   └── auth.dart  # API service: auth, Pokémon, favorites
└── screens/
    ├── signin.dart  # Sign in screen
    └── register.dart   # Register screen
```

---

## Features

- Browse all 151 original Pokémon in a scrollable grid
- Search by name or Pokédex ID
- Add/remove favorites (requires login)
- Register and sign in as a Trainer
- Auth token stored in memory for the session

---

## Common Issues

**App shows "Cannot connect to server"**  
→ Make sure the backend is running (`uvicorn main:app --reload`).  
→ Double-check the `baseUrl` in `auth.dart` matches your platform (see Step 3).  
→ On a physical device, make sure your phone and computer are on the same Wi-Fi network.

**Android emulator can't reach the backend**  
→ Use `http://10.0.2.2:8000` instead of `localhost` — Android emulators treat `10.0.2.2` as the host machine.

**`flutter pub get` fails**  
→ Make sure your Flutter SDK is up to date: `flutter upgrade`

**SVG images don't load**  
→ The app uses `flutter_svg` to display Pokémon sprites. Make sure it's listed in `pubspec.yaml` and that `flutter pub get` ran successfully.

**Favorites don't persist after closing the app**  
→ This is expected — the auth token is stored in memory only. You'll need to sign in again after restarting the app. Favorites themselves are saved in the database and will reappear after logging back in.
