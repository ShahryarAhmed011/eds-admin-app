# eds_admin_app

EDS Admin (Flutter): the EDoorStep **admin** app, split out of `eds-mobile-app` on 2026-10-29 by extraction only (`docs/multi-app-extraction-plan.md`).
Clean architecture + BLoC, built screen-for-screen from `figma_ref/screens/`.

## Run

```bash
flutter run                                   # dummy data (Figma content, works offline)
flutter run --dart-define=USE_REMOTE_API=true # real API at https://api.edoorstep.com/api/v1
flutter run --dart-define=USE_REMOTE_API=true --dart-define=API_BASE_URL=https://staging.example/api/v1
```

## App flow

Splash → a stored session opens that role's home, otherwise the welcome / role picker → sign in or sign up (+ email OTP).
After sign in, each role gets its own home and bottom tabs:

| Role | Tabs |
|---|---|
| Admin | Queues · Shops · Users · Catalogue · More |

Route guards (`lib/core/router/app_router.dart`) keep signed-out users on the auth screens and keep each role out of the others'
areas. Signing out or an expired session returns the app to the welcome screen.

In dummy mode any email/password signs in as the chosen role, and the OTP code is `123456`, the same as the dev API.

## Structure

```
lib/
├── core/                 # shared by every feature — import via core/core.dart
│   ├── theme/            # AppColors, AppTextStyles (Inter), AppSpacing, AppRadius
│   ├── widgets/          # Eds* design system: scaffold, buttons, fields, cards, sheets…
│   ├── network/          # ApiClient (envelope unwrap), ApiException, token refresh
│   ├── money/            # Money (integer paisa → "Rs 1,250")
│   ├── router/           # AppRoutes, role homes, go_router + auth guard
│   ├── session/          # AuthSession (signed-in role), AppRole
│   ├── navigation/       # bottom nav per role
│   └── di/               # get_it; registerDataSource picks Remote vs Dummy
└── features/<module>/<feature>/
    ├── data/             # data_sources (Remote + Dummy), dto, mappers, repository impl
    ├── domain/           # entities, repository interface, use cases
    ├── presentation/     # bloc, screens, widgets
    ├── <feature>.dart    # barrel
    ├── <feature>_injection.dart
    └── <feature>_routes.dart
```

Modules: `shared` (auth, location, profile), `customer`, `retailer`, `rider`, `admin`, `system`.
Each feature is registered once in `lib/features/feature_registry.dart`.

## API

The full endpoint reference is in [docs/api/curl-reference.md](docs/api/curl-reference.md). Each feature's
`XxxRemoteDataSource` maps those endpoints. The `XxxDummyDataSource` returns the same JSON shape,
so both paths run through the same mappers.

## Tests

```bash
flutter test   # unit tests + a smoke test that boots the app, checks guards and renders every route per role at 360×800
```
