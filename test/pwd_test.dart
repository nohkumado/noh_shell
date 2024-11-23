import 'package:noh_shell/commands/pwd.dart';
import 'package:noh_shell/shell_env.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Pwd command tests', () {
    test('Print current working directory', () async {
      final pwd = Pwd(arguments: [], env: ShellEnv());
      final result = await pwd.execute();

      // Get the expected current directory
      String expectedDirectory = Directory.current.path;

      expect(result.exitCode, equals(0));
      expect(result.stdout.trim(), equals(expectedDirectory));
    });
  });
}
