import 'package:noh_shell/commands/cd.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Cd command tests', () {
    test('Change to existing directory', () async {
      final tempDir = Directory.systemTemp.createTempSync('cd_test_');
      final cd = Cd(arguments: [tempDir.path]);
      final result = await cd.execute();

      expect(result.exitCode, equals(0));
      expect(result.stdout.trim(), equals(tempDir.absolute.path));

      tempDir.deleteSync(recursive: true);
    });

    test('Change to home directory when no arguments', () async {
      final cd = Cd(arguments: []);
      final result = await cd.execute();

      String expectedHome = Platform.environment['HOME']
          ?? Platform.environment['USERPROFILE']
          ?? '.';

      expect(result.exitCode, equals(0));
      expect(result.stdout.trim(), isNotEmpty);
    });

    test('Attempt to change to non-existent directory', () async {
      final cd = Cd(arguments: ['/non/existent/path']);
      final result = await cd.execute();

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('No such file or directory'));
    });
  });
}
