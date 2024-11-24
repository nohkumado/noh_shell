import 'package:test/test.dart';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import 'package:noh_shell/commands/cp.dart';

void main() {
  group('Cp command tests', () {
    late ShellEnv env;
    late Cp cpCommand;
    late Directory tempDir;

    setUp(() {
      env = ShellEnv();
      cpCommand = Cp(arguments: [], env: env);
      tempDir = Directory.systemTemp.createTempSync('cp_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Copy a single file', () async {
      final sourceFile = File('${tempDir.path}/source.txt')..writeAsStringSync('Test content');
      final destFile = '${tempDir.path}/dest.txt';

      cpCommand = Cp(arguments: [sourceFile.path, destFile], env: env);
      final result = await cpCommand.execute();

      expect(result.exitCode, equals(0));
      expect(File(destFile).existsSync(), isTrue);
      expect(File(destFile).readAsStringSync(), equals('Test content'));
    });

    test('Copy multiple files to a directory', () async {
      final sourceFile1 = File('${tempDir.path}/source1.txt')..writeAsStringSync('Content 1');
      final sourceFile2 = File('${tempDir.path}/source2.txt')..writeAsStringSync('Content 2');
      final destDir = Directory('${tempDir.path}/dest')..createSync();

      cpCommand = Cp(arguments: [sourceFile1.path, sourceFile2.path, destDir.path], env: env);
      final result = await cpCommand.execute();

      expect(result.exitCode, equals(0));
      expect(File('${destDir.path}/source1.txt').readAsStringSync(), equals('Content 1'));
      expect(File('${destDir.path}/source2.txt').readAsStringSync(), equals('Content 2'));
    });

    test('Copy a directory recursively', () async {
      final sourceDir = Directory('${tempDir.path}/source')..createSync();
      File('${sourceDir.path}/file1.txt').writeAsStringSync('Content 1');
      Directory('${sourceDir.path}/subdir').createSync();
      File('${sourceDir.path}/subdir/file2.txt').writeAsStringSync('Content 2');

      final destDir = '${tempDir.path}/dest';

      cpCommand = Cp(arguments: ['-r', sourceDir.path, destDir], env: env);
      final result = await cpCommand.execute();

      expect(result.exitCode, equals(0));
      expect(Directory(destDir).existsSync(), isTrue);
      expect(File('$destDir/file1.txt').readAsStringSync(), equals('Content 1'));
      expect(File('$destDir/subdir/file2.txt').readAsStringSync(), equals('Content 2'));
    });

    test('Fail to copy directory without -r flag', () async {
      final sourceDir = Directory('${tempDir.path}/source')..createSync();
      final destDir = '${tempDir.path}/dest';

      cpCommand = Cp(arguments: [sourceDir.path, destDir], env: env);
      final result = await cpCommand.execute();

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('omitting directory'));
    });

    test('Copy to existing file', () async {
      final sourceFile = File('${tempDir.path}/source.txt')..writeAsStringSync('New content');
      final destFile = File('${tempDir.path}/dest.txt')..writeAsStringSync('Old content');

      cpCommand = Cp(arguments: [sourceFile.path, destFile.path], env: env);
      final result = await cpCommand.execute();

      expect(result.exitCode, equals(0));
      expect(destFile.readAsStringSync(), equals('New content'));
    });

    test('Copy non-existent file', () async {
      final nonExistentFile = '${tempDir.path}/nonexistent.txt';
      final destFile = '${tempDir.path}/dest.txt';

      cpCommand = Cp(arguments: [nonExistentFile, destFile], env: env);
      final result = await cpCommand.execute();

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Failed to copy'));
    });

    test('Copy with insufficient arguments', () async {
      cpCommand = Cp(arguments: ['single_arg'], env: env);
      final result = await cpCommand.execute();

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Usage:'));
    });
  });
}
