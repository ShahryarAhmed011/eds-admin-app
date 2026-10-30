import 'package:eds_admin_app/features/shared/auth/domain/entities/auth_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const complete = AuthDraft(
    firstName: 'Ali',
    lastName: 'Khan',
    email: 'user@example.com',
    password: 'Abcd1234',
    phoneNumber: '3001234567',
    acceptedTerms: true,
  );

  test('a complete sign up can be submitted', () {
    expect(complete.hasName, isTrue);
    expect(complete.hasContact, isTrue);
    expect(complete.hasStrongPassword, isTrue);
    expect(complete.canSignUp, isTrue);
  });

  test('each step checks its own fields', () {
    expect(complete.copyWith(lastName: ' ').hasName, isFalse);
    expect(complete.copyWith(email: 'user@').hasContact, isFalse);
    expect(complete.copyWith(phoneNumber: '300123').hasContact, isFalse);
    expect(complete.copyWith(acceptedTerms: false).canSignUp, isFalse);
  });

  test('a password needs 8+ characters with a letter and a number', () {
    expect(complete.copyWith(password: 'Abc123').hasStrongPassword, isFalse);
    expect(complete.copyWith(password: 'abcdefgh').hasStrongPassword, isFalse);
    expect(complete.copyWith(password: '12345678').hasStrongPassword, isFalse);
    expect(complete.copyWith(password: 'abcd1234').hasStrongPassword, isTrue);
  });
}
