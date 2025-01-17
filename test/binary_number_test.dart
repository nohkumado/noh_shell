import 'package:noh_shell/utils/binary_number.dart';
import 'package:test/test.dart';

void main() {
  group('BinaryNumber', () {
    test('Constructor with default length', () {
      var binary = BinaryNumber(value: 12);
      expect(binary.toString(), equals('00001100'));
      expect(binary.toInt(), equals(12));
    });

    test('Constructor with custom length', () {
      var binary = BinaryNumber(value: 12, length: 16);
      expect(binary.toString(), equals('0000000000001100'));
      expect(binary.toInt(), equals(12));
    });

    test('fromHex constructor', () {
      var binary = BinaryNumber.fromHex('0xFF');
      expect(binary.toString(), equals('11111111'));
      expect(binary.toInt(), equals(255));
    });

    test('fromHex constructor with custom length', () {
      var binary = BinaryNumber.fromHex('FF', length: 16);
      expect(binary.toString(), equals('0000000011111111'));
      expect(binary.toInt(), equals(255));
    });

    test('toHex method', () {
      var binary = BinaryNumber(value: 255);
      expect(binary.toHex(), equals('0xff'));
    });

    test('toHex method with leading zeros', () {
      var binary = BinaryNumber(value: 15, length: 16);
      expect(binary.toHex(), equals('0x000f'));
    });

    test('fromInt static method', () {
      var bits = BinaryNumber.fromInt(123, length: 8);
      expect(bits, equals([false, true, true, true, true, false, true, true]));
    });

    test('Edge case: zero', () {
      var binary = BinaryNumber(value: 0);
      expect(binary.toString(), equals('00000000'));
      expect(binary.toInt(), equals(0));
      expect(binary.toHex(), equals('0x00'));
    });

    test('Edge case: maximum value for 8 bits', () {
      var binary = BinaryNumber(value: 255);
      expect(binary.toString(), equals('11111111'));
      expect(binary.toInt(), equals(255));
      expect(binary.toHex(), equals('0xff'));
    });

    test('Edge case: value exceeding bit length', () {
      var binary = BinaryNumber(value: 256, length: 8);
      expect(binary.toString(), equals('00000000'));
      expect(binary.toInt(), equals(0));
    });
  });
}
