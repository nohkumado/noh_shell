import 'dart:io';
import '../command.dart';

class Cd extends Command {
  Cd({super.name = "cd", required super.arguments});

  @override
  Future<ProcessResult> execute({
    String? input,
    IOSink? output,
    IOSink? error,
    bool debug = false,
  }) async {
    // If no arguments provided, return to home directory
    String targetPath = arguments.isEmpty
        ? Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '.'
        : arguments[0];

    try {
      // Resolve the path (handle relative and absolute paths)
      Directory targetDirectory = Directory(targetPath).absolute;

      if (!await targetDirectory.exists()) {
        error?.writeln('cd: ${targetDirectory.path}: No such file or directory');
        return ProcessResult(0, 1, '', 'No such file or directory');
      }

      // Change the current working directory
      Directory.current = targetDirectory;

      output?.write('${targetDirectory.path}\n');
      return ProcessResult(0, 0, targetDirectory.path, '');
    } catch (e) {
      error?.writeln('cd: Error changing directory: $e');
      return ProcessResult(0, 1, '', 'Error changing directory');
    }
  }
}
