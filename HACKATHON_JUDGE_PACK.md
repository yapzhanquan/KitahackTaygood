# Hackathon Judge Pack (Items 1, 3, 4)

## 1) AI Feature (Implemented)
- Feature: `AI Portfolio Summary` in the `Insights` tab.
- What it does:
  - Uses Google Gemini (`gemini-1.5-flash`) to summarize portfolio health, risks, and immediate actions.
  - Falls back to a local heuristic summary if Gemini key is missing or request fails.
- Code:
  - `lib/services/ai_insight_service.dart`
  - `lib/screens/main_page.dart` (Insights section + Generate button)

### Run with Gemini
```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

## 3) Success Metrics & Scalability (Implemented + Pitch-ready)
- Added measurable metrics in-app under `Impact Metrics`:
  - `Total Check-ins`
  - `Avg Check-ins/Project`
  - `Stalled+Slowing Rate`
  - `High Confidence Rate`
- These metrics are visible in the `Insights` tab and can be used directly in demo narration.

### Suggested scoring narrative
- Impact KPI: reduce stalled/slowing rate over time.
- Data quality KPI: increase high-confidence rate and check-in coverage.
- Engagement KPI: increase average check-ins per project.

### Scalability roadmap (judge-friendly)
1. District rollout: onboard 3 municipalities with moderator accounts.
2. Data quality controls: duplicate check-in detection + role-based verification.
3. Operational scale: scheduled summaries and alert routing to agencies.

## 4) Live Demo in Firebase Mode (Implemented path)
- App config now supports runtime mode switching via `--dart-define`.
- No source edits needed to switch between mock and Firebase.

### Required setup
1. Run `flutterfire configure` to generate real `firebase_options.dart`.
2. Add platform files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist` (if demoing iOS)
3. Enable Firebase Auth (Google provider), Firestore, Storage.
4. Ensure Firestore/Storage rules are deployed.

### Run commands
```bash
# Firebase live mode
flutter run --dart-define=DATA_MODE=firebase

# Firebase emulator mode
flutter run --dart-define=DATA_MODE=firebase --dart-define=USE_EMULATORS=true

# Optional map enable
flutter run --dart-define=DATA_MODE=firebase --dart-define=GOOGLE_MAPS_ENABLED=true
```

### Demo script (60-90 seconds)
1. Open `Insights` and generate AI summary.
2. Point to impact metrics and explain KPI targets.
3. Add a real check-in and show metrics/status update live.
