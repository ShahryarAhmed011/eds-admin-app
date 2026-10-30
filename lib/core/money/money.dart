import 'package:equatable/equatable.dart';

/// An amount in paisa, the API's only money representation.
/// `Money(64500).format()` → `Rs 645`. Never use doubles for money.
class Money extends Equatable implements Comparable<Money> {
  const Money(this.paisa);

  const Money.rupees(int rupees) : paisa = rupees * 100;

  static const zero = Money(0);

  /// Parses user input like "1,250" or "1250.50" into paisa.
  static Money? tryParseRupees(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(cleaned);
    return value == null ? null : Money((value * 100).round());
  }

  final int paisa;

  int get wholeRupees => paisa ~/ 100;

  /// `Rs 1,250` (or `Rs 1,250.50` when there are paisa).
  String format({String symbol = 'Rs'}) {
    final rupees = _groupThousands(paisa.abs() ~/ 100);
    final remainder = paisa.abs() % 100;
    final fraction = remainder == 0
        ? ''
        : '.${remainder.toString().padLeft(2, '0')}';
    return '${paisa < 0 ? '-' : ''}$symbol $rupees$fraction';
  }

  /// Plain rupee amount without symbol, for prefilling inputs ("1250").
  String toInputText() =>
      paisa % 100 == 0 ? '${paisa ~/ 100}' : (paisa / 100).toStringAsFixed(2);

  Money operator +(Money other) => Money(paisa + other.paisa);
  Money operator -(Money other) => Money(paisa - other.paisa);

  @override
  int compareTo(Money other) => paisa.compareTo(other.paisa);

  @override
  List<Object?> get props => [paisa];

  @override
  String toString() => format();

  static String _groupThousands(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
