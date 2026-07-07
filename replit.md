# UP Police HRMS — उत्तर प्रदेश पुलिस कर्मचारी प्रबंधन प्रणाली

Enterprise HR management system for UP Police, Bareilly district. Built with Flutter web.

## Running the app

The workflow **Start application** builds and serves the Flutter web app:

```bash
# One-time: install Flutter dependencies
flutter pub get

# Build the web app (output → build/web/)
flutter build web --release

# Serve on port 5000
python3 serve.py
```

The workflow runs `python3 serve.py` automatically. After any code change, rebuild then restart:

```bash
flutter build web --release && python3 serve.py
```

## Stack

- **Flutter 3.32** — web target, CanvasKit renderer
- **Provider** — state management
- **Google Sheets / Apps Script** — data backend (GAS URL configured in the data source)
- **pdf / printing** — employee profile PDF export

## Key files

| Path | Purpose |
|---|---|
| `lib/main.dart` | App entry point; `SelectionArea` wraps entire app |
| `lib/core/theme/app_theme.dart` | Colors, gradients, `glassContainer()` helper |
| `lib/core/services/gsheet_data_source.dart` | Google Sheets CSV data source |
| `lib/screens/dashboard/dashboard_screen.dart` | Main dashboard |
| `lib/screens/profile/profile_screen.dart` | Employee profile |
| `serve.py` | Python HTTP server for `build/web/` on port 5000 |

## Design

- Glassmorphism: deep navy–blue gradient background, frosted-glass cards via `BackdropFilter`
- All text is selectable / copyable (`SelectionArea` at root)
- Hindi (Devanagari) UI with Noto Sans Devanagari fonts

## User preferences

- Glassy / frosted-glass card style throughout
- All text selectable for copy-paste
