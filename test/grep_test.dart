import 'package:test/test.dart';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import 'package:noh_shell/commands/grep.dart';

void main() {
  group('Grep command tests', () {
    late ShellEnv env;
    late Grep grepCommand;
    late Directory tempDir;
    late File testFile;

    setUp(() {
      env = ShellEnv();
      grepCommand = Grep(arguments: [], env: env);
      tempDir = Directory.systemTemp.createTempSync('grep_test_');
      testFile = File('${tempDir.path}/test.txt');
      testFile.writeAsStringSync('''
Line 1: Hello World
Line 2: Test line
Line 3: Another Hello
Line 4: Final line
''');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Grep with matching pattern', () async {
      grepCommand = Grep(arguments: ['Hello', testFile.path], env: env);
      final result = await grepCommand.execute();
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('1: Line 1: Hello World'));
      expect(result.stdout, contains('3: Line 3: Another Hello'));
      expect(result.stdout, contains('2 match(es) found'));
    });

    test('Grep with non-matching pattern', () async {
      grepCommand = Grep(arguments: ['NotFound', testFile.path], env: env);
      final result = await grepCommand.execute();
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('0 match(es) found'));
    });

    test('Grep with non-existent file', () async {
      grepCommand = Grep(arguments: ['pattern', '${tempDir.path}/nonexistent.txt'], env: env);
      final result = await grepCommand.execute();
      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('File not found'));
    });

    test('Grep with insufficient arguments', () async {
      grepCommand = Grep(arguments: ['pattern'], env: env);
      final result = await grepCommand.execute();
      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Usage: grep <pattern> <file>'));
    });

    test('Copy method', () {
      final copiedCommand = grepCommand.copy(arguments: ['new', 'args']);
      expect(copiedCommand, isA<Grep>());
      expect(copiedCommand.arguments, equals(['new', 'args']));
      expect(copiedCommand.env, equals(env));
    });
  });
}
