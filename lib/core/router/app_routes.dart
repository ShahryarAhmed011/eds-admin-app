/// Every route path in the app. Modules own their GoRoute definitions but
/// read paths from here so any screen can navigate to any other.
abstract final class AppRoutes {
  static const splash = '/';

  // Shared · auth
  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const otpVerification = '/auth/otp';

  /// Verifying the signed-in account's phone or email (onboarding).
  static const verifyPhone = '/onboarding/verify-phone';
  static const verifyEmail = '/onboarding/verify-email';

  /// Onboarding "Complete your profile".
  static const completeProfile = '/onboarding/profile';

  /// Onboarding "Create your shop" (retailers).
  static const createShop = '/onboarding/store';

  /// Onboarding identity check (retailers and riders).
  static const verifyIdentity = '/onboarding/kyc';
  static const profile = '/profile';

  // Shared · location
  static const locationCountry = '/location/country';

  // Customer
  static const customerHome = '/customer/home';
  static const customerSearch = '/customer/search';
  static const customerCompareNearby = '/customer/compare';
  static const customerProduct = '/customer/product';
  static const customerShop = '/customer/shop';
  static const customerCart = '/customer/cart';
  static const customerCheckout = '/customer/checkout';
  static const customerOrders = '/customer/orders';

  /// Order tracking / detail: `/customer/orders/detail?id=<order_id>`.
  static const customerOrderDetail = '/customer/orders/detail';
  static const customerAccount = '/customer/account';
  static const customerAddressBook = '/customer/addresses';
  static const customerEditAddress = '/customer/addresses/edit';
  static const customerUnservedArea = '/customer/unserved';

  // Retailer · shop & onboarding
  /// Shows draft, live or paused content based on the shop's status.
  static const retailerHome = '/retailer/home';
  static const retailerKycSubmission = '/retailer/kyc';
  static const retailerKycUnderReview = '/retailer/kyc/review';
  static const retailerKycRejected = '/retailer/kyc/rejected';
  static const retailerShopStatusGuide = '/retailer/shop/status-guide';
  static const retailerAccount = '/retailer/account';

  // Retailer · orders
  static const retailerOrders = '/retailer/orders';

  /// Retailer order detail: `/retailer/orders/detail?id=<order_id>`.
  static const retailerOrderDetail = '/retailer/orders/detail';

  // Retailer · catalogue & products
  static const retailerGlobalCatalogue = '/retailer/catalogue';
  static const retailerCatalogueReview = '/retailer/catalogue/review';
  static const retailerBulkAddSelection = '/retailer/catalogue/bulk-add';
  static const retailerBulkAddResults = '/retailer/catalogue/bulk-add/results';
  static const retailerScanBarcode = '/retailer/catalogue/scan';
  static const retailerMyProducts = '/retailer/products';
  static const retailerBulkRepriceEditor = '/retailer/products/reprice';
  static const retailerBulkRepriceResults =
      '/retailer/products/reprice/results';
  static const retailerProductRequests = '/retailer/requests';
  static const retailerProductRequestForm = '/retailer/requests/new';

  // Rider
  static const riderHome = '/rider/home';
  static const riderDeliveries = '/rider/deliveries';

  /// Rider job execution: `/rider/deliveries/job?id=<order_id>`.
  static const riderJobDetail = '/rider/deliveries/job';
  static const riderCash = '/rider/cash';
  static const riderEarnings = '/rider/earnings';
  static const riderAccount = '/rider/account';
  static const riderKycSubmission = '/rider/kyc';
  static const riderKycUnderReview = '/rider/kyc/review';
  static const riderKycRejected = '/rider/kyc/rejected';

  // Admin · operations
  /// Admin home: quick actions (KYC reviews first).
  static const adminHome = '/admin/home';
  static const adminQueues = '/admin/queues';
  static const adminKycReviewList = '/admin/kyc';
  static const adminKycApplicantDetail = '/admin/kyc/detail';
  static const adminUsers = '/admin/users';
  static const adminUserDetail = '/admin/users/detail';
  static const adminShops = '/admin/shops';
  static const adminShopDetail = '/admin/shops/detail';
  static const adminMore = '/admin/more';

  // Admin · catalogue & settings
  static const adminCatalogueVariants = '/admin/catalogue';
  static const adminCatalogueVariantDetail = '/admin/catalogue/detail';
  static const adminProductRequests = '/admin/requests';
  static const adminProductRequestDetail = '/admin/requests/detail';
  static const adminScraperDashboard = '/admin/scraper';
  static const adminServiceableAreas = '/admin/areas';
  static const adminAuditLog = '/admin/audit';

  // System states
  static const systemSubmissionSuccess = '/system/success';
}
