import 'package:noh_shell/commands/export.dart';
import 'package:noh_shell/shell_env.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Export command tests', () {
    late Export exportCommand;
    ShellEnv testEnv = ShellEnv();

    setUp(() {
      testEnv['HOME'] = '/home/testuser';
      testEnv['PWD'] =  '/current/directory';
      testEnv['USER'] =  'testuser';
    });

    test('Export new variable', () async {
      exportCommand = Export(arguments: ['NEW_VAR=test_value'], env: testEnv);
      final result = await exportCommand.execute();

      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('Exported: NEW_VAR=test_value'));
      expect(testEnv['NEW_VAR'], equals('test_value'));
    });

    test('Update existing variable', () async {
      exportCommand = Export(arguments: ['HOME=/new/home'], env: testEnv);
      final result = await exportCommand.execute();

      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('Exported: HOME=/new/home'));
      expect(testEnv['HOME'], equals('/new/home'));
    });

    test('List all variables when no arguments', () async {
      exportCommand = Export(arguments: [], env: testEnv);
      final result = await exportCommand.execute();

      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('HOME=/home/testuser'));
      expect(result.stdout, contains('PWD=/current/directory'));
      expect(result.stdout, contains('USER=testuser'));
    });

    test('Invalid syntax', () async {
      exportCommand = Export(arguments: ['INVALID_SYNTAX'], env: testEnv);
      final result = await exportCommand.execute(debug: false);

      expect(result.exitCode, equals(1));
      expect(result.stdout, contains('Usage: export KEY=VALUE'));
      expect(result.stderr, contains('Invalid syntax'));
    });

    test('Copy method', () {
      exportCommand = Export(arguments: ['ORIGINAL=value'], env: testEnv);
      final copiedCommand = exportCommand.copy(arguments: ['COPIED=newvalue']);

      expect(copiedCommand, isA<Export>());
      expect(copiedCommand.arguments, equals(['COPIED=newvalue']));
    });
  });
}
