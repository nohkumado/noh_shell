class BinaryNumber {
  late List<bool> bits;

  BinaryNumber( {int? value, int length = 8}) {
    bits = List<bool>.filled(length, false);
    if(value != null) bits = fromInt(value,length:length);
  }
  operator [](int index) {
    return bits[index];
  }
  operator []=(int index, int value)
  {
    if (index >= 0 && index < bits.length) bits[index] = value == 1;
  }

  int toInt() {
    int result = 0;
    for (int i = 0; i < bits.length; i++) {
      if (bits[i]) {
        result |= 1 << (bits.length - 1 - i);
      }
    }
    return result;
  }
 String toHex() {
    int value = toInt();
    return '0x${value.toRadixString(16).padLeft((bits.length + 3) ~/ 4, '0')}';
  }
  @override
  String toString() {
    return bits.map((b) => b ? '1' : '0').join('');
  }
    static List<bool> fromInt(int value, {int length = 8}) {
    List<bool> result = List<bool>.filled(length, false);
    for (int i = 0; i < length; i++) {
      result[length - 1 - i] = ((value >> i) & 1) == 1;
    }
    return result;
  }
   static BinaryNumber fromHex(String hexString, {int? length}) {
    // Remove '0x' prefix if present
    hexString = hexString.toLowerCase().replaceFirst(RegExp(r'^0x'), '');

    // Parse the hex string to an integer
    int value = int.parse(hexString, radix: 16);

    // Calculate length if not provided
    length ??= hexString.length * 4;

    return BinaryNumber(value:value, length: length);
  }
}

