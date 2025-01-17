import 'binary_number.dart';

class FilePerm extends BinaryNumber {
  FilePerm() : super( length: 12);

  FilePerm.fromString(String mode) : super( length: 12) {
    if (RegExp(r'^\d+$').hasMatch(mode)) {
      _setFromOctal(int.parse(mode, radix: 8));
    }
    else _parseMode(mode);
  }
  FilePerm.fromInt(int mode) : super( length: 12) {
    _setFromOctal(mode);
   // int u = mode ~/ 100;
   // int g = ((mode - u) ~/ 10);
   // int o = (mode - u - g);
   // bits = [
   //   u & 4, u & 2, u & 1,
   //   g & 4, g & 2, g & 1,
   //   o & 4, o & 2, o & 1,
   // ].map((bit) => bit == 1).toList();
  }
  void _setFromOctal(int mode) {
    for (int i = 0; i < 12; i++) {
      bits[11 - i] = ((mode >> i) & 1) == 1;
    }
  }

  void _parseMode(String mode) {
    //print("incoming parse: $mode")// Split the input into individual symbolic mode components
    List<String> components = mode.split(',');
    if(components.length == 1 && RegExp(r'^([-rwxXst]*)$').hasMatch(mode))
      {
        print("bastard string : $mode");


      }

    // Define a regex for a single symbolic mode
    final RegExp chmodRegex = RegExp(r'^([ugoa]*)([=+-])([rwxXst]*)$');;
    for (String component in components) {
      component = component.trim(); // Remove any whitespace


      Iterable<RegExpMatch> matches = chmodRegex.allMatches(component);

      if (matches.isEmpty) {
        throw FormatException("Invalid mode format: $mode");
      }
      //final RegExp chmodRegex = RegExp(r'([ugoa]*)([=+-])([rwxXst-]*)');
      //Iterable<RegExpMatch> matches = chmodRegex.allMatches(mode);
      print("num of matches: ${matches.length}");

      for (var match in matches) {
        //print("treating group: $match");
        String categories = match.group(1) ?? 'a';
        String operator = match.group(2) ?? '+';
        String permTypes = match.group(3)!;
        print("splitted into : $categories, $operator, $permTypes in $bits");

        bool treated = false;
        if (categories.contains('u') || categories.contains('a')) {
          treated = true;
          _setPerm(operator, 3, permTypes);
        }
        if (categories.contains('g') || categories.contains('a')) {
          treated = true;
          _setPerm(operator, 6, permTypes);
        }
        if (categories.contains('o') || categories.contains('a')) {
          treated = true;
          _setPerm(operator, 9, permTypes);
        }
        if(!treated)
        {
          print("untrewated   $permTypes");
          if (permTypes.contains('t')) {
            treated = true;
            print("calling set sticky   $permTypes");
            _setPerm(operator, 9, permTypes);
          }
          if (permTypes.contains('s')) {
            treated = true;
            _setPerm(operator, 3, permTypes);
            _setPerm(operator, 6, permTypes);
          }
          if(!treated){
            print("OOOOOY need to do something with $categories, $operator, $permTypes");
          }
        }
        //print("finalized into : $bits");
      }
    }
  }

  void _setPerm(String operator, int pos, String permTypes) {
    if(operator == '=')
    {
      for(int n = pos; n< pos+3; n++) this[n] = 0;
      operator = '+';
    }
    if(operator == '+')
    {
      if (permTypes.contains('r')) this[pos]= 1;
      if (permTypes.contains('w')) this[pos+1] = 1;
      if (permTypes.contains('x')) this[pos+2] = 1;
      if (permTypes.contains('s') && (pos == 3 || pos == 6)) this[pos - 3] = 1;
      if (permTypes.contains('t') && pos == 9) {
        this[2] = 1;
      }
    }
    else if(operator == '-')
    {
      if (permTypes.contains('r')) this[pos]= 0;
      if (permTypes.contains('w')) this[pos+1] = 0;
      if (permTypes.contains('x')) this[pos+2] = 0;
      // Handle special permissions
      if (permTypes.contains('s') && (pos == 3 || pos == 6)) this[pos - 3] = 1;
      if (permTypes.contains('t') && pos == 9) this[2] = 1;
    }
  }

  // Additional methods specific to file permissions
  bool get userCanRead => bits[3];
  bool get userCanWrite => bits[4];
  bool get userCanExecute => bits[5];

  get groupCanRead => bits[6];
  bool get groupCanWrite => bits[7];
  bool get groupCanExecute => bits[8];
    bool get othersCanRead => bits[9];
  bool get othersCanWrite => bits[10];
  bool get othersCanExecute => bits[11];

  get hasSetuid => bits[0];
  get hasSetgid => bits[1];
  get hasSticky => bits[2];


  void setUserRead([bool value = true]) => bits[3] = value;
  void setUserWrite([bool value = true]) => bits[4] = value;
  void setUserExecute([bool value = true]) => bits[5] = value;
  // ... similar setters for group and others

  @override
  String toString() {
    // Implement a string representation of permissions (e.g., "rwxr-xr-x")
    String result = '';

    // Special bits
    //result += bits[0] ? 's' : '-'; // setuid
    //result += bits[1] ? 's' : '-'; // setgid
    //result += bits[2] ? 't' : '-'; // sticky bit

    // User permissions
    result += bits[3] ? 'r' : '-';
    result += bits[4] ? 'w' : '-';
    if (bits[0]) result += bits[5] ? 's':'S';// Execute or setuid
    else result += bits[5] ? 'x' : '-'; // Execute

    // Group permissions
    result += bits[6] ? 'r' : '-';
    result += bits[7] ? 'w' : '-';
    if (bits[1])result += bits[8] ? 's' : 'S'; // Execute or setgid
    else result += bits[8] ? 'x' : '-';

    // Others permissions
    result += bits[9] ? 'r' : '-';
    result += bits[10] ? 'w' : '-';
    if (bits[2])result += bits[11] ? 't' : 'T'; // Execute or sticky
      else result += bits[11] ? 'x' : '-';

    // Adjust special bits display
    //if (bits[0] && !bits[5]) result = result.replaceRange(0, 1, 'S');
    //if (bits[1] && !bits[8]) result = result.replaceRange(1, 2, 'S');
    //if (bits[2] && !bits[11]) result = result.replaceRange(2, 3, 'T');

    return result;
  }

  // String toOctal() {
  //   // Convert the 12 bits into three separate octal digits
  //   int specialBits = (bits[0] ? 4 : 0) + (bits[1] ? 2 : 0) + (bits[2] ? 1 : 0);
  //   int userBits = (bits[3] ? 4 : 0) + (bits[4] ? 2 : 0) + (bits[5] ? 1 : 0);
  //   int groupBits = (bits[6] ? 4 : 0) + (bits[7] ? 2 : 0) + (bits[8] ? 1 : 0);
  //   int otherBits = (bits[9] ? 4 : 0) + (bits[10] ? 2 : 0) + (bits[11] ? 1 : 0);
  //
  //   // Combine them into an octal string
  //   return '${specialBits}${userBits}${groupBits}${otherBits}';
  // }
  String toOctal() {
    // Calculate the special bits as the leading octal digit
    int specialBits = (bits[0] ? 4 : 0) + (bits[1] ? 2 : 0) + (bits[2] ? 1 : 0);

    // Calculate the permission bits for user, group, and others
    int userBits = (bits[3] ? 4 : 0) + (bits[4] ? 2 : 0) + (bits[5] ? 1 : 0);
    int groupBits = (bits[6] ? 4 : 0) + (bits[7] ? 2 : 0) + (bits[8] ? 1 : 0);
    int otherBits = (bits[9] ? 4 : 0) + (bits[10] ? 2 : 0) + (bits[11] ? 1 : 0);

    // Combine them into a standard octal representation
    return '${specialBits!= 0?'${specialBits}':''}${userBits}${groupBits}${otherBits}';
  }
  void setGroupExecute(bool val) {
    bits[8] = val;
  }
}
