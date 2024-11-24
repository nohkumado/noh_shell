import 'package:test/test.dart';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import 'package:noh_shell/commands/chmod.dart';

void main() {
  group('Chmod command tests', () {
    late ShellEnv env;
    late Chmod chmodCommand;
    late Directory tempDir;

    setUp(() {
      env = ShellEnv();
      chmodCommand = Chmod(arguments: [], env: env);
      tempDir = Directory.systemTemp.createTempSync('chmod_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Change file permissions using octal mode', () async {
      final testFile = File('${tempDir.path}/test.txt')..writeAsStringSync('Test content');

      chmodCommand = Chmod(arguments: ['755', testFile.path], env: env);
      final result = await chmodCommand.execute();

      expect(result.exitCode, equals(0));
      final fileMode = testFile.statSync().mode;
      expect(fileMode & 0x1FF, equals(0x1ED)); // 0o755 in octal
    });

    test('Change directory permissions recursively', () async {
      final testDir = Directory('${tempDir.path}/testdir')..createSync();
      final testFile = File('${testDir.path}/test.txt')..writeAsStringSync('Test content');

      chmodCommand = Chmod(arguments: ['-R', '700', testDir.path], env: env);
      final result = await chmodCommand.execute();

      expect(result.exitCode, equals(0));
      final dirMode = testDir.statSync().mode;
      final fileMode = testFile.statSync().mode;
      expect(dirMode & 0x1FF, equals(0x1C0)); // 0o700 in octal
      expect(fileMode & 0x1FF, equals(0x1C0)); // 0o700 in octal
    });

    test('Change permissions using symbolic mode', () async {
      final testFile = File('${tempDir.path}/test.txt')..writeAsStringSync('Test content');

      chmodCommand = Chmod(arguments: ['rwx', testFile.path], env: env);
      final result = await chmodCommand.execute();

      expect(result.exitCode, equals(0));
      final fileMode = testFile.statSync().mode;
      expect(fileMode & 0x1FF, equals(0x1FF)); // 0o777 in octal
    });

    test('Fail to change permissions of non-existent file', () async {
      final nonExistentFile = '${tempDir.path}/nonexistent.txt';

      chmodCommand = Chmod(arguments: ['755', nonExistentFile], env: env);
      final result = await chmodCommand.execute();

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Failed to change mode'));
    });

    test('Change permissions of multiple files', () async {
      final file1 = File('${tempDir.path}/file1.txt')..writeAsStringSync('Content 1');
      final file2 = File('${tempDir.path}/file2.txt')..writeAsStringSync('Content 2');

      chmodCommand = Chmod(arguments: ['644', file1.path, file2.path], env: env);
      final result = await chmodCommand.execute();

      expect(result.exitCode, equals(0));
      expect(file1.statSync().mode & 0x1FF, equals(0x1A4)); // 0o644 in octal
      expect(file2.statSync().mode & 0x1FF, equals(0x1A4)); // 0o644 in octal
    });
  });
}
