# EDoorStep (EDS) — Project Overview

> **EDS Admin** — the single-role **admin** app, cut from `eds-mobile-app` on 2026-10-29 (`docs/multi-app-extraction-plan.md`). Sections below describe the shared architecture; only this role's features ship here.

## What the app is

**EDoorStep** is a Flutter mobile app for a **hyperlocal grocery / retail marketplace in Pakistan** (prices in PKR paisa, areas like Karachi & Islamabad, `+92` phone codes).

It is unusual in that **one app serves four roles** — **Customer, Retailer, Rider, and Admin** — each with its own home, bottom-nav tabs, onboarding flow, and route space, gated by an auth + role guard.

## Purpose & core idea

The core idea is a **live, location-aware marketplace that connects nearby shops to nearby customers**:

- **Customer** — discover shops that are live nearby, search products, and compare the *same SKU across nearby shops* ("who has this, and who's cheapest"), plus manage delivery addresses. *(Ordering/cart = Phase 2.)*
- **Retailer** — create a shop, pass KYC, build a catalogue (browse a master catalogue, scan barcodes, bulk-add, bulk-reprice), and manage a go-live lifecycle (**draft → live → paused**).
- **Rider** — onboard and pass KYC. *(Actual deliveries = Phase 2.)*
- **Admin** — run the back-office: review queues, KYC approvals, user/shop moderation, catalogue variant management, product-request approvals, a web-scraper/catalogue-import dashboard, serviceable-area toggles, and an audit log.

The app runs in two modes via `--dart-define`:
- **Remote API** (default) against `https://api.edoorstep.com/api/v1`
- **Dummy / offline mode** — every feature has a dummy data source returning the same JSON shape, so the whole app is demoable offline.

## Architecture

**Clean Architecture + BLoC, organized by feature module.** Each feature is a vertical slice with `data` / `domain` / `presentation` layers.

| Concern | Choice |
|---|---|
| State management | `flutter_bloc` (~50 BLoCs), `equatable` |
| Dependency injection | `get_it` service locator; a single `feature_registry.dart` wires every module and picks Remote vs Dummy data sources |
| Routing | `go_router`, centralized in `core/router/app_routes.dart`, with an auth + onboarding + role route guard |
| Networking | `dio` wrapped in `ApiClient`, which unwraps a standard `{success, status, data, error, pagination}` envelope and handles cursor pagination |
| Session / auth | `AuthSession` (`ChangeNotifier`) doubling as token storage + onboarding tracker; tokens in `flutter_secure_storage` |
| Local persistence | `sqflite` (currently gated off while the live backend is validated) |
| Design system | Custom `Eds*` widget library (~30 widgets), theme layer, Inter + Outfit fonts, integer-paisa `Money` type |
| Maps / location | `flutter_map` + `latlong2` + `geolocator` for the map pin-picker and serviceability flows |

### Folder structure (`lib/`)

```
lib/
├── app.dart, main.dart, bootstrap
├── core/        # config, di, network, router, session, storage, theme, widgets, money, location
└── features/
    ├── splash/
    ├── shared/   → auth, profile, location, kyc
    ├── customer/ → home, discovery, cart, account
    ├── retailer/ → shop, kyc, lifecycle, catalogue, products, product_requests
    ├── rider/    → home, deliveries, kyc, account
    ├── admin/    → queues, kyc, users, shops, catalogue, product_requests, scraper, areas, audit_log
    └── system/   → state views & skeletons
```

### Bottom-nav tabs per role

| Role | Tabs |
|---|---|
| Admin | Queues · Shops · Users · Catalogue · More |

## Backend integration

- **Base URL:** `https://api.edoorstep.com/api/v1`
- **Envelope:** every response is `{success, status, message, data, error.code, meta.request_id, pagination}`. Clients branch on `status` / `error.code`, never on `message`. Collections live at `data.items`; cursor pagination via `pagination.next_cursor`. Money is always integer paisa.
- **Auth flow:** `POST /auth/login` (or register) → email OTP verify/resend → bearer `access_token` (~15 min) + `refresh_token` → `/auth/refresh` rotates tokens. The same email can hold one account **per role**, so `role` is required on register/login/OTP. In dev, **OTP is always `123456`**.
- **Onboarding is API-driven:** `GET /onboarding/status` returns the next action/route, which the route guard enforces (verify → profile → store → KYC).
- A full **87-operation curl reference** lives in `docs/api/curl-reference.md`.
- *Note:* the Dart remote data sources are partly **ahead of / diverging from** the documented contract (e.g. code uses `store`-style paths and phone-OTP endpoints the reference doesn't list), reflecting active wiring against an evolving backend.

## Status — what's done so far

### Done (implemented screens, BLoCs, dummy + partial remote data)

- **Auth & onboarding** — sign in/up, OTP, complete profile, KYC, create shop, location/serviceability, map pin picker.
- **Customer discovery** — home, search, compare-nearby, product, shop, address book / account.
- **Retailer catalogue & inventory** — global catalogue browse, barcode scan, bulk add, bulk reprice, my products, product requests, go-live lifecycle, account.
- **Full Admin back-office** — queues, KYC review, users, shops, catalogue variants, product-request approvals, scraper/import dashboard, serviceable areas, audit log.
- **Platform** — design system, theming, routing guards, session management, envelope handling.
- **~57 screen files** (real implementations, not stubs), **29 dummy** data sources + **26 remote** wired.

### Phase 2 / not yet shipped (deliberately gated in code)

- **Customer cart / ordering** — renders a "Phase 2 · Coming soon" state.
- **Rider deliveries** — placeholder; deliveries land in Phase 2.
- **Retailer ordering on live home** — "arrives in Phase 2".
- **Google sign-in** — "coming soon".
- Some extra shop types / countries in the location picker.

### Maturity signals

- `persistAccountData = false` while the live backend is being validated → screens fetch from API.
- Store/shop endpoint-naming divergence → remote integration still being validated, while the UI and offline/dummy path are essentially complete.
- Short git history (all on `main`), broad screen-for-screen build-out from `figma_ref/`.
- No scattered `TODO`/`FIXME`s — the only forward markers are the deliberate "Phase 2" gates.

### Testing

`flutter test` runs unit tests plus a smoke test that boots the app, checks route guards, and renders every route per role at 360×800.
