# Run Shatbha locally

How to start the Laravel API on your Mac and open the Flutter app on an **Android emulator** or a **USB phone** (`adb`).

Two repos sit next to each other:

```
Shatbha/
  code/              ← this Flutter app (you are here)
  Shatbha-backend/   ← Laravel API (`artisan` lives here)
```

`php artisan serve` **must** be run inside `Shatbha-backend`. Running it from `code/` prints `Could not open input file: artisan`.

---

## What you need

- Flutter via **FVM** (`fvm flutter`)
- Android SDK **adb** on your `PATH` (or Android Studio)
- PHP 8.2+ and Composer (for local Laravel)
- Cloned [Shatbha-backend](https://github.com/islam-kamal/Shatbha-backend)

First-time Laravel install (once): see the main README section **Run the Laravel API (first-time setup)**.

---

## How the pieces connect

The local app talks to `http://127.0.0.1:8000`.

| Who | What `127.0.0.1:8000` means |
|---|---|
| Mac / iOS Simulator | Your Mac — Laravel is here |
| Android emulator | The **emulator**, not your Mac |
| USB Android phone | The **phone**, not your Mac |

So on Android you run **`adb reverse`**: the device’s port 8000 is forwarded to Laravel on the Mac.

```
Emulator or phone  →  127.0.0.1:8000
        adb reverse tcp:8000 tcp:8000
Mac Laravel        ←  127.0.0.1:8000
```

Do **not** pass `--dart-define=API_BASE_URL=http://192.168.91.70:8000` for emulator or USB. That address was a README example, not your machine.

---

## Step 1 — Start Laravel (keep this terminal open)

```bash
cd /Users/islamkamal/Public/Personal/AI/Shatbha/Shatbha-backend
php artisan serve --host=127.0.0.1 --port=8000
```

Check:

```bash
curl -s http://127.0.0.1:8000/up
```

You want JSON with `"ok"` / a 200. If this fails, the app cannot log in.

Optional login probe:

```bash
curl -s -X POST http://127.0.0.1:8000/api/v1/login \
  -H 'Accept: application/json' \
  -d 'email=admin@shatbha.test&password=password'
```

---

## Step 2 — Attach the Android device

### Emulator

1. Open **Android Studio → Device Manager** and start an emulator (or `emulator -avd <name>`).
2. Confirm it is the only device, or you know which serial to use:

```bash
adb devices
```

Example:

```
List of devices attached
emulator-5554	device
```

### USB phone

1. Enable **Developer options** → **USB debugging**.
2. Plug in the phone; accept the RSA prompt.
3. `adb devices` should show the phone as `device` (not `unauthorized`).

If **emulator and phone** are both connected, the helper script uses the USB phone (`adb -d`). To force the emulator: `adb -e reverse tcp:8000 tcp:8000`.

---

## Step 3 — Forward port 8000 (`adb reverse`)

From the Flutter repo:

```bash
cd /Users/islamkamal/Public/Personal/AI/Shatbha/code
./scripts/adb_reverse.sh
```

Or by hand:

```bash
adb reverse tcp:8000 tcp:8000
```

| Flag | Meaning |
|---|---|
| *(none)* | The only connected device |
| `-e` | Emulator |
| `-d` | USB phone |

Re-run this after you restart the emulator, unplug the phone, or reboot adb.

---

## Step 4 — Run the Flutter app

Still in `code/`. Boot log **must** show:

```
flavor=local API_BASE_URL=http://127.0.0.1:8000
```

If it shows `192.168.91.70` or another LAN IP, stop the app (`q`) and run **without** `--dart-define=API_BASE_URL=...`. Changing dart-define needs a **full restart**, not hot reload.

### One-shot (reverse + run)

```bash
cd /Users/islamkamal/Public/Personal/AI/Shatbha/code
./scripts/run_local_android.sh
```

### Manual

```bash
cd /Users/islamkamal/Public/Personal/AI/Shatbha/code
adb reverse tcp:8000 tcp:8000
fvm flutter run --flavor local -t lib/main_local.dart
```

### Cursor / VS Code

Run and Debug → **Shatbha · local** (runs `adb reverse` via `.vscode/tasks.json`).

### iOS Simulator / macOS / web (no adb)

Laravel on `127.0.0.1:8000` is enough:

```bash
cd /Users/islamkamal/Public/Personal/AI/Shatbha/code
fvm flutter run -t lib/main_local.dart
```

---

## Step 5 — Log in

| Email | Password | Role |
|---|---|---|
| `admin@shatbha.test` | `password` | Company admin |
| `clerk@shatbha.test` | `password` | Company clerk |
| `contractor@market.test` | `password` | Marketplace contractor |
| `supplier@market.test` | `password` | Marketplace supplier |
| `client@shatbha.test` | `password` | Homeowner |

The login screen is prefilled with the admin account.

---

## USB phone on Wi‑Fi only (no cable)

Skip this for the **emulator**. Use it only when the phone is not on USB.

**Terminal 1** (backend):

```bash
cd /Users/islamkamal/Public/Personal/AI/Shatbha/Shatbha-backend
php artisan serve --host=0.0.0.0 --port=8000
ipconfig getifaddr en0
```

Use the IP that command prints (for example `192.168.1.23`). Phone and Mac must be on the same Wi‑Fi.

**Terminal 2** (Flutter):

```bash
cd /Users/islamkamal/Public/Personal/AI/Shatbha/code
fvm flutter run --flavor local -t lib/main_local.dart \
  --dart-define=API_BASE_URL=http://192.168.1.23:8000
```

---

## Hosted API (no local Laravel)

```bash
cd /Users/islamkamal/Public/Personal/AI/Shatbha/code
fvm flutter run --flavor production -t lib/main_production.dart
```

Same demo users. No `adb reverse`.

---

## Troubleshooting

| What you see | What to do |
|---|---|
| `Could not open input file: artisan` | You are in `code/`. `cd` to `Shatbha-backend`. |
| `connectionTimeout` to `192.168.91.70` | Drop `--dart-define=API_BASE_URL`. Use `127.0.0.1` + `adb reverse`. |
| `Connection refused` | Laravel is not running, or reverse is missing. Repeat steps 1 and 3. |
| Boot URL is wrong | Full restart after changing flavor or dart-define. |
| `adb devices` empty | Start the emulator or enable USB debugging; accept the phone prompt. |
| Emulator + phone both listed | `adb -e reverse ...` (emulator) or `adb -d reverse ...` (phone). |
| Login 401 / validation | `admin@shatbha.test` / `password`. Seed the backend if the user is missing. |

---

## Checklist (emulator or USB)

1. Laravel: `php artisan serve --host=127.0.0.1 --port=8000` **from `Shatbha-backend`**.
2. Device: emulator running **or** phone on USB with debugging.
3. `adb reverse tcp:8000 tcp:8000` (or `./scripts/adb_reverse.sh`).
4. From `code/`: `./scripts/run_local_android.sh` — **no** LAN dart-define.
5. Log shows `API_BASE_URL=http://127.0.0.1:8000`.
6. Log in with `admin@shatbha.test` / `password`.
