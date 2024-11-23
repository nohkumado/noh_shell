import 'package:noh_shell/commands/ls.dart';
import 'package:noh_shell/shell_env.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Ls command tests', () {
    test('List current directory', () async {
      final ls = Ls(arguments: [], env: ShellEnv());
      final result = await ls.execute();
      expect(result.exitCode, equals(0));
      expect(result.stdout, isNotEmpty);
    });

    test('List non-existent directory', () async {
      final ls = Ls(arguments: ['/non/existent/path'], env: ShellEnv());
      final result = await ls.execute();
      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Directory does not exist'));
    });

    test('List specific directory', () async {
      final tempDir = Directory.systemTemp.createTempSync('ls_test_');
      final ls = Ls(arguments: [tempDir.path], env: ShellEnv());
      final result = await ls.execute(debug: false);
      expect(result.exitCode, equals(0));
      expect(result.stdout, isEmpty);
      tempDir.deleteSync(recursive: true);
    });
  });
}