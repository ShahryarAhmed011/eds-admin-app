import '../../../../../core/core.dart';

/// Form prefill. Not an API payload: sample data from the dummy source, or
/// the test account in debug builds.
class AuthDraftDto {
  const AuthDraftDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.acceptedTerms,
  });

  factory AuthDraftDto.fromJson(Json json) => AuthDraftDto(
    firstName: json.strOr('firstName'),
    lastName: json.strOr('lastName'),
    email: json.strOr('email'),
    password: json.strOr('password'),
    phoneNumber: json.strOr('phoneNumber'),
    acceptedTerms: json.boolean('acceptedTerms'),
  );

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phoneNumber;
  final bool acceptedTerms;
}
