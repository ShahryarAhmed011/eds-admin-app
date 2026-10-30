import '../../../../../core/core.dart';
import '../dto/admin_user_dto.dart';
import 'admin_users_data_source.dart';

/// Figma data in the `GET /admin/users` shape, filtered like the server.
class AdminUsersDummyDataSource implements AdminUsersDataSource {
  static const List<Json> _rows = [
    {
      'id': 'USR-088',
      'fullName': 'Bilal Hassan',
      'email': 'bilal.hassan@example.com',
      'role': 'retailer',
      'status': 'flagged',
      'onboardingStatus': 'live',
      'createdAt': '2026-09-02T10:15:00+05:00',
      'phone': '+92 302 4567890',
      'location': 'Rawalpindi · Satellite Town',
      'flagReason': 'Stock complaints',
      'severity': 'high',
      'alertTitle': 'Repeated stock complaints',
      'alertMessage':
          '3 reports in the past 7 days. Last report: 15 Oct, 4:10 pm. '
          'Review before taking action.',
      'shopId': 'SH-032',
      'shopName': 'Bilal General Store',
      'shopStatusLabel': 'Shop currently suspended',
      'identityVerifiedAt': '2026-09-03T11:00:00+05:00',
      'lastSignInAt': '2026-10-16T08:20:00+05:00',
    },
    {
      'id': 'USR-109',
      'fullName': 'Imran Raza',
      'email': 'imran.raza@example.com',
      'role': 'rider',
      'status': 'flagged',
      'onboardingStatus': 'kyc_under_review',
      'createdAt': '2026-10-11T09:00:00+05:00',
      'phone': '+92 345 1122334',
      'location': 'Islamabad · G-11/2',
      'flagReason': 'Duplicate account',
      'severity': 'high',
      'alertTitle': 'Possible duplicate account',
      'alertMessage': 'Same device as USR-097. Review before taking action.',
      'lastSignInAt': '2026-10-16T07:55:00+05:00',
    },
    {
      'id': 'USR-164',
      'fullName': 'Sadia Noor',
      'email': 'sadia.noor@example.com',
      'role': 'customer',
      'status': 'flagged',
      'onboardingStatus': 'complete',
      'createdAt': '2026-09-28T18:30:00+05:00',
      'phone': '+92 312 9988776',
      'location': 'Islamabad · G-10/3',
      'flagReason': 'Access review',
      'severity': 'medium',
      'alertTitle': 'Access review requested',
      'alertMessage': 'Multiple failed sign-in attempts on 15 Oct.',
      'lastSignInAt': '2026-10-15T21:12:00+05:00',
    },
    {
      'id': 'USR-052',
      'fullName': 'Kamran Shah',
      'email': 'kamran.shah@example.com',
      'role': 'retailer',
      'status': 'suspended',
      'onboardingStatus': 'live',
      'createdAt': '2026-08-14T12:00:00+05:00',
      'phone': '+92 300 4455667',
      'location': 'Islamabad · G-9/4',
      'flagReason': 'Misleading listings',
      'alertTitle': 'Account suspended',
      'alertMessage': 'Suspended on 12 Oct for misleading listings.',
      'identityVerifiedAt': '2026-08-16T10:00:00+05:00',
      'lastSignInAt': '2026-10-12T18:40:00+05:00',
    },
    {
      'id': 'USR-071',
      'fullName': 'Ayesha Khan',
      'email': 'ayesha.khan@example.com',
      'role': 'rider',
      'status': 'suspended',
      'onboardingStatus': 'kyc_approved',
      'createdAt': '2026-08-20T15:00:00+05:00',
      'phone': '+92 333 2233445',
      'location': 'Islamabad · G-11/4',
      'flagReason': 'Repeated no-shows',
      'alertTitle': 'Account suspended',
      'alertMessage': 'Suspended on 10 Oct after repeated no-shows.',
      'identityVerifiedAt': '2026-08-22T10:00:00+05:00',
      'lastSignInAt': '2026-10-10T13:15:00+05:00',
    },
  ];

  @override
  Future<List<AdminUserDto>> fetchUsers({
    String? status,
    String? role,
    String? query,
    int limit = 50,
  }) async {
    await dummyDelay();
    final q = query?.trim().toLowerCase() ?? '';
    return [
      for (final row in _rows)
        if ((status == null || row['status'] == status) &&
            (role == null || row['role'] == role) &&
            (q.isEmpty ||
                '${row['fullName']} ${row['email']} ${row['id']} '
                        '${row['phone']}'
                    .toLowerCase()
                    .contains(q)))
          AdminUserDto.fromJson(row),
    ].take(limit).toList();
  }

  @override
  Future<AdminUserDto> updateStatus({
    required String id,
    required String status,
    required String reason,
  }) async {
    await dummyDelay();
    final row = _rows.firstWhere(
      (r) => r['id'] == id,
      orElse: () => throw const ApiException(
        status: 404,
        code: ApiErrorCode.notFound,
        message: 'User not found.',
      ),
    );
    return AdminUserDto.fromJson({...row, 'status': status});
  }
}
