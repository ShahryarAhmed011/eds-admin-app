import 'package:eds_admin_app/core/session/app_role.dart';
import 'package:eds_admin_app/core/session/onboarding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fresh = OnboardingStatus();
  const done = OnboardingStatus(
    phoneVerified: true,
    profileCreated: true,
    storeCreated: true,
    kycCompleted: true,
    catalogCount: minCatalogProducts,
  );

  test('reads the status block of the login response', () {
    final status = OnboardingStatus.fromJson(const {
      'isEmailVerified': true,
      'isPhoneVerified': false,
      'isProfileCreated': false,
      'isStoreCreated': false,
      'isKYCCompleted': false,
      'canGoLive': false,
    });
    expect(status.emailVerified, isTrue);
    expect(status.nextStep(AppRole.retailer), OnboardingStep.verifyPhone);
  });

  test('retailer: phone → profile → store → KYC → catalog → home', () {
    final steps = _walk(AppRole.retailer);
    expect(steps, [
      OnboardingStep.verifyPhone,
      OnboardingStep.profile,
      OnboardingStep.store,
      OnboardingStep.kyc,
      OnboardingStep.catalog,
    ]);
  });

  test('rider: phone → profile → KYC → home', () {
    final steps = _walk(AppRole.rider);
    expect(steps, [
      OnboardingStep.verifyPhone,
      OnboardingStep.profile,
      OnboardingStep.kyc,
    ]);
  });

  test('customer: phone → profile → home', () {
    const verified = OnboardingStatus(phoneVerified: true);
    expect(verified.nextStep(AppRole.customer), OnboardingStep.profile);
    expect(
      verified.complete(OnboardingStep.profile).nextStep(AppRole.customer),
      isNull,
    );
  });

  test('admins and finished accounts have no step', () {
    expect(fresh.nextStep(AppRole.admin), isNull);
    for (final role in AppRole.values) {
      expect(done.nextStep(role), isNull, reason: '$role');
    }
  });

  test('an email login verifies the email instead of the phone', () {
    const viaEmail = OnboardingStatus(verifyVia: VerifyVia.email);
    expect(viaEmail.nextStep(AppRole.rider), OnboardingStep.verifyEmail);
    // Verified email: no phone step, on to the profile.
    expect(
      viaEmail.complete(OnboardingStep.verifyEmail).nextStep(AppRole.rider),
      OnboardingStep.profile,
    );
    // Kept across a restart.
    expect(
      OnboardingStatus.fromJson(viaEmail.toJson()).nextStep(AppRole.rider),
      OnboardingStep.verifyEmail,
    );
  });

  test('survives a save and load', () {
    final status = fresh.complete(OnboardingStep.verifyPhone);
    expect(
      OnboardingStatus.fromJson(status.toJson()).nextStep(AppRole.retailer),
      OnboardingStep.profile,
    );
  });
}

/// Every step a fresh account of [role] goes through, finishing each.
List<OnboardingStep> _walk(AppRole role) {
  var status = const OnboardingStatus();
  final steps = <OnboardingStep>[];
  for (var step = status.nextStep(role); step != null;) {
    steps.add(step);
    status = status.complete(step);
    step = status.nextStep(role);
  }
  return steps;
}
