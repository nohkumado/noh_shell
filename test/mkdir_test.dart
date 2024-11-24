import 'package:test/test.dart';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import 'package:noh_shell/commands/mkdir.dart';

void main() {
  group('Mkdir command tests', () {
    late ShellEnv env;
    late Mkdir mkdirCommand;
    late Directory tempDir;

    setUp(() {
      env = ShellEnv();
      mkdirCommand = Mkdir(arguments: [], env: env);
      tempDir = Directory.systemTemp.createTempSync('mkdir_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Create a single directory', () async {
      final newDir = '${tempDir.path}/new_directory';
      mkdirCommand = Mkdir(arguments: [newDir], env: env);
      final result = await mkdirCommand.execute();
      expect(result.exitCode, equals(0));
      expect(Directory(newDir).existsSync(), isTrue);
    });

    test('Create multiple directories', () async {
      final dir1 = '${tempDir.path}/dir1';
      final dir2 = '${tempDir.path}/dir2';
      mkdirCommand = Mkdir(arguments: [dir1, dir2], env: env);
      final result = await mkdirCommand.execute();
      expect(result.exitCode, equals(0));
      expect(Directory(dir1).existsSync(), isTrue);
      expect(Directory(dir2).existsSync(), isTrue);
    });

    test('Create nested directories with -p option', () async {
      final nestedDir = '${tempDir.path}/parent/child/grandchild';
      mkdirCommand = Mkdir(arguments: ['-p', nestedDir], env: env);
      final result = await mkdirCommand.execute();
      expect(result.exitCode, equals(0));
      expect(Directory(nestedDir).existsSync(), isTrue);
    });

    test('Fail to create nested directories without -p option', () async {
      final nestedDir = '${tempDir.path}/parent/child/grandchild';
      mkdirCommand = Mkdir(arguments: [nestedDir], env: env);
      final result = await mkdirCommand.execute();
      expect(result.exitCode, equals(1));
      expect(Directory(nestedDir).existsSync(), isFalse);
    });

    test('Mkdir with no arguments', () async {
      mkdirCommand = Mkdir(arguments: [], env: env);
      final result = await mkdirCommand.execute();
      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Usage: mkdir <directory_name>'));
    });

    test('Create directory that already exists', () async {
      final existingDir = '${tempDir.path}/existing';
      Directory(existingDir).createSync();
      mkdirCommand = Mkdir(arguments: [existingDir], env: env);
      final result = await mkdirCommand.execute();
      expect(result.exitCode, equals(1),reason: "mkdir already exists, should return 1");
      expect(result.stderr, contains('mkdir: cannot create director'), reason: "mkdir already exists, should return failed msg");
    });

    test('Copy method', () {
      final copiedCommand = mkdirCommand.copy(arguments: ['new_dir']);
      expect(copiedCommand, isA<Mkdir>());
      expect(copiedCommand.arguments, equals(['new_dir']));
      expect(copiedCommand.env, equals(env));
    });
  });
}
