# شطبة / Shatbha

RTL finishing-pack ERP Flutter app (BLoC, Drift, Atelier theme).

The Laravel API lives in a separate repo: [islam-kamal/Shatbha-backend](https://github.com/islam-kamal/Shatbha-backend).

## Demo users

| Email | Password | Role |
|---|---|---|
| `admin@shatbha.test` | `password` | مدير — full access including P&L |
| `clerk@shatbha.test` | `password` | كاتب — income statement returns **403** |

Seeded fixtures (on the API): contractor remaining **7,000**; P&L net **900**.

## Flutter app

Use FVM (`fvm flutter`) if the repo is pinned.

```bash
fvm flutter pub get
fvm dart run build_runner build   # Drift codegen if app_database.g.dart is missing
fvm flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

| Target | `API_BASE_URL` |
|---|---|
| iOS / macOS / desktop / Chrome | `http://127.0.0.1:8000` |
| Android emulator | `http://10.0.2.2:8000` |
| Hosted API | `https://YOUR-SERVICE.onrender.com` |

Bottom navigation (RTL, right → left): **الرئيسية · دفتر · تقارير · المزيد**. Add/pay sheets hide the bar.

Offline: writes go to Drift and a sync outbox (`المزيد` → مزامنة الصندوق الصادر).

## Backend

Clone and run the API from [Shatbha-backend](https://github.com/islam-kamal/Shatbha-backend), then start this app against `http://127.0.0.1:8000`.
