# Plateful

Food ordering app scaffold built with Flutter.

## What this project currently does
- Boots Flutter app with Riverpod `ProviderScope`.
- Initializes Hive local storage.
- Tries Firebase init (fails silently now).
- Uses `go_router` route graph.
- Starts at splash, then redirects to Home.
- Provides tab shell: Home, Orders, Feedback, Profile.
- Includes routes for Login, Restaurant Menu, Cart, Checkout, Feedback Form.
- Most feature screens are placeholders (`TODO`), so this is foundation stage.

## Stack
- Flutter (Dart)
- Riverpod
- go_router
- Hive
- Firebase Core/Auth
- flutter_screenutil

## Project structure
- `lib/main.dart`: app bootstrap + init
- `lib/src/routing/`: route enums, route table, bottom tab shell
- `lib/src/features/`: feature screens
- `lib/src/app/themes/`: theme tokens/styles
- `assets/jsons/`: bundled JSON assets

## Run locally
```bash
flutter pub get
flutter run
```

## Notes
- Firebase init is wrapped in empty catch; errors are ignored.
- App is scaffolded and ready for feature implementation.
