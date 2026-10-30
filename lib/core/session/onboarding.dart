import 'app_role.dart';

/// A step a signed-in account must finish before using the app, in order.
///
/// [catalog] is retailer-only and comes last (after KYC): the shop must list
/// at least [minCatalogProducts] products before it opens.
enum OnboardingStep { verifyEmail, verifyPhone, profile, store, kyc, catalog }

/// How many products a retailer must list before the catalog step is done
/// (the backend's `catalogCount` in the login `status` block is checked
/// against this).
const minCatalogProducts = 10;

/// The onboarding steps shown in the stepper for [role], in order (the
/// contact check comes before and isn't shown): Profile, then Store and
/// KYC for a retailer, KYC for a rider.
List<OnboardingStep> onboardingStages(AppRole role) => [
  OnboardingStep.profile,
  if (role == AppRole.retailer) OnboardingStep.store,
  if (role == AppRole.retailer || role == AppRole.rider) OnboardingStep.kyc,
];

extension OnboardingStepLabel on OnboardingStep {
  String get label => switch (this) {
    OnboardingStep.verifyEmail || OnboardingStep.verifyPhone => 'Verify',
    OnboardingStep.profile => 'Profile',
    OnboardingStep.store => 'Store',
    OnboardingStep.kyc => 'KYC',
    OnboardingStep.catalog => 'Products',
  };
}

/// Which contact the account verifies first: the one it logged in with
/// (an email login verifies the email, phone login and sign up the phone).
enum VerifyVia { phone, email }

/// The `status` block of the login / sign up response: what the account
/// has finished. Each role gets its own flags (customer: email, phone,
/// profile; rider: + KYC, `canGoOnline`; retailer: + store, KYC,
/// `canGoLive`); missing ones read as false.
class OnboardingStatus {
  const OnboardingStatus({
    this.emailVerified = false,
    this.phoneVerified = false,
    this.profileCreated = false,
    this.storeCreated = false,
    this.kycCompleted = false,
    this.catalogCount = 0,
    this.canGoLive = false,
    this.canGoOnline = false,
    this.verifyVia = VerifyVia.phone,
  });

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    bool flag(String key) => json[key] == true;
    return OnboardingStatus(
      verifyVia: json[_verifyViaKey] == VerifyVia.email.name
          ? VerifyVia.email
          : VerifyVia.phone,
      emailVerified: flag('isEmailVerified'),
      phoneVerified: flag('isPhoneVerified'),
      profileCreated: flag('isProfileCreated'),
      storeCreated: flag('isStoreCreated'),
      kycCompleted: flag('isKYCCompleted'),
      catalogCount: (json['catalogCount'] as num?)?.toInt() ?? 0,
      canGoLive: flag('canGoLive'),
      canGoOnline: flag('canGoOnline'),
    );
  }

  final bool emailVerified;
  final bool phoneVerified;
  final bool profileCreated;
  final bool storeCreated;
  final bool kycCompleted;

  /// How many products the retailer's store lists (login `status` block).
  final int catalogCount;

  /// Retailer: the shop can go live.
  final bool canGoLive;

  /// Rider: can start taking deliveries.
  final bool canGoOnline;

  /// Set by the app (not the API) from how the account logged in.
  final VerifyVia verifyVia;

  static const _verifyViaKey = 'verifyVia';

  /// This status, verifying [via] first.
  OnboardingStatus verifying(VerifyVia via) => OnboardingStatus(
    emailVerified: emailVerified,
    phoneVerified: phoneVerified,
    profileCreated: profileCreated,
    storeCreated: storeCreated,
    kycCompleted: kycCompleted,
    catalogCount: catalogCount,
    canGoLive: canGoLive,
    canGoOnline: canGoOnline,
    verifyVia: via,
  );

  /// The first unfinished step for [role], or null when it can use the
  /// app: the [verifyVia] contact → profile, then store → KYC for a retailer and KYC for a
  /// rider. Customers only need a profile; admins have no onboarding.
  OnboardingStep? nextStep(AppRole role) {
    if (role == AppRole.admin) return null;
    switch (verifyVia) {
      case VerifyVia.email when !emailVerified:
        return OnboardingStep.verifyEmail;
      case VerifyVia.phone when !phoneVerified:
        return OnboardingStep.verifyPhone;
      case _:
    }
    if (!profileCreated) return OnboardingStep.profile;
    return switch (role) {
      AppRole.retailer when !storeCreated => OnboardingStep.store,
      AppRole.retailer ||
      AppRole.rider when !kycCompleted => OnboardingStep.kyc,
      // Last for a retailer: the store must list at least ten products.
      AppRole.retailer when catalogCount < minCatalogProducts =>
        OnboardingStep.catalog,
      _ => null,
    };
  }

  /// This status with [step] marked done.
  OnboardingStatus complete(OnboardingStep step) => OnboardingStatus(
    emailVerified: emailVerified || step == OnboardingStep.verifyEmail,
    phoneVerified: phoneVerified || step == OnboardingStep.verifyPhone,
    profileCreated: profileCreated || step == OnboardingStep.profile,
    storeCreated: storeCreated || step == OnboardingStep.store,
    kycCompleted: kycCompleted || step == OnboardingStep.kyc,
    // Finishing the catalog step means the ten-product bar is met.
    catalogCount:
        step == OnboardingStep.catalog && catalogCount < minCatalogProducts
        ? minCatalogProducts
        : catalogCount,
    canGoLive: canGoLive,
    canGoOnline: canGoOnline,
    verifyVia: verifyVia,
  );

  Map<String, dynamic> toJson() => {
    'isEmailVerified': emailVerified,
    'isPhoneVerified': phoneVerified,
    'isProfileCreated': profileCreated,
    'isStoreCreated': storeCreated,
    'isKYCCompleted': kycCompleted,
    'catalogCount': catalogCount,
    'canGoLive': canGoLive,
    'canGoOnline': canGoOnline,
    _verifyViaKey: verifyVia.name,
  };
}

/// Where features record onboarding progress (the session implements it).
abstract interface class OnboardingTracker {
  AppRole? get role;
  OnboardingStep? get onboardingStep;

  /// Saves the status from a response; null forgets it (no gate).
  Future<void> setOnboarding(OnboardingStatus? status);

  /// Marks [step] finished so the router moves on.
  Future<void> completeOnboarding(OnboardingStep step);
}

/// Keeps the onboarding status with the session across restarts.
abstract interface class OnboardingStorage {
  Future<OnboardingStatus?> read();
  Future<void> write(OnboardingStatus status);
  Future<void> clear();
}

/// Session-only storage (tests, or when nothing should persist).
class MemoryOnboardingStorage implements OnboardingStorage {
  OnboardingStatus? _status;

  @override
  Future<OnboardingStatus?> read() async => _status;

  @override
  Future<void> write(OnboardingStatus status) async => _status = status;

  @override
  Future<void> clear() async => _status = null;
}
