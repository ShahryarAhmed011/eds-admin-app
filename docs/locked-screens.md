# Locked screens

Cut down for the EDS Admin app on 2026-10-29 (`docs/multi-app-extraction-plan.md`): only the steps this app ships are listed; the files themselves are identical to `eds-mobile-app` at tag `split-base-2`.

These screens are finished and signed off. Do not change their order, their UI, their routing, or the API calls under them without asking the owner twice first. New work goes alongside them, never on top of them. Last confirmed 2026-10-28.

Changed 2026-10-29 with the owner's go-ahead, for the split into single-role apps (`docs/multi-app-extraction-plan.md`): sign up no longer asks for a role (the app's `AppConfig.appRole` is registered), the sign-up link and route are absent when the app's role cannot self-register (admin), and a login as another role is refused before any session is written. Nothing else in these screens changed.

## The locked onboarding flow

The retailer onboarding sequence is driven by the login `status` flags (`isPhoneVerified` / `isEmailVerified`, `isProfileCreated`, `isStoreCreated`, `isKYCCompleted`, `catalogCount`). The first unfinished step wins, in this order.

| # | Step | Screen | File |
| --- | --- | --- | --- |
| 1 | Sign in / Sign up / OTP | `SignInScreen`, `SignUpScreen`, `OtpScreen` | `lib/features/shared/auth/presentation/screens/` |

## Locked with the screens

- Step order and gate logic: `OnboardingStatus.nextStep`, `OnboardingStep` in `lib/core/session/onboarding.dart`.
- Onboarding routes and the per-step allow-list in `lib/core/router/app_router.dart`.

## Rules for changes

1. Ask the owner twice before editing any file above, and state the exact scope.
2. Append new onboarding steps after the catalogue step. Never reorder or remove a step.
3. Keep the state shapes the screens read. Work under a screen that changes what it renders counts as a UI change.
4. Performance-only changes (fewer calls, same output) also need confirmation now.

## Not locked

Every screen not listed above.
