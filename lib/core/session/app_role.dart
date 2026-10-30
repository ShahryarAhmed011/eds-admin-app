/// Account roles. One email may hold one account per role, so the role is
/// sent on register, login and OTP calls.
enum AppRole {
  customer('customer', 'Customer'),
  retailer('retailer', 'Retailer'),
  rider('rider', 'Rider'),
  admin('admin', 'Admin');

  const AppRole(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AppRole fromApi(String? value) => AppRole.values.firstWhere(
    (r) => r.apiValue == value,
    orElse: () => AppRole.customer,
  );
}

extension AppRoleAudience on AppRole {
  /// "This is how … will see you.": who deals with this role.
  String get seenBy => switch (this) {
    AppRole.retailer => 'customers and riders',
    AppRole.rider => 'customers and shops',
    AppRole.customer || AppRole.admin => 'shops and riders',
  };
}

extension AppRoleAge on AppRole {
  /// Shops and riders must be adults; customers can be any age.
  int get minimumAge => switch (this) {
    AppRole.retailer || AppRole.rider => 18,
    AppRole.customer || AppRole.admin => 0,
  };
}

/// The day someone born on [birthday] turns [years] (Feb 29 → Mar 1).
DateTime turnsAge(DateTime birthday, int years) =>
    DateTime(birthday.year + years, birthday.month, birthday.day);

/// [years] ago today, at midnight.
DateTime yearsAgo(int years, {DateTime? now}) {
  final today = now ?? DateTime.now();
  return DateTime(today.year - years, today.month, today.day);
}

/// The product each role signs into, now that every role ships as its own
/// app.
extension AppRoleApp on AppRole {
  String get appName => switch (this) {
    AppRole.customer => 'EDoorStep',
    AppRole.retailer => 'EDS Merchant',
    AppRole.rider => 'EDS Rider',
    AppRole.admin => 'EDS Admin',
  };
}
