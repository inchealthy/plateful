# Project Rules

- Scope lock: build and test only for iOS + Android.
- Web, macOS, Linux, Windows are out-of-scope unless user asks.
- Keep implementation aligned to `.planning/plateful_prd_final.md` and current phase doc.
- Verification default for each phase: run `flutter pub get` then `flutter test`.
- Do not run `flutter build` (APK/IPA/etc.) unless user explicitly asks.
- Test runtime sanity: if a test is unusually long/hangs, treat it as broken signal. Find root cause and fix test/app code, don't normalize long-running flaky tests.

# Agent Rules

- If a test takes too long, stop and investigate immediately.
- Prefer deterministic pumps/timeouts and stable assertions; avoid patterns that can settle forever (`pumpAndSettle` loops without guard).
