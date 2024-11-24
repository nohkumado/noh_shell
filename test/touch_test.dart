import 'package:test/test.dart';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import 'package:noh_shell/commands/touch.dart';

void main() {
  group('Touch command tests', () {
    late ShellEnv env;
    late Touch touchCommand;
    late Directory tempDir;

    setUp(() {
      env = ShellEnv();
      touchCommand = Touch(arguments: [], env: env);
      tempDir = Directory.systemTemp.createTempSync('touch_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Create new file', () async {
      final newFile = '${tempDir.path}/new_file.txt';
      touchCommand = Touch(arguments: [newFile], env: env);
      final result = await touchCommand.execute();
      expect(result.exitCode, equals(0));
      expect(File(newFile).existsSync(), isTrue);
    });

    test('Update existing file', () async {
      final existingFile = '${tempDir.path}/existing_file.txt';
      File(existingFile).writeAsStringSync('Test content');
      final initialModTime = File(existingFile).lastModifiedSync();

      await Future.delayed(Duration(seconds: 1)); // Ensure time difference

      touchCommand = Touch(arguments: [existingFile], env: env);
      final result = await touchCommand.execute();
      expect(result.exitCode, equals(0));
      expect(File(existingFile).lastModifiedSync().isAfter(initialModTime), isTrue);
    });

    test('Touch multiple files', () async {
      final file1 = '${tempDir.path}/file1.txt';
      final file2 = '${tempDir.path}/file2.txt';
      touchCommand = Touch(arguments: [file1, file2], env: env);
      final result = await touchCommand.execute();
      expect(result.exitCode, equals(0));
      expect(File(file1).existsSync(), isTrue);
      expect(File(file2).existsSync(), isTrue);
    });

    test('Touch with no arguments', () async {
      touchCommand = Touch(arguments: [], env: env);
      final result = await touchCommand.execute();
      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Usage: touch <filename>'));
    });

    test('Touch non-existent directory', () async {
      final nonExistentPath = '${tempDir.path}/non_existent_dir/file.txt';
      touchCommand = Touch(arguments: [nonExistentPath], env: env);
      final result = await touchCommand.execute();
      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Error touching file'));
    });

    test('Copy method', () {
      final copiedCommand = touchCommand.copy(arguments: ['new_file.txt']);
      expect(copiedCommand, isA<Touch>());
      expect(copiedCommand.arguments, equals(['new_file.txt']));
      expect(copiedCommand.env, equals(env));
    });
  });
}
