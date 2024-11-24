import 'package:test/test.dart';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import 'package:noh_shell/commands/echo.dart';

void main() {
  group('Echo command tests', () {
    late ShellEnv env;
    late Echo echoCommand;

    setUp(() {
      env = ShellEnv();
      echoCommand = Echo(arguments: [], env: env);
    });

    test('Basic echo', () async {
      echoCommand = Echo(arguments: ['Hello', 'World'], env: env);
      final result = await echoCommand.execute();
      expect(result.stdout, equals('Hello World\n'));
      expect(result.exitCode, equals(0));
    });

    test('Echo with -n option', () async {
      echoCommand = Echo(arguments: ['-n', 'No', 'newline'], env: env);
      final result = await echoCommand.execute();
      expect(result.stdout, equals('No newline'));
      expect(result.exitCode, equals(0));
    });

    test('Echo with -e option', () async {
      echoCommand = Echo(arguments: ['-e', 'Line1\\nLine2\\tTabbed'], env: env);
      final result = await echoCommand.execute();
      expect(result.stdout, equals('Line1\nLine2\tTabbed\n'));
      expect(result.exitCode, equals(0));
    });

    test('Echo with both -n and -e options', () async {
      echoCommand = Echo(arguments: ['-n', '-e', 'Escaped\\tNo newline'], env: env);
      final result = await echoCommand.execute();
      expect(result.stdout, equals('Escaped\tNo newline'));
      expect(result.exitCode, equals(0));
    });

    test('Echo with environment variable', () async {
      env['TEST_VAR'] = 'Test Value';
      echoCommand = Echo(arguments: ['${env['TEST_VAR']}'], env: env);
      final result = await echoCommand.execute();
      expect(result.stdout, equals('${env['TEST_VAR']}\n'));
      expect(result.exitCode, equals(0));
    });

    test('Echo with no arguments', () async {
      echoCommand = Echo(arguments: [], env: env);
      final result = await echoCommand.execute();
      expect(result.stdout, equals('\n'));
      expect(result.exitCode, equals(0));
    });

    test('Copy method', () {
      final copiedCommand = echoCommand.copy(arguments: ['New', 'args']);
      expect(copiedCommand, isA<Echo>());
      expect(copiedCommand.arguments, equals(['New', 'args']));
      expect(copiedCommand.env, equals(env));
    });
  });
}
