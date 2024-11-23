import 'dart:io';

import 'shell_env.dart';

class Prompt {
  ShellEnv env;

  String prform = "> ";

  Prompt({required this.env}) { prform = parsePS1(); }

  String getPrompt() {
    String username = env['USER'] ??Platform.environment['USER'] ?? 'user';
    String hostname = env['HOSTNAME'] ??Platform.environment['HOSTNAME'] ?? 'localhost';
    //String currentDir = Directory.current.path;
    String currentDir = env['PWD'] ??Directory.current.path;
    String homeDir = env['HOME'] ??Platform.environment['HOME'] ?? '/home/$username';

    if (currentDir.startsWith(homeDir)) {
      currentDir = '~' + currentDir.substring(homeDir.length);
    }

    //return '\x1B[1;32m$username@$hostname\x1B[0m:\x1B[1;34m$currentDir\x1B[0m\$ ';
    return prform;
  }

  @override
  String toString() {
    return getPrompt();
  }

  String parsePS1({String? ps1}) {
    if (ps1 == null) { ps1 = '\\u\\h:\\w\$ '; }
    final result = StringBuffer();
    bool escapeNext = false;

    for (int i = 0; i < ps1.length; i++) {
      if (escapeNext) {
        result.write(ps1[i]);
        escapeNext = false;
        continue;
      }

      if (ps1[i] == '\\') {
        if (i + 1 < ps1.length) {
          switch (ps1[i + 1]) {
            case 'u':
              result.write(Platform.environment['USER'] ?? 'user');
              i++;
              break;
            case 'h':
              result.write(Platform.environment['HOSTNAME']?.split('.').first ?? 'localhost');
              i++;
              break;
            case 'w':
              String currentDir = Directory.current.path;
              String homeDir = Platform.environment['HOME'] ?? '/home/${Platform.environment['USER']}';
              if (currentDir.startsWith(homeDir)) {
                currentDir = '~' + currentDir.substring(homeDir.length);
              }
              result.write(currentDir);
              i++;
              break;
            case 'W':
              result.write(Directory.current.path.split(Platform.pathSeparator).last);
              i++;
              break;
            case '\$':
              result.write(Platform.environment['USER'] == 'root' ? '#' : '\$');
              i++;
              break;
            case '[':
              result.write('\x1B');
              i++;
              break;
            case ']':
            // End of color sequence
              i++;
              break;
            default:
              result.write(ps1[i]);
          }
        } else {
          result.write(ps1[i]);
        }
      } else {
        result.write(ps1[i]);
      }
    }

    return result.toString();
  }
}
