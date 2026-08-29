# شطبها / Shatbha

RTL ERP for Egyptian finishing and contracting SMEs. Arabic-first, four-tab shell, Atelier visual language.

This repository is the **Flutter app**. The Laravel API lives in a separate repo: [islam-kamal/Shatbha-backend](https://github.com/islam-kamal/Shatbha-backend).

| | |
|---|---|
| Flutter (this repo) | [islam-kamal/Shatbha](https://github.com/islam-kamal/Shatbha) |
| Laravel API | [islam-kamal/Shatbha-backend](https://github.com/islam-kamal/Shatbha-backend) |
| Hosted API | [https://p02--shatbha--9lqgqlp9drrc.code.run](https://p02--shatbha--9lqgqlp9drrc.code.run) |
| Health | `GET /` → `{ "ok": true, "app": "shatbha", "api": "/api/v1" }` |
| Laravel health | `GET /up` |

---

## Table of contents

1. [What the product does](#what-the-product-does)
2. [Two data layers](#two-data-layers)
3. [Demo users and seeded fixtures](#demo-users-and-seeded-fixtures)
4. [Visual language](#visual-language)
5. [Architecture](#architecture)
6. [App start and authentication](#app-start-and-authentication)
7. [Navigation map](#navigation-map)
8. [Finishing pack — live API flows](#finishing-pack--live-api-flows)
9. [Extra packs — in-app demo flows](#extra-packs--in-app-demo-flows)
10. [Offline cache and outbox sync](#offline-cache-and-outbox-sync)
11. [Roles and access](#roles-and-access)
12. [Logging](#logging)
13. [HTTP API](#http-api)
14. [Run the Flutter app](#run-the-flutter-app)
15. [Run the Laravel API locally](#run-the-laravel-api-locally)
16. [Deploy the API](#deploy-the-api)
17. [Build and ship the Flutter app](#build-and-ship-the-flutter-app)
18. [Project layout](#project-layout)

---

## What the product does

Shatbha is a field-and-office ledger for a finishing atelier:

- Keep **customers** (اتفاق / إشراف) and **contractors**.
- Record **customer journal** lines: cash collection, labor (مصنعية), goods, returns.
- Track **office expenses** by category.
- Track **contractor jobs**: qty × unit price, payments, remaining.
- Print-style **statements**, **customer report**, **contractor remaining**, and **income statement** (P&amp;L).
- Work **offline**: reads fall back to SQLite (Drift); writes queue in an outbox and flush from المزيد.

The finishing pack is wired to the API. Extra activity packs (manufacturing, food, aluminum, real estate, carpets, …) are **in-app demo screens** so the product can show those businesses without extra backend tables yet.

---

## Two data layers

| Kind | Storage | Survives restart | Examples |
|---|---|---|---|
| **Live (finishing pack)** | Laravel + Sanctum + company-scoped DB. Flutter caches in Drift. | Yes, on the server. Local cache until next successful fetch. | Login, company name/pack, customers, contractors, work types, expense categories, customer entries, expenses, jobs/payments, reports, P&amp;L |
| **Demo (`ExtraStore`)** | In-memory `ChangeNotifier` in the app | No | Other revenues, supplier journal, items/inventory, production, cubing, units/installments, partners, checks, food/aluminum P&amp;L, print/backup/search UI |

Writes that go through repositories (`JournalRepository`, `ExpenseRepository`, `JobRepository`, `CatalogRepository`) hit `POST /api/v1/...`. If the device is offline they still appear locally and land in `sync_outbox`.

---

## Demo users and seeded fixtures

| Email | Password | Role | Arabic label |
|---|---|---|---|
| `admin@shatbha.test` | `password` | `admin` | مدير — all reports including P&amp;L |
| `clerk@shatbha.test` | `password` | `clerk` | كاتب — `GET /reports/income-statement` returns **403** |

Login fields are prefilled with the admin account.

**Seeded company:** شطبها · أتيليه التشطيبات والمقاولات · pack `finishing`.

| Fixture | Value | How it is computed |
|---|---|---|
| Contractor remaining | **7,000** | Job «محارة فيلا»: qty 100 × 200 = 20,000 − payment 13,000 |
| P&amp;L net | **900** | Supervision cash 1,000 (بدير) − office category «اشتراكات وفواتير» 100 |

Other seed rows: customers خالد (اتفاق, estimate 50,000) and بدير (إشراف 8%); contractor أحمد; work types تأسيس سباكة / تأسيس نقاشة / أرضيات; expense categories اشتراكات وفواتير and إكراميات وبدلات; sample cash and labor entries on خالد.

Seeding is **idempotent**: if `admin@shatbha.test` already exists, the seeder returns without duplicating data.

---

## Visual language

**Atelier** — dark stone chrome with ivory sheets and brass accents.

| Token | Hex | Role |
|---|---|---|
| Stone | `#1C1814` | App chrome, text on ivory |
| Raised | `#2A241E` | Cards on dark backgrounds |
| Ivory | `#F6F1E8` | Sheets, lists, print preview |
| Brass | `#C4A574` | Brand, KPIs, selected tabs |
| Terracotta | `#B85C38` | Expenses, danger, negative amounts |
| Teal | `#4A7C74` | Cash / positive amounts |

Fonts: **IBM Plex Sans Arabic** (UI numbers and body), **Cairo** (wordmark), **Cinzel** (English lockup / VERSION). Locale is `ar` with RTL Material localizations. Bottom navigation order (right → left): **الرئيسية · دفتر · تقارير · المزيد**. Overlay add/pay screens hide the bar (`parentNavigatorKey` root routes).

---

## Architecture

Feature-first: **`core` is shared**, each feature owns its **data**, **injection**, and **presentation**.

```
lib/
  core/          env, Dio, Drift DB, failures, logging, theme, widgets, router
  features/
    auth/
      data/           datasources / models / repositories
      injection.dart  GetIt registrations for this feature
      presentation/
        cubit/        cubit (or bloc) + matching state file
        screens/
    catalog/  journal/  expenses/  jobs/  reports/  company/  extra/  sync/  shell/
```

`core/di/injection.dart` registers storage, Dio, and the database, then calls each feature’s `registerX(sl)`.

**Cubit and state files**

Every feature cubit is two files (auth is a Bloc, so it also has events). The cubit/bloc file **exports** its state so screens keep importing one path.

```
presentation/cubit/
  foo_cubit.dart   # Cubit class; `export 'foo_state.dart'`
  foo_state.dart    # State class
```

| Feature | Files | Types |
|---|---|---|
| auth | `auth_bloc.dart`, `auth_event.dart`, `auth_state.dart` | `AuthBloc` / `AuthEvent` / `AuthState` |
| catalog | `catalog_cubit.dart`, `catalog_state.dart` | `DefinitionsCubit` / `DefinitionsState` |
| journal | `journal_cubit.dart`, `journal_state.dart` | `JournalCubit` / `JournalState` |
| shell | `date_range_cubit.dart`, `date_range_state.dart` | `DateRangeCubit` / `DateRange` |
| sync | `sync_cubit.dart`, `sync_state.dart` | `SyncCubit` / `SyncState` (`pending` count) |

`expenses`, `jobs`, `reports`, `company`, and `extra` have screens only — they call repositories (or `ExtraStore`) from the widget.

`shell` is presentation-only (tabs + date range). `extra` stores demo data in `ExtraStore` (in-memory). Jobs and journal import `Party` from `catalog`.

**How to find code**

| I want to… | Open |
|---|---|
| Change a screen | `lib/features/<feature>/presentation/screens/` |
| Change cubit logic | `lib/features/<feature>/presentation/cubit/*_cubit.dart` (auth: `*_bloc.dart`) |
| Change cubit state | `lib/features/<feature>/presentation/cubit/*_state.dart` |
| Change auth events | `lib/features/auth/presentation/cubit/auth_event.dart` |
| Change API parsing | `lib/features/<feature>/data/datasources/` |
| Change a model | `lib/features/<feature>/data/models/` |
| Change cache / offline enqueue | `lib/features/<feature>/data/repositories/` |
| Register a new class | `lib/features/<feature>/injection.dart` |
| Shared button / KPI / overlay | `lib/core/widgets/` |
| Local tables | `lib/core/database/app_database.dart` |

**Stack**

| Layer | Choice |
|---|---|
| UI | Flutter, Material 3, `go_router` 4-tab `StatefulShellRoute` |
| State | `flutter_bloc` + `equatable` |
| DI | `get_it` — root `setupDependencies()` + per-feature `injection.dart` |
| HTTP | Dio, base URL `${API_BASE_URL}/api/v1`, Bearer from `flutter_secure_storage` |
| Local DB | Drift (`lib/core/database`) shared by feature repositories |
| Logging | `logger` via `AppLog` |

Failures: `OfflineFailure`, `UnauthorizedFailure`, `ForbiddenFailure`, `ServerFailure`, `ValidationFailure`. Dio maps to these in `mapDio`.

---

## App start and authentication

```
main()
  → error hooks + Bloc observer
  → initializeDateFormatting('ar')
  → setupDependencies()   // Drift, Dio, repos
  → ShatbhaApp
       AuthBloc + DateRangeCubit + SyncCubit
       GoRouter (refreshListenable = AuthBloc)

Splash  --AuthStarted-->  restore token from secure storage
                            │
                            ├─ GET /me succeeds → /home
                            ├─ /me fails, cache exists → /home (cached user)
                            └─ no token → /login
```

**Login:** `POST /api/v1/login` `{ email, password }` → Sanctum token stored as key `token`. User + company cached in Drift. Router redirect: guest cannot leave `/login`; authenticated users bouncing on `/login` or `/splash` go to `/home`.

**Logout:** المزيد → تسجيل الخروج → `POST /logout` (best-effort) then delete token → `/login`.

**Session restore while offline:** if `/me` fails but a user row exists in `users_cache`, the app still opens as that user.

**Company update:** `PUT /company` with `name` / `subtitle` / `pack`. `AuthCompanyUpdated` refreshes `AuthAuthenticated` without a full re-login.

---

## Navigation map

### Shell (bottom bar)

| Tab | Route | Screen |
|---|---|---|
| الرئيسية | `/home` | 8 tiles into finishing + reports |
| دفتر | `/ledger` | Ledger hub (live + extra journals) |
| تقارير | `/reports` | Date-range chip + report list |
| المزيد | `/more` | Ops, definitions, system, logout |

### Home tiles

| Tile | Route |
|---|---|
| يومية العملاء | `/journal` |
| التعريفات | `/definitions` |
| مصاريف إدارية | `/expenses` |
| كشف حساب عميل | `/customers/picker` |
| اتفاق مقاولين | `/jobs` |
| تقرير العملاء | `/reports/customers` |
| قائمة الدخل | `/pnl` |
| تقرير المقاولين | `/reports/contractors` |

### Date range

`DateRangeCubit` is global. تقارير shows a chip; picking **من تاريخ** then **إلى تاريخ** filters journal KPIs and P&amp;L query params (`from` / `to` ISO dates).

---

## Finishing pack — live API flows

These screens read and write the Laravel API (with Drift fallback).

### 1. Definitions — `/definitions`

Four tabs: **عملاء · مقاولون · أعمال · بنود**.

| Action | Flow |
|---|---|
| List | `GET /customers`, `/contractors`, `/work-types`, `/expense-categories` |
| Add customer | `/definitions/add-customer` → name, phone, kind **اتفاق** (`agreement`) or **إشراف** (`supervision` + %). `POST /customers` |
| Add contractor | `/definitions/add-contractor` → name, phone. `POST /contractors` |
| Add work type / expense category | Prompt dialog → `POST /work-types` or `POST /expense-categories` |

App-bar shortcuts: الأصناف (`/items`, demo) and إضافة مورد (`/definitions/add-supplier`, demo).

**Party types on the API:** `customer` | `contractor` only. Suppliers are not API parties.

### 2. Customer journal — `/journal`

Loads `GET /customer-entries` with optional `from`, `to`, `customer_id`.

KPIs: cash total, labor total, returns.

**Add entry** `/journal/add`:

1. Pick customer.
2. Type: تحصيل `cash` · مصنعية `labor` · خامات `goods` · مرتجع `return`.
3. Title, amount, date.
4. `POST /customer-entries`. Labor sends `labor_amount`; others send `amount`.
5. Success overlay, then pop.

Offline: enqueue `POST /customer-entries` and keep a local row with a timestamp id.

Empty state: «لا توجد حركات» with قيد جديد.

### 3. Customer statement — picker → `/customers/:id/statement`

1. الرئيسية → كشف حساب عميل → list.
2. Supervision customers show subtitle «عميل إشراف».
3. Statement: opening, sales (amount + labor), collect (cash), returns, closing.
4. Closing formula (API): `opening + sales − collect − returns`.
5. **إضافة قيد** from the statement goes to `/journal/add`.

**Supervision** `/customers/:id/supervision`: fee = cash collected × `supervision_percent / 100`. Seeded بدير is 8%.

### 4. Expenses — `/expenses`

`GET /expenses` → list + period total. Add `/expenses/add`: category, title, amount, date → `POST /expenses`. Offline enqueue same as journal.

**Expense report** `/reports/expenses`: `GET /reports/expenses` grouped by category.

### 5. Contractor jobs — `/jobs`

`GET /jobs` with `total`, `paid`, `remaining`. KPI is sum of remaining (seeded **7,000**).

**Add job** `/jobs/add`: contractor, title, qty, unit price → `POST /jobs`. Total = qty × unit_price.

**Pay** `/jobs/:id/pay`: amount + date → `POST /jobs/:id/payments`. API rejects amount &gt; remaining (422).

**Contractor report** `/reports/contractors`: remaining per contractor.

### 6. Customer report — `/reports/customers`

Per customer: opening, sales, collect, closing. Tap a row → that customer’s statement.

### 7. Income statement (P&amp;L) — `/pnl`

`GET /reports/income-statement?from=&to=` — **admin only**.

| Line | Source |
|---|---|
| تحصيل نسب إشراف | Cash entries whose customer `kind` is `supervision` |
| إجمالي مصاريف مكتبية | Expenses whose category name is `اشتراكات وفواتير` |
| صافي | supervision − office |

Clerk sees a forbidden state (403 mapped to `ForbiddenFailure`). Print icon opens the demo print preview (`/print`).

### 8. Company — `/company`

Loads `GET /company`. Saves Arabic name + English subtitle via `PUT /company`. Phones/addresses/logo are UI-only until the API grows those fields.

### 9. Activity pack — `/packs`

Choose: finishing, manufacturing, food, wood, aluminum, realestate, carpets. Persist `pack` on the company. Does not hide/show routes yet; extra screens stay reachable from دفتر / تقارير / المزيد.

---

## Extra packs — in-app demo flows

Unless noted, data is `ExtraStore` or hardcoded. Adds update memory until the process is killed.

### Ledger hub (`/ledger`)

| Row | Route | Notes |
|---|---|---|
| يومية العملاء | `/journal` | **Live** |
| مصاريف إدارية | `/expenses` | **Live** |
| إيرادات أخرى | `/revenues` | Seed: بيع خردة ألوميتال 2,500. Add `/revenues/add` |
| يومية الموردين | `/suppliers/journal` | شراء / سداد / مرتجع. Add `/suppliers/journal/add` |
| يومية مجمعة | `/general-journal` | Combined demo journal; «قيد جديد» opens **live** `/journal/add` |
| اتفاق مقاولين | `/jobs` | **Live** |
| تقرير العهد | `/petty-cash` | Fixed KPIs 5,000 / 3,200 / 1,800, progress for عهدة موقع فيلا |
| سحب خامات | `/inventory/out` | Add `/inventory/out/add` |
| تسجيل إنتاج | `/production` | Add `/production/add` |
| يومية الشركاء | `/partners/journal` | Add `/partners/journal/add` |
| أعمال مقاولات | `/contracting` | Demo projects → `/cubing`; «مشروع جديد» is **live** `/jobs/add` |

### Reports hub (beyond live P&amp;L / customers / contractors / expenses)

| Report | Route | Demo content |
|---|---|---|
| تقرير المبيعات | `/reports/sales` | Invoices, totals |
| تقرير الموردين | `/reports/suppliers` | Supplier balances |
| تقرير المخزون | `/reports/inventory` | Same as `/inventory` — items from ExtraStore |
| الميزانية العمومية | `/balance-sheet` | Assets / equity layout |
| تقرير الشركاء | `/reports/partners` | 60/40 split, capital 2,000,000 |
| تقرير الأقساط | `/reports/installments` | Due / collected / late; tap → collect |

### Cubing / BOQ — `/cubing`

Lines: نقاشة، جبس، ألوميتال، كهرباء. KPIs 420 م² and 50,000. PDF opens `/print`. Add line `/cubing/add` (no persist).

### Items — `/items`

ExtraStore SKUs (تام + خامة ألوميتال). Add `/items/add`. Work types list `/work-types` can also create **live** work types via catalog.

### Real estate — `/units`

Units 101-ب, 102-ب, 201-ج with progress bars. Detail `/units/:code` → تحصيل قسط `/units/:code/collect` (cash vs other, success overlay).

### Partners — `/partners`, `/partners/agreement`

Agreement pie 60/40, save overlay. Journal as above.

### Manufacturing / food / aluminum

| Screen | Route |
|---|---|
| عملاء التصنيع | `/manufacturing/customers` |
| قائمة الدخل — غذائي | `/pnl/food` (net 99,000) |
| قائمة الدخل — ألوميتال | `/pnl/aluminum` (ALU MAS, net 900) |

### Operations (المزيد)

| Screen | Route | Behavior |
|---|---|---|
| بحث | `/search` | Filters demo hits (customers / agreements / installments) |
| طباعة | `/print` | Preview P&amp;L 1,000 − 100 = 900; Print / PDF / Excel overlays |
| مزامنة الصندوق الصادر | — | **Live** `SyncCubit.flush()` — see [Offline](#offline-cache-and-outbox-sync) |
| نسخ احتياطي | `/backup` | Simulated backup/restore; restore does not wipe Drift |
| شيكات | `/checks` | Demo cheque register |
| الأصول الثابتة | `/fixed-assets` | Cost / depreciation / net |

---

## Offline cache and outbox sync

On network/API failure, repositories:

1. **Read:** return Drift cache (parties, entries, expenses, jobs, company, user).
2. **Write (create entry / expense / job):** insert a local row **and** `enqueue(method, path, json body)` into `sync_outbox` (`status = pending`).

**Flush:** المزيد → مزامنة الصندوق الصادر.

- Subtitle shows pending count (`SyncCubit`).
- Replay each pending row with the original method/path/body via Dio.
- Success → `synced`. Failure → `failed` (logged; not retried until another flush).
- SnackBar: «لا شيء للمزامنة» or «تم رفع N قيد».

Paths replayed today: `/customer-entries`, `/expenses`, `/jobs` (and payments if queued). Token is attached like any other request.

---

## Roles and access

| Capability | admin | clerk |
|---|---|---|
| Login, journals, expenses, jobs, statements, definitions | Yes | Yes |
| Customer / contractor / expense reports | Yes | Yes |
| Income statement API + `/pnl` | Yes | **403** — UI forbidden state |

Sanctum: all routes except `POST /login` and `GET /db-status` require `Authorization: Bearer`. Company id is taken from the authenticated user; there is no cross-company access.

---

## Logging

Package `logger` via `lib/core/logging/app_log.dart`.

| Mode | Level |
|---|---|
| Debug | trace and up, pretty printer, emojis |
| Release | warning and up |

| Tag | What |
|---|---|
| `http` | Method, URI, status, duration; headers/body **redacted** (`password`, `token`, `Authorization`, …) |
| `bloc` | create, event, change, transition, error, close |
| `nav` | push/pop/replace, go_router redirects |
| `auth` / `sync` / `journal` / … | Domain |
| `flutter` | `FlutterError`, `PlatformDispatcher`, `ErrorWidget` |

`AuthLoginRequested.toString()` omits the password. Never log the Sanctum token.

---

## HTTP API

Base path: `{API_BASE_URL}/api/v1`. JSON `Accept: application/json`.

### Public

| Method | Path | Notes |
|---|---|---|
| POST | `/login` | Body `email`, `password` → `{ token, user }` |
| GET | `/db-status` | Ops / DB probe |
| GET | `/` (web, not under `/api/v1`) | `{ ok, app, api }` |
| GET | `/up` | Laravel health |

### Authenticated

| Method | Path |
|---|---|
| POST | `/logout` |
| GET | `/me` |
| GET / PUT | `/company` |
| GET / POST | `/customers`, `/contractors` |
| GET / POST / PUT / DELETE | `/parties` |
| GET / POST | `/work-types`, `/expense-categories` |
| GET / POST | `/customer-entries` |
| GET | `/customers/{id}/statement` |
| GET / POST | `/expenses` |
| GET | `/reports/expenses` |
| GET / POST | `/jobs` |
| POST | `/jobs/{id}/payments` |
| GET | `/reports/customers` |
| GET | `/reports/contractors` |
| GET | `/reports/income-statement` (`admin` middleware) |

Query dates: `from`, `to` as `YYYY-MM-DD`.

---

## Run the Flutter app

Requires a Flutter SDK (use [FVM](https://fvm.app) if the machine pins a version). Drift generated file: `lib/core/database/app_database.g.dart`.

```bash
fvm flutter pub get
# only if app_database.g.dart is missing or tables changed:
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter run
```

Default API is Northflank (`lib/core/config/env.dart`). **Full restart** after changing `--dart-define` (hot reload does not pick it up).

```bash
# Local Laravel (iOS / macOS / desktop / Chrome)
fvm flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000

# Android emulator (host loopback is 10.0.2.2)
fvm flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

| Target | `API_BASE_URL` |
|---|---|
| Northflank (default) | `https://p02--shatbha--9lqgqlp9drrc.code.run` |
| iOS / macOS / desktop / Chrome (local) | `http://127.0.0.1:8000` |
| Android emulator (local) | `http://10.0.2.2:8000` |
| Physical phone vs LAN API | `http://<your-lan-ip>:8000` |

If Android is pointed at `127.0.0.1`, the app logs a warning at boot.

Analyze: `fvm flutter analyze lib`.

---

## Run the Laravel API locally

Clone [Shatbha-backend](https://github.com/islam-kamal/Shatbha-backend). PHP 8.2+ (Docker image uses **8.4**) and Composer.

**SQLite (default)**

```bash
composer install
touch database/database.sqlite
cp .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve --host=127.0.0.1 --port=8000
```

API root: `http://127.0.0.1:8000/api/v1`.

```bash
curl -s -X POST http://127.0.0.1:8000/api/v1/login \
  -H 'Accept: application/json' \
  -d 'email=admin@shatbha.test&password=password'
```

**Optional MySQL** (`docker-compose.yml` in the backend repo):

```bash
docker compose up -d mysql
# .env: DB_CONNECTION=mysql, DB_DATABASE=shatbha, DB_USERNAME=shatbha, DB_PASSWORD=secret
php artisan migrate:fresh --seed
```

Tests: `php artisan test`.

---

## Deploy the API

The Flutter app does not deploy a server. Point `API_BASE_URL` at whatever host serves Laravel.

### Current: Northflank + Neon Postgres

Hosted URL above. Pattern:

1. Push `Shatbha-backend` to GitHub.
2. [Northflank Sandbox](https://app.northflank.com) → Combined service → Dockerfile `./Dockerfile`.
3. Public HTTP **port 80**.
4. Environment:

```
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:…          # php artisan key:generate --show
APP_URL=https://YOUR-SERVICE.code.run
LOG_CHANNEL=stderr
DB_CONNECTION=pgsql
DATABASE_URL=postgresql://USER:PASS@HOST/neondb?sslmode=require
DB_URL=${DATABASE_URL}
SESSION_DRIVER=database
CACHE_STORE=database
QUEUE_CONNECTION=sync
```

Use Neon’s **direct** URI (not the pooler) if migrations hang. After first deploy, set `APP_URL` to the `*.code.run` URL and redeploy.

Container start (`scripts/00-laravel-deploy.sh`): write `.env`, `migrate --force`, `db:seed --force` (no-op if admin exists), then Apache.

Neon may sleep when idle; the first request after that can take ~30s.

### Render (blueprint)

`render.yaml` at the **backend repo root**: Docker web service + Postgres. Health `/up`. Set `APP_KEY` in the dashboard. Free web sleeps after idle; free Postgres expires on a timer — upgrade for production.

### Docker locally

From the backend repo:

```bash
docker build -t shatbha-api .
docker run --rm -p 8080:80 \
  -e APP_KEY=base64:… \
  -e APP_URL=http://127.0.0.1:8080 \
  -e DATABASE_URL=postgresql://… \
  shatbha-api
```

Then `--dart-define=API_BASE_URL=http://127.0.0.1:8080`.

---

## Build and ship the Flutter app

```bash
fvm flutter build apk --release \
  --dart-define=API_BASE_URL=https://p02--shatbha--9lqgqlp9drrc.code.run

fvm flutter build ios --release \
  --dart-define=API_BASE_URL=https://p02--shatbha--9lqgqlp9drrc.code.run

fvm flutter build macos --release \
  --dart-define=API_BASE_URL=https://p02--shatbha--9lqgqlp9drrc.code.run

fvm flutter build web --release \
  --dart-define=API_BASE_URL=https://p02--shatbha--9lqgqlp9drrc.code.run
```

Omit `--dart-define` to keep the default in `env.dart`. Do not bake a localhost URL into a store build.

iOS/macOS: `flutter_secure_storage` does not yet support Swift Package Manager; that is a plugin warning, not an app bug.

---

## Project layout

```
lib/
  main.dart
  app.dart                     AuthBloc + DateRangeCubit + SyncCubit
  core/
    config/env.dart
    database/app_database.dart
    di/injection.dart          storage, Dio, DB, then registerAuth, …
    error/  logging/  network/  utils/
    theme/  widgets/  routing/  observers/
  features/
    auth/
      data/datasources|models|repositories
      injection.dart
      presentation/
        cubit/                auth_bloc + auth_event + auth_state
        screens/
    catalog/                  catalog_cubit + catalog_state
    journal/                  journal_cubit + journal_state
    expenses/  jobs/  reports/ company/   screens + data, no cubit
    extra/                    ExtraStore + screens + widgets/kit
    sync/                     sync_cubit + sync_state
    shell/                    date_range_cubit + date_range_state
```

Backend (other repo): Laravel 12, Sanctum, `apiPrefix` `api/v1`, `EnsureAdmin` on income statement, Docker PHP 8.4 + Apache, deploy script + Neon/`DATABASE_URL`.
