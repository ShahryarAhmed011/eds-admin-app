/// Pakistani mobile numbers as the API expects them: a `+92` country code
/// and the national digits (e.g. `3001234567`).
abstract final class PhoneNumber {
  static const countryCode = '+92';

  /// Pakistan flag emoji shown beside [countryCode].
  static const countryFlag = '🇵🇰';

  /// National digits from any user input: drops spaces, `+92`/`92` and a
  /// leading trunk `0`.
  static String nationalDigits(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (input.trim().startsWith('+92') ||
        (digits.startsWith('92') && digits.length > 10)) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  /// National digits in a Pakistani mobile number.
  static const nationalLength = 10;

  /// "300-1234567" for the national part of a number.
  static String formatNational(String digits) => digits.length > 3
      ? '${digits.substring(0, 3)}-${digits.substring(3)}'
      : digits;

  /// "+92 300-1234567". Empty when there is no number.
  static String format(String? countryCode, String? number) {
    if (number == null || number.isEmpty) return '';
    final code = (countryCode == null || countryCode.isEmpty)
        ? PhoneNumber.countryCode
        : countryCode;
    return '$code ${formatNational(nationalDigits(number))}';
  }
}
