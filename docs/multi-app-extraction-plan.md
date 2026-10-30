# Splitting EDS into four apps — extraction plan

Written 2026-10-29. Owner: Shahryar. Status: **plan, not started.**

## Goal

Turn the single four-role app into four single-role apps that share the same
architecture, theme, widgets and screens, by **extraction only**. No redesign,
no refactor, no new abstractions. The locked onboarding screens stay
byte-for-byte as they are in every app that contains them.

| App | Folder (sibling of this repo, under `frontend/`) | Package name | Role baked in | Sign up |
|---|---|---|---|---|
| Customer | `eds-mobile-app` (this repo, pruned) | `eds_mobile_app` (unchanged) | `customer` | yes, no role step |
| Merchant (the `retailer` role) | `eds_merchant_app` | `eds_merchant_app` | `retailer` | yes, no role step |
| Rider | `eds_rider_app` | `eds_rider_app` | `rider` | yes, no role step |
| Admin | `eds_admin_app` | `eds_admin_app` | `admin` | **none** (admin accounts are provisioned; sign in only) |

The seller app is named **EDS Merchant** (decided 2026-10-29) because it will
list restaurants and pharmacies as well as grocers. Only the product name,
folder, package and bundle id say "merchant". The code keeps the `retailer`
role value the API expects and the `features/retailer/` folder: renaming
identifiers is churn the extraction rules out.

Each new app is a **plain folder with no Git at all**, not even a local
repository. The owner initialises Git and connects GitHub later, by hand.
They are made by copying this repo's working tree at one tagged commit,
leaving out `.git`, `build`, `.dart_tool` and the IDE files, so the fork
point is still known from the tag in this repo.

## What stays the same, by decision

- Clean architecture + BLoC + get_it + go_router, feature-module layout,
  `core/` and `features/shared/`, the `Eds*` widget library, `AppColors`,
  fonts, `Money`, `ApiClient`, dummy data sources and `--dart-define` modes.
- Every locked screen (see `docs/locked-screens.md`): sign in / sign up / OTP,
  complete profile, create shop, verify identity, catalogue onboarding,
  catalogue review. Same order, same UI, same routing, same API calls.
- Route constants, the router guard, `AppRole`, `OnboardingStep` and
  `OnboardingStatus`. Dead branches for roles an app does not ship are left in
  place; they cost nothing and keep the diff to a pure deletion of features.

The **only** behaviour change in the whole project is: sign up no longer
asks for a role, because each app has exactly one. That change touches
`SignUpScreen` and the auth bloc, which are locked. The owner has asked for
it once in this plan; per the lock rule it needs a second explicit go-ahead
before the edit is made.

## How the code splits today

Measured on this repo at the time of writing.

| Area | Dart files | Lines | Goes to |
|---|---|---|---|
| `lib/core` | 67 | 6,112 | all four |
| `lib/features/shared` | 121 | 12,918 | all four, pruned per role (below) |
| `lib/features/splash`, `lib/features/system` | 12 + 10 | small | all four (`system/states` only where referenced) |
| `lib/features/customer` | 137 | 8,040 | customer |
| `lib/features/retailer` | 233 | 17,381 | retailer |
| `lib/features/rider` | 80 | 3,607 | rider |
| `lib/features/admin` | 225 | 12,796 | admin |

No role feature imports another role's feature (checked with grep), so each
role folder lifts out cleanly. Role features depend on `shared/` like this:

| Role | Uses from `features/shared/` |
|---|---|
| customer | `auth`, `orders` (+ `profile`, `location` through the router and onboarding) |
| retailer | `auth`, `common`, `kyc`, `location`, `orders`, `profile` |
| rider | `auth`, `common`, `orders` (+ `profile`, `kyc` through onboarding) |
| admin | `auth` (sign in), `kyc` (document entities) (+ `profile` only if its routes are kept) |

Wiring lives in exactly three places, which is what makes this a deletion job:

1. `lib/features/feature_registry.dart` — one `register*` call and one
   `...routes` spread per module.
2. `lib/core/navigation/role_navs.dart` — one tab list per role.
3. `lib/core/router/app_router.dart` — the guard, which already keys off the
   signed-in role and needs no change.

Cross-app consequence to accept: `features/shared/orders/OrderStore` is an
in-memory stand-in that today lets a customer order appear in the retailer
inbox *inside one process*. After the split each app has its own copy, so
that demo loop only works through the real orders API. Nothing to do now;
Home already hides order counts and the upcoming list until that API exists.

## Phase 0 — do once, in this repo, before forking

Everything here is inherited by all four apps, so it is done once.

1. Merge `home-screen-update` to `main` and tag the fork point:
   `git tag split-base`.
2. Add the per-app role to build config, `lib/core/config/app_config.dart`:
   `static const appRole = AppRole.customer;` with a doc line saying each
   app sets its own value at fork time. A compile-time constant, no
   `--dart-define`, so a wrong build cannot happen by a missing flag.
3. Sign up without the role step (needs the second go-ahead, see above):
   - `SignUpScreen`: drop `_Step.role` from the step enum and start at
     `_Step.name`; delete `_RoleStep` and `_RoleCard`. The copy on the name
     step already reads "This is how … will see you" from `selectedRole`, so
     it keeps working.
   - `AuthBloc`: `selectedRole` is initialised from `AppConfig.appRole`;
     `AuthRoleSelected`, `SelectRole`, `GetSelectedRole` and
     `AuthRepository.selectRole/getSelectedRole` are deleted. The register
     call still sends `role: AppConfig.appRole.apiValue`, so the API
     contract is untouched.
   - `app_role_ui.dart`: `signUpTitle/Description/Icon` lose their only
     caller; delete them. `canSelfRegister` becomes the admin app's switch
     to hide the "Create account" link on sign in.
4. Wrong-role account on sign in. Today the login response's role decides
   the home route. In a single-role app a customer signing into the retailer
   app would be routed to a screen that does not exist. In
   `AuthRepositoryImpl.signIn`, when `SignedInUser.role != AppConfig.appRole`,
   sign out again and throw an `ApiException` with a plain message ("This
   is a customer account. Use the EDS app to shop."). This is under a locked
   screen's data path, so it also gets the second go-ahead. (If the backend
   can take a `role` on login, send `AppConfig.appRole` and let it refuse.)
5. Run `flutter analyze` and the full test suite; commit. Tag `split-base-2`.

## Phase 1 — create `eds_merchant_app`

Repeat the same recipe for rider and admin (Phases 2 and 3). Retailer goes
first because it has the most locked screens and the most code.

### 1a. Copy and rename

```
cd "…/frontend"
git -C eds-mobile-app checkout split-base-2
rsync -a --exclude .git --exclude build --exclude .dart_tool \
      --exclude .idea --exclude '*.iml' eds-mobile-app/ eds_merchant_app/
ls -a eds_merchant_app | grep -c '^\.git$'   # must print 0
```

No `git init` afterwards. The folder stays without version control until the
owner sets it up.

- `pubspec.yaml`: `name: eds_merchant_app`, description "EDS merchant app."
- Test imports: `package:eds_mobile_app/` → `package:eds_merchant_app/`
  (only tests use package imports; `lib/` is relative throughout).
- Android: `namespace` and `applicationId` → `com.eds.merchant`;
  `android:label` → `EDS Merchant`.
- iOS: `PRODUCT_BUNDLE_IDENTIFIER` → `com.eds.merchant` (and the
  `.RunnerTests` variant); `CFBundleDisplayName` → `EDS Merchant`;
  `CFBundleName` → `eds_merchant_app`.
- `app.dart`: `title: 'EDS Merchant'`.
- `AppConfig.appRole = AppRole.retailer`.
- `.idea` and the `.iml` are not copied; the IDE regenerates them.

### 1b. Prune features

Delete whole folders, nothing inside a kept folder changes:

- `lib/features/customer/`, `lib/features/rider/`, `lib/features/admin/`
- `lib/features/shared/` — keep every subfolder; retailer uses all six.
- `lib/features/system/states/` — keep; the retailer catalogue uses its
  skeletons and sheets.

`feature_registry.dart`: remove the customer, rider and admin imports,
`register*` calls and route spreads. Keep shared, retailer and system.

`role_navs.dart`: keep `RoleNavs.retailer`; the other lists can stay or go —
they only reference string constants. Recommended: delete them so the file
says what the app is.

`core/router/app_routes.dart`, `role_home.dart`, `app_router.dart`:
**untouched** in Phase 1. Unused constants are harmless and the guard is
locked.

### 1c. Prune tests, docs and references

- `test/features/`: keep `shared`, `splash`, `retailer`; delete `customer`,
  `rider`, `admin`.
- `test/smoke/app_flow_smoke_test.dart`: it loops over `AppRole.values` and
  registers dummy sources for admin and retailer. Reduce it to the retailer
  role and drop the admin dummy sources it imports. The "cannot open another
  role's screens" case becomes "a retailer session on a customer route lands
  on retailer home" (the guard still does that).
- `test/core/router/auth_redirect_test.dart`: keep; adjust any case that
  starts from a non-retailer role.
- `figma_ref/`: keep `screens/Retailer`, `screens/Shared`, `screens/System`
  and the loose files used for retailer work (`appbar.png`, `animation.mov`,
  `order.png`, `catalog.png`, `live.png`, `hourglass.png`,
  `noordersyet.svg`, `style_action_buttons.png`,
  `horizontal_product_listing.png`, `product_listing_sync with category.png`,
  `searchandcategorybar.png`, the login/welcome/logo references). Delete
  `screens/Customer`, `screens/Rider`, `screens/Admin` and
  `selectedordersonmainmenu.png` (customer cart reference).
- `docs/locked-screens.md`: keep whole; every row applies to the retailer.
- `docs/api/catalogue-browse-api.md` and `curl-reference.md`: keep.
- `README.md` and `OVERVIEW.md`: rewrite the role table to one row and the
  folder tree to what remains; keep the architecture sections verbatim.
- `docs/multi-app-extraction-plan.md` (this file): keep in every app so the
  fork point and the rules are visible from each repo.
- Assets: `assets/images/*.svg` and both font families are shared; copy all.

### 1d. Verify

1. `flutter analyze` — clean.
2. `flutter test` — green. The pre-existing `color_usage_test` failure on two
   gradients (`store_art.dart`, `retailer_account_screen.dart`) is the only
   allowed red, same as before the split.
3. `flutter run` in dummy mode and against the API: cold start → sign in →
   retailer home; sign up → name step first, no role card; the full locked
   flow profile → store → KYC → catalogue → review opens in order.
4. Lock check, run from the new app's folder for every file listed in
   `docs/locked-screens.md`:
   `diff <file> <(git -C ../eds-mobile-app show split-base-2:<file>)`
   must print **nothing**. The role-step removal was done before the tag,
   so nothing in the locked set may differ after the fork.
5. Wrong-role check: sign in with a customer account → the plain message,
   still on the sign-in screen.

## Phase 2 — `eds_rider_app`

Same recipe with `AppRole.rider`, ids `com.eds.rider` /
`com.eds.rider`, label `EDS Rider`.

- Keep `lib/features/rider/`, `shared/{auth, common, kyc, orders, profile}`;
  delete `shared/location` only if nothing in rider or the profile step
  imports it (grep first). Delete customer, retailer, admin.
- `system/states`: delete if no rider file imports it (grep first).
- Tests: keep `shared`, `splash`, `rider`; smoke test to the rider role.
- `docs/locked-screens.md`: keep rows 1, 2 and 4 (sign in/up/OTP, profile,
  KYC); remove the store and catalogue rows and the catalogue data-path
  bullets. State at the top that the file was cut down for the rider app on
  the fork date.
- `figma_ref/screens/Rider` + `Shared` + `System`.

## Phase 3 — `eds_admin_app`

`AppRole.admin`, ids `com.eds.admin` / `com.eds.admin`, label
`EDS Admin`.

- Keep `lib/features/admin/`, `shared/auth`, `shared/kyc` (admin imports its
  entities), `shared/profile` only if admin routes to it (grep).
  Delete customer, retailer, rider, `shared/orders`, `shared/location`,
  `shared/common` unless imported.
- Sign up: not shipped. `canSelfRegister` is false for admin, so the sign-in
  screen hides "Create account"; remove `AppRoutes.signUp` from the
  registry's shared auth routes for this app only (one line in
  `shared/auth/auth_routes.dart` guarded by `AppConfig.appRole.canSelfRegister`
  keeps the file identical across apps).
- Tests: keep `shared/auth`, `splash`, `admin` (11 files, the biggest test
  set); smoke test to the admin role.
- `docs/locked-screens.md`: keep row 1 only.
- `figma_ref/screens/Admin` + `Shared` + `System`.

## Phase 4 — prune this repo to the customer app

Last, so the other three were cut from a complete source.

- Delete `lib/features/retailer/`, `rider/`, `admin/`, `shared/kyc`,
  `shared/common` (grep first), `system/states` (grep first).
- Registry: shared auth, location, profile; customer; nothing else.
- `RoleNavs.customer` only.
- Tests: `shared`, `splash`, `customer`, `core`; smoke test to the customer
  role.
- `docs/locked-screens.md`: rows 1 and 2.
- `figma_ref/screens/Customer` + `Shared` + `System` and
  `selectedordersonmainmenu.png` (the pending cart-panel reference).
- README/OVERVIEW: "customer app" wording; the other three apps get one line
  each naming their folders.
- Keep the package name `eds_mobile_app` and the store ids: this is the app
  already on the stores.

## Order of work and effort

| Step | Rough effort | Blocked on |
|---|---|---|
| Phase 0 (shared changes, once) | half a day | owner's second go-ahead on the two locked-screen edits |
| Phase 1 retailer | one day | Phase 0 tag |
| Phase 2 rider | half a day | Phase 1 recipe proven |
| Phase 3 admin | half a day | — |
| Phase 4 customer prune | half a day | Phases 1–3 done |
| Store/bundle setup (certs, Play/App Store entries) for 3 new ids | outside this plan | — |

Each phase ends with analyze clean, tests green and the lock check empty.
In this repo that is one commit per phase. The new apps have no Git, so
before each phase there take a copy of the folder
(`cp -R eds_merchant_app eds_merchant_app.bak`) and delete it once the
phase is verified; that is the only rollback.

## Rules after the split

1. `core/` and `features/shared/` now exist four times. Until a shared
   package is extracted (explicitly **out of scope** here, as it is an
   architecture change), a change to either must be applied to all four
   repos by hand in the same week, and the commit message must name the
   other three. Track it in a `SYNC.md` at each root listing the
   `eds-mobile-app` commit that app was last synced to (only this repo has
   commits).
2. The locked-screens rule holds in every app. A locked file is identical
   across apps by construction; keep it that way.
3. `AppRole` stays complete in every app: the API still sends and expects
   all four values, and `fromApi` must not fall back to the wrong role.
4. Dummy mode keeps working per app; the cross-app order demo is gone.
5. The three new apps have no Git at all until the owner initialises it.
   Do not run `git init`, add a remote, push, or open a PR from them.

## Open questions for the owner

1. Confirm the bundle id pattern `com.eds.merchant` / `com.eds.rider` /
   `com.eds.admin` (proposed), or give the ones registered on the stores.
   The customer app keeps its existing id.
2. Second go-ahead for the two locked-screen edits in Phase 0 (role step
   removal; wrong-role sign-in refusal).
3. Does the backend accept `role` on login? If yes, Phase 0 step 4 sends it
   instead of checking client-side.

## Execution log — 2026-10-29

Done the same day the plan was written, on branch `multi-app-split` of
`eds-mobile-app` (not merged to `main`; the owner merges).

| Step | Result |
|---|---|
| Phase 0 | commit `b429b45` "Phase 0: single-role build" + `40987ba` (smoke test follows the build's role); tag `split-base-2` |
| `eds_merchant_app` | plain folder, no Git; analyze clean; 108 tests pass, 1 known failure (below); every locked file identical to `split-base-2` |
| `eds_rider_app` | plain folder, no Git; analyze clean; 81 tests pass; locked files identical |
| `eds_admin_app` | plain folder, no Git; analyze clean; 113 tests pass; locked files identical |
| customer (this repo) | commit `377ccf5` "Phase 4: prune to the customer app"; tag `split-customer`; analyze clean; 83 tests pass; locked files identical |

Deviations from the plan above, all deliberate:

1. **Android `namespace` is unchanged** (`com.eds.eds_mobile_app`) in the
   three new apps; only `applicationId` and the label changed. The
   manifest's `.MainActivity` resolves against the namespace and the Kotlin
   file still lives under `com/eds/eds_mobile_app`, so changing the
   namespace alone would break the launch. Moving the Kotlin package is a
   separate, optional tidy-up.
2. **No `dart format` on the copies.** The first pass ran it and it
   reformatted files the base had never formatted, two of them locked.
   Those files were restored byte-for-byte from the tag, and the step was
   dropped from the recipe. Rule: a copied file is either identical to the
   tag or on the intended-change list.
3. **Generated build files were deleted** from the copies
   (`ios/Flutter/Generated.xcconfig`, `ios/Flutter/ephemeral/`,
   `ios/Flutter/flutter_export_environment.sh`, `android/local.properties`)
   because they carried the old folder's absolute path. They are
   git-ignored and come back on the first `flutter run`. `ios/Pods` was not
   copied; CocoaPods reinstalls on the first iOS run.
4. **The map user-agent string** `com.eds.eds_mobile_app` in
   `shared/location` (place search, map pin picker) and the merchant's
   `shop_pin_preview.dart` was left as is: it is shared code, and the rule
   is to keep shared code identical across the four apps. Change it in all
   four at once if the tile provider should see one id per app.
5. **Known red test in the merchant app:** `color_usage_test` flags two
   gradients in `store_art.dart` and `retailer_account_screen.dart`. It
   failed the same way in the combined app before the split and is not a
   split problem. The other three apps no longer contain those files and
   are fully green.
6. **Open questions 1 and 3** (bundle id pattern, role on login) were not
   answered before execution. The ids are the proposed `com.eds.merchant` /
   `com.eds.rider` / `com.eds.admin`, and the wrong-role refusal is the
   client-side check; both are easy to change later.

The recipe that produced the apps is `make_app.sh` (per-role copy, rename,
prune, verify) with `fix_format.sh` (restore anything not on the
intended-change list); both lived in the session scratchpad and are
described fully by Phases 1–4 above.
