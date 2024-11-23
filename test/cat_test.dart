import 'package:noh_shell/commands/cat.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Cat command tests', () {
    late Directory tempDir;
    late File testFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('cat_test_');
      testFile = File('${tempDir.path}/test.txt');
      testFile.writeAsStringSync('Hello, World!');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Cat existing file', () async {
      final cat = Cat(arguments: [testFile.path]);
      final result = await cat.execute();
      expect(result.exitCode, equals(0));
      expect(result.stdout, equals('Hello, World!'));
    });

    test('Cat non-existent file', () async {
      final cat = Cat(arguments: ['/non/existent/file.txt']);
      final result = await cat.execute();
      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('File does not exist'));
    });

    test('Cat without arguments', () async {
      final cat = Cat(arguments: []);
      final result = await cat.execute();
      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Usage: cat <filename>'));
    });

    test('Cat unreadable file', () async {
      final unreadableFile = File('${tempDir.path}/unreadable.txt');
      unreadableFile.writeAsStringSync('Secret content');
      unreadableFile.setLastModifiedSync(DateTime.now());

      // Make the file unreadable (this might not work on all systems)
      try {
        await Process.run('chmod', ['000', unreadableFile.path]);
      } catch (e) {
        // If chmod fails, skip this test
        return;
      }

      final cat = Cat(arguments: [unreadableFile.path]);
      final result = await cat.execute();
      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Error reading file'));
    });
  });
}
