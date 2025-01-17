import 'package:noh_shell/shell.dart';
import 'package:test/test.dart';
import 'dart:io';


void main() {
  group('Shell Tests', () {
    late Shell shell;
    late Directory tempDir;

    setUp(() {
      shell = Shell();
      tempDir = Directory.systemTemp.createTempSync('shell_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Basic command execution', () async {
      final result = await shell.processCommand('pwd');
      expect(result.exitCode, equals(0));
      expect(result.stdout, isNotEmpty);
    });

    test('Command with arguments', () async {
      File('${tempDir.path}/test.txt').writeAsStringSync('Hello, World!');
      final result = await shell.processCommand('cat ${tempDir.path}/test.txt');
      expect(result.exitCode, equals(0));
      expect(result.stdout, equals('Hello, World!'));
    });

    test('Unknown command', () async {
      final result = await shell.processCommand('unknown_command');
      expect(result.exitCode, equals(1),reason: 'Expected exit code 1 for unknown command');
      expect(result.stderr, contains('Unknown command'));
    });

    test('Environment variable setting and getting', () {
      shell.setEnv('TEST_VAR', 'test_value');
      expect(shell.getEnv('TEST_VAR'), equals('test_value'));
    });

    test('Directory change', () async {
      final initialDir = Directory.current.path;
      await shell.processCommand('cd ${tempDir.path}');
      expect(Directory.current.path, equals(tempDir.path));
      await shell.processCommand('cd $initialDir');
    });

    test('Ls command', () async {
      File('${tempDir.path}/file1.txt').createSync();
      File('${tempDir.path}/file2.dart').createSync();
      final result = await shell.processCommand('ls ${tempDir.path}');
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('file1.txt'));
      expect(result.stdout, contains('file2.dart'));
    });

    test('Piping ls and grep', () async {
      File('${tempDir.path}/file1.txt').createSync();
      File('${tempDir.path}/file2.dart').createSync();
      File('${tempDir.path}/file3.dart').createSync();

      final result = await shell.processPipe('ls ${tempDir.path} | grep .dart', debug:true);
      expect(result.exitCode, equals(0) , reason: "Expected exit code 0 for piping ls to grep");
      expect(result.stdout, contains('file2.dart'), reason: "Expected to find file2");
      expect(result.stdout, contains('file3.dart'), reason: "Expected to find file3");
      expect(result.stdout, isNot(contains('file1.txt')), reason: "Expected to find file1");
    });

    test('Export command', () async {
      await shell.processCommand('export TEST_VAR=test_value');
      expect(shell.getEnv('TEST_VAR'), equals('test_value'));
    });

    // Add more tests for other commands and functionalities
  });
}
