# Project Rules

- Scope lock: build and test only for iOS + Android.
- Web, macOS, Linux, Windows are out-of-scope unless user asks.
- Keep implementation aligned to `.planning/plateful_prd_final.md` and current phase doc.
- Verification default for each phase: run `flutter pub get` then `flutter test`.
- Do not run `flutter build` (APK/IPA/etc.) unless user explicitly asks.
