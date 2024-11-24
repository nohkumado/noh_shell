import 'package:test/test.dart';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import 'package:noh_shell/commands/mv.dart';

void main() {
  group('Mv command tests', () {
    late ShellEnv env;
    late Mv mvCommand;
    late Directory tempDir;

    setUp(() {
      env = ShellEnv();
      mvCommand = Mv(arguments: [], env: env);
      tempDir = Directory.systemTemp.createTempSync('mv_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Rename a file', () async {
      final sourceFile = File('${tempDir.path}/source.txt')..writeAsStringSync('Test content');
      final destFile = '${tempDir.path}/dest.txt';

      mvCommand = Mv(arguments: [sourceFile.path, destFile], env: env);
      final result = await mvCommand.execute();

      expect(result.exitCode, equals(0));
      expect(File(destFile).existsSync(), isTrue);
      expect(sourceFile.existsSync(), isFalse);
    });

    test('Move a file to a directory', () async {
      final sourceFile = File('${tempDir.path}/source.txt')..writeAsStringSync('Test content');
      final destDir = Directory('${tempDir.path}/dest')..createSync();

      mvCommand = Mv(arguments: [sourceFile.path, destDir.path], env: env);
      final result = await mvCommand.execute();

      expect(result.exitCode, equals(0));
      expect(File('${destDir.path}/source.txt').existsSync(), isTrue);
      expect(sourceFile.existsSync(), isFalse);
    });

    test('Move multiple files to a directory', () async {
      final sourceFile1 = File('${tempDir.path}/source1.txt')..writeAsStringSync('Content 1');
      final sourceFile2 = File('${tempDir.path}/source2.txt')..writeAsStringSync('Content 2');
      final destDir = Directory('${tempDir.path}/dest')..createSync();

      mvCommand = Mv(arguments: [sourceFile1.path, sourceFile2.path, destDir.path], env: env);
      final result = await mvCommand.execute();

      expect(result.exitCode, equals(0));
      expect(File('${destDir.path}/source1.txt').existsSync(), isTrue);
      expect(File('${destDir.path}/source2.txt').existsSync(), isTrue);
      expect(sourceFile1.existsSync(), isFalse);
      expect(sourceFile2.existsSync(), isFalse);
    });

    test('Move a directory', () async {
      final sourceDir = Directory('${tempDir.path}/source')..createSync();
      File('${sourceDir.path}/file.txt').writeAsStringSync('Test content');
      final destDir = '${tempDir.path}/dest';

      mvCommand = Mv(arguments: [sourceDir.path, destDir], env: env);
      final result = await mvCommand.execute();

      expect(result.exitCode, equals(0));
      expect(Directory(destDir).existsSync(), isTrue);
      expect(File('$destDir/file.txt').existsSync(), isTrue);
      expect(sourceDir.existsSync(), isFalse);
    });

    test('Fail to move non-existent file', () async {
      final nonExistentFile = '${tempDir.path}/nonexistent.txt';
      final destFile = '${tempDir.path}/dest.txt';

      mvCommand = Mv(arguments: [nonExistentFile, destFile], env: env);
      final result = await mvCommand.execute();

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Failed to move'));
    });
  });
}
