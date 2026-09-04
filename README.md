# شطبها / Shatbha

**أتيليه التشطيبات والمقاولات** — Arabic-first, RTL mobile ERP for Egyptian finishing and contracting SMEs.

This repository is the **Flutter app**. The Laravel API lives separately:

| | |
| --- | --- |
| Flutter (this repo) | [islam-kamal/Shatbha](https://github.com/islam-kamal/Shatbha) |
| Laravel API | [islam-kamal/Shatbha-backend](https://github.com/islam-kamal/Shatbha-backend) |
| Hosted API | [https://p02--shatbha--9lqgqlp9drrc.code.run](https://p02--shatbha--9lqgqlp9drrc.code.run) |
| Health | `GET /` → `{ "ok": true, "app": "shatbha", "api": "/api/v1" }` |

**Local run (emulator / USB / adb):** see **[RUN.md](RUN.md)**.

---

## Table of contents

1. [Product idea](#1-product-idea)
2. [Who uses the app](#2-who-uses-the-app)
3. [Core business concepts](#3-core-business-concepts)
4. [Feature modules](#4-feature-modules)
5. [End-to-end flows and scenarios](#5-end-to-end-flows-and-scenarios)
6. [Business rules (important)](#6-business-rules-important)
7. [Tech stack and architecture](#7-tech-stack-and-architecture)
8. [Navigation map](#8-navigation-map)
9. [Demo users](#9-demo-users)
10. [Project layout](#10-project-layout)
11. [Related docs](#11-related-docs)

---

## 1. Product idea

Finishing ateliers in Egypt typically juggle:

- Homeowners (عملاء) and their payments / supervision agreements
- Contractors and suppliers (مقاولون / موردون)
- Project design packages (moodboard, plans, BOQ) that need client sign-off
- Site execution, materials, procurement, warehouse, and handover
- Day-to-day cash journal, expenses, jobs, and reports

**شطبها** unifies that into one Arabic RTL app with three sides of the same business:

| Side | Who | Goal |
| --- | --- | --- |
| **Company** | Admin / clerk of the finishing office | Run CRM, ledger, projects, design, procurement, reports |
| **Vendor** | Contractor or supplier with a login | Respond to quotes, manage portfolio/products, work on assigned projects |
| **Client** | Homeowner linked to a customer party | Follow their projects, approve design, see handover docs |

One login screen tries company → vendor → client credentials in order, so each persona uses the same app binary with role-gated navigation.

Visual language (“Atelier”): dark stone chrome, brass accents, cream **IvorySheet** content panels, Arabic typography (IBM Plex Sans Arabic / Cairo).

---

## 2. Who uses the app

### Company — admin / clerk

- Full shell: **الرئيسية · دفتر · تقارير · المزيد**
- Manages customers & contractors (parties), projects, design packages, quotes, materials, POs, warehouse, PM tasks, handover, journal, expenses, jobs, company profile
- **Admin** can access income statement / P&L; **clerk** shares most company screens but not admin-only reports
- Seeded examples: `admin@shatbha.test` / `clerk@shatbha.test` (password typically `password` in local seed)

### Vendor — contractor / supplier

- Shell: **الرئيسية · المزيد** (no company ledger/reports)
- **Contractor:** quote inbox, respond to RFQs, vendor project workspace, portfolio
- **Supplier:** product catalog management, profile
- Account created by self-registration **or** when the company adds a contractor party with an email (credentials emailed)

### Client — homeowner

- Client home with projects / updates / documents
- Sees only projects linked to their **customer party**
- Approves or rejects submitted design packages; can open attachments (images/PDF)
- Participates in project requests; can sign handover where enabled
- Account created when the company adds/invites a **customer** with email

---

## 3. Core business concepts

### Party vs login account

| Concept | Meaning |
| --- | --- |
| **Party (`parties`)** | CRM record: `customer` or `contractor` under a `company_id` (name, phone, kind, balances…) |
| **ClientAccount** | Login for a homeowner, linked to a customer party (`party_id`) |
| **VendorAccount** | Login for a contractor/supplier; company-created contractors also link via `party_id` |

Creating a party with an **email** provisions the matching login and emails a temporary password. The party list shows email + “حساب دخول” when a login exists.

### Customer kinds

- **اتفاق (agreement)** — classic finishing agreement customer
- **إشراف (supervision)** — supervision % on collections (used in statements / supervision screens)

### Project

A finishing job site owned by the company, optionally linked to a **customer** (`customer_id`). Linking a customer (who has a client login) is what makes the project appear in the client app and allows design submission / notifications to that client.

### Design package lifecycle

```
draft → pending (submitted to client) → approved | rejected
```

Company builds inspiration + plans + BOQ, then **إرسال للعميل**. Client reviews and approves or rejects with a reason. Rejection returns the package to editable company workflow for resubmit.

### Collaboration

- **Project members** — company users, vendors, and/or client account on the project
- **Project requests** — structured asks (e.g. design approval, vendor responses) with comments and approve/reject

### Marketplace quotes

Company requests a quote from a marketplace contractor for a project; contractor responds; company accepts or rejects. Accepted work can feed contractor jobs / project linkage.

---

## 4. Feature modules

| Module | What it does |
| --- | --- |
| **Auth** | Splash, unified login, token restore (`/me`, `/client/me`), logout, role-aware redirects |
| **Shell** | Bottom nav, home grids per role, ledger hub, reports hub, more menu, date range for reports |
| **Catalog / parties** | Clients & contractors CRM (list/add/edit/delete), work types, expense categories; login provisioning on create |
| **Journal / ledger** | Customer journal entries, statements, pickers; hub also reaches supplier/general journals (atelier extras) |
| **Projects** | List/create/detail; customer required on create; hub to design, team, requests, materials, PM, procurement, warehouse, handover |
| **Design** | Moodboard/inspiration by room, plans (image/PDF), BOQ; submit to client; plan-level review comments |
| **Client workspace** | Client projects, design approval UI, attachment view/download, client-side requests |
| **Contractors marketplace** | Browse contractors, request quote, quote list/detail/respond/accept/reject |
| **Vendors** | Vendor directory & profiles; contractor/supplier portfolio or products (vendor-managed) |
| **Materials** | Supplier catalog, project material lines, generate PO from materials |
| **Procurement** | Purchase orders: create, approve, receive goods |
| **Warehouse** | Warehouses, stock levels, issue to project, transfers |
| **Project manager** | Tasks, milestones, timeline, budget lines |
| **Handover** | Delivery milestones, snags, checklists, sign-offs; client sign-off; mark handed over |
| **Notifications** | In-app inbox, unread badge, FCM + local notifications, deep links |
| **Reports** | Customers, contractors, expenses, sales, suppliers, inventory, partners, installments, P&L |
| **Expenses / jobs** | Office expenses by category; contractor jobs and payments |
| **Company** | Company profile settings |
| **Media** | Upload, attach picker, fullscreen image viewer, PDF download/open |
| **Sync** | Drift SQLite cache + **outbox** for offline writes (flush from المزيد) |
| **Extra packs** | Demo/atelier screens: production, units/installments, partners, checks, packs, backup, search, print, etc. |

---

## 5. End-to-end flows and scenarios

### Scenario A — Onboard a client who can log in

1. Company → **العملاء** → **عميل جديد**.
2. Enter name + **email** (required) + optional phone / kind (اتفاق أو إشراف).
3. Backend creates `Party` + `ClientAccount`, generates a temporary password, sends **Party credentials** email.
4. App shows success including temporary password and whether the email was sent (`credentials_emailed`).
5. Client installs the app, logs in with that email/password (login falls through to `/client/login`).
6. Until a project is linked to that customer, the client may see an empty project list.

**Local note:** with `MAIL_MAILER=log`, “email” is written to Laravel’s log, not Gmail. The API still returns the temporary password in the response for testing.

### Scenario B — Onboard a contractor who can log in

1. Company → **المقاولون** → **مقاول جديد**.
2. Same as clients: email required → `VendorAccount` (type contractor) + credentials email.
3. Contractor logs in via the same login screen (`/vendor/login`).
4. They can open quotes, portfolio, and vendor project workspace when assigned.

### Scenario C — Create a project for a client

1. Company → **المشاريع** → **مشروع جديد**.
2. Pick an existing **customer** (required), title, address, budget, area, description.
3. API creates the project and syncs **project membership** for the creator and the customer’s client account (if any).
4. Project detail becomes the hub for design, team, requests, materials, PM, procurement, warehouse, handover.

### Scenario D — Design package → client approval

1. Open project → **التصميم**.
2. **لوحة الإلهام:** set style/notes; add inspiration items per room (images/PDF).
3. **مخططات:** add floor/elevation/etc. plans with media; optional internal submit/approve.
4. **BOQ:** add lines (manually or from inspiration); totals drive client summary.
5. Company taps **إرسال للعميل** when ready.
   - Requires: project has `customer_id` and that customer has an **active ClientAccount**.
   - Status → `pending`; client is notified (in-app / FCM when configured).
6. Client home shows “تصميم بانتظار اعتمادك” → **اعتماد التصميم**.
7. Client reviews style, inspiration, plans (view/download attachments), BOQ → **اعتماد** or **رفض مع ملاحظة**.
8. Company sees approved/rejected banner; on reject, edit and resubmit.

### Scenario E — Marketplace quote

1. Company → contractors marketplace (or contractor profile) → **طلب عرض سعر**.
2. Select project + description → quote request created for that vendor.
3. Contractor → **العروض** → respond with pricing/notes.
4. Company accepts or rejects. Accepted quotes can drive further job/project linkage.

### Scenario F — Team and project requests

1. Project → **الفريق**: add company/vendor members; invite client if needed.
2. Project → **الطلبات**: create a request (e.g. approval / vendor action).
3. Vendor comments / submits response; company or client approve/reject with comments as allowed by role APIs.
4. Notifications keep each side in sync.

### Scenario G — Materials → PO → warehouse → site

1. Add materials to the project from supplier catalog.
2. Generate / create **purchase order** → approve → **receive** goods.
3. Warehouse: stock, issue to project, transfers.
4. PM tracks tasks/milestones; handover tracks snags/checklist/sign-off until **تسليم**.

### Scenario H — Ledger day-to-day (company)

1. **دفتر:** customer journal (تحصيل، مصنعية، بضاعة…), statements, supervision fees where kind is إشراف.
2. **مصروفات** and **أعمال المقاولين** for office spend and contractor agreements/payments.
3. **تقارير** for customers, contractors, expenses, sales, inventory, P&L (admin).

### Scenario I — Notifications

1. On login, app registers FCM device token with the API.
2. Events (design submitted/approved/rejected, quotes, requests, etc.) create notification rows and optional push.
3. User opens **التنبيهات**, marks read, follows deep link (`route` in payload).

### Scenario J — Offline / sync

1. Reads can fall back to Drift SQLite cache when the API is unreachable.
2. Some writes enqueue to an **outbox** and replay when online (**المزيد → مزامنة الصندوق الصادر**).
3. This is opportunistic offline support, not a full offline-first ERP.

---

## 6. Business rules (important)

1. **Email on party create** — Creating a customer or contractor without email fails validation when a login is required.
2. **Design submit requires a client login** — Project must have `customer_id` pointing to a party with an active `ClientAccount`; otherwise the API returns a clear Arabic 422.
3. **Client only sees their projects** — Scoped by `customer_id` ↔ client’s `party_id`.
4. **Role redirects** — Vendors/clients cannot open company-only routes (`/journal`, `/clients`, full `/projects` admin tree, etc.); company users are kept off `/client/*` and vendor-only surfaces except where shared (e.g. notifications).
5. **Temporary passwords** — Returned once in API responses and emailed; treat them as secrets in production.
6. **Design status gates editing** — While `pending`, company edit may be locked; after `rejected`, company can revise and resubmit.
7. **Company isolation** — Parties and projects are scoped by `company_id`.

---

## 7. Tech stack and architecture

### Flutter app

- Flutter 3.7+ / Dart, Arabic `Locale('ar')`
- **BLoC / Cubit** for auth and features
- **GoRouter** for shell + deep links + auth redirects
- **Dio** → `https://…/api/v1` (or local `http://127.0.0.1:8000`)
- **Drift** SQLite — cache + sync outbox
- **get_it** DI, **flutter_secure_storage** for Sanctum tokens
- **Firebase Messaging** + local notifications
- Media: image_picker, file_picker, url_launcher, open_filex
- Flavors: `main.dart` / `main_local.dart` / `main_production.dart`

### Laravel API

- Laravel + **Sanctum** (company `User`, `VendorAccount`, `ClientAccount`)
- REST under `/api/v1`
- Mail for party credentials; FCM via Firebase Admin when configured
- Multi-tenant by `company_id`

### Layering (per feature)

```
presentation/  → screens, cubits
data/          → repositories, remote datasources, models
injection.dart → get_it registration
```

Core shared: `lib/core` (routing, theme, network, database, widgets, DI).

---

## 8. Navigation map

### Bottom shell (company)

| Tab | Route | Purpose |
| --- | --- | --- |
| الرئيسية | `/home` | Shortcuts to projects, clients, design, procurement, … |
| دفتر | `/ledger` | Journal / statements hub |
| تقارير | `/reports` | Report hub |
| المزيد | `/more` | Settings, sync, notifications, extras |

### Important company routes

- `/clients`, `/clients/add`, `/clients/:id/edit`
- `/contractors`, `/contractors/add`, `/contractors/marketplace`
- `/projects`, `/projects/add`, `/projects/:id`
- `/projects/:id/design`, `/projects/:id/team`, `/projects/:id/requests`
- `/projects/:id/pm`, `/projects/:id/procurement`, `/projects/:id/warehouse`, `/projects/:id/handover`
- `/quotes`, `/notifications`, `/company`

### Client

- `/client/projects`, `/client/projects/:id`
- `/client/projects/:id/design-approval`
- `/client/projects/:id/requests`
- `/notifications`

### Vendor

- `/quotes`, `/quotes/:id`, `/quotes/:id/respond`
- `/vendor/projects`, `/vendor/products`, `/vendor/portfolio`
- `/notifications`

---

## 9. Demo users

Typical local seeds (confirm in backend seeder):

| Email | Role |
| --- | --- |
| `admin@shatbha.test` | Company admin |
| `clerk@shatbha.test` | Company clerk |
| `client@shatbha.test` | Client (if seeded) |
| Vendor emails from seeder / provisioned contractors | Contractor or supplier |

Password for seeded accounts is usually `password` unless changed.

---

## 10. Project layout

```
code/                          ← Flutter app (this repo)
├── lib/
│   ├── main.dart / main_local.dart / main_production.dart
│   ├── app.dart               # MaterialApp.router, locale ar
│   ├── bootstrap.dart
│   ├── core/
│   │   ├── config/            # API flavors
│   │   ├── database/          # Drift
│   │   ├── di/
│   │   ├── network/
│   │   ├── routing/           # app_router.dart
│   │   ├── theme/
│   │   └── widgets/
│   └── features/              # auth, shell, catalog, projects, design, client, …
├── assets/brand/
├── RUN.md                     # Local Android / adb / Laravel serve
└── pubspec.yaml

Shatbha-backend/               ← sibling Laravel API (separate clone)
├── routes/api.php
├── app/Http/Controllers/Api/
├── app/Services/              # PartyLoginProvisioner, NotificationService, FcmPushService, …
└── resources/views/emails/
```

---

## 11. Related docs

- **[RUN.md](RUN.md)** — Start Laravel on `127.0.0.1:8000`, `adb reverse`, FVM Flutter flavors, emulator/USB checklist
- Backend README (in `Shatbha-backend`) — migrations, seeders, env (`MAIL_*`, `FIREBASE_CREDENTIALS`), deploy notes

---

## Quick start (summary)

```bash
# Terminal 1 — API
cd ../Shatbha-backend
php artisan serve --host=127.0.0.1 --port=8000

# Terminal 2 — Android device tunnel
adb reverse tcp:8000 tcp:8000

# Terminal 3 — App
cd ../code
fvm flutter run --flavor local -t lib/main_local.dart
```

Full detail, troubleshooting, and production notes: **[RUN.md](RUN.md)**.
