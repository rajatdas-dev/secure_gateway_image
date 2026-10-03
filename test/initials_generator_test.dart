import 'package:flutter_test/flutter_test.dart';

import 'package:secure_gateway_image/src/utils/initials_generator.dart';

void main() {
  group('generateInitials', () {
    test('generates initials from first and last words', () {
      expect(generateInitials('Rajat Das'), 'RD');
    });

    test('uses first character for a single word', () {
      expect(generateInitials('Rajat'), 'R');
    });

    test('handles extra whitespace', () {
      expect(generateInitials('  Rajat   Das  '), 'RD');
    });

    test('returns question mark for empty input', () {
      expect(generateInitials(''), '?');

      expect(generateInitials(null), '?');
    });
  });
}
