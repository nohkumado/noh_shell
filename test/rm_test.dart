import 'package:test/test.dart';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import 'package:noh_shell/commands/rm.dart';

void main() {
  group('Rm command tests', () {
    late ShellEnv env;
    late Rm rmCommand;
    late Directory tempDir;

    setUp(() {
      env = ShellEnv();
      rmCommand = Rm(arguments: [], env: env);
      tempDir = Directory.systemTemp.createTempSync('rm_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Remove a file', () async {
      final file = File('${tempDir.path}/test_file.txt');
      file.writeAsStringSync('Test content');

      rmCommand = Rm(arguments: [file.path], env: env);
      final result = await rmCommand.execute();

      expect(result.exitCode, equals(0));
      expect(file.existsSync(), isFalse);
    });

    test('Remove an empty directory', () async {
      final dir = Directory('${tempDir.path}/empty_dir');
      dir.createSync();

      rmCommand = Rm(arguments: ['-r', dir.path], env: env);
      final result = await rmCommand.execute();

      expect(result.exitCode, equals(0));
      expect(dir.existsSync(), isFalse);
    });

    test('Remove a directory with contents', () async {
      final dir = Directory('${tempDir.path}/full_dir');
      dir.createSync();
      File('${dir.path}/file.txt').writeAsStringSync('content');

      rmCommand = Rm(arguments: ['-r', dir.path], env: env);
      final result = await rmCommand.execute();

      expect(result.exitCode, equals(0));
      expect(dir.existsSync(), isFalse);
    });

    test('Fail to remove directory without -r flag', () async {
      final dir = Directory('${tempDir.path}/dir');
      dir.createSync();

      rmCommand = Rm(arguments: [dir.path], env: env);
      final result = await rmCommand.execute();

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Is a directory'));
      expect(dir.existsSync(), isTrue);
    });

    test('Remove multiple items', () async {
      final file1 = File('${tempDir.path}/file1.txt')..writeAsStringSync('content');
      final file2 = File('${tempDir.path}/file2.txt')..writeAsStringSync('content');

      rmCommand = Rm(arguments: [file1.path, file2.path], env: env);
      final result = await rmCommand.execute();

      expect(result.exitCode, equals(0));
      expect(file1.existsSync(), isFalse);
      expect(file2.existsSync(), isFalse);
    });

    test('Fail to remove non-existent file', () async {
      final nonExistentFile = '${tempDir.path}/non_existent.txt';

      rmCommand = Rm(arguments: [nonExistentFile], env: env);
      final result = await rmCommand.execute();

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Failed to remove'));
    });
  });
}
