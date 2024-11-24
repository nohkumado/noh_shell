import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import '../command.dart';

class Grep extends Command {
  Grep({super.name = "grep", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    IOSink? output,
    IOSink? error,
    bool debug = false,
  }) async {
    if (arguments.length < 2) {
      error?.writeln('Usage: grep <pattern> <file>');
      return ProcessResult(0, 1, '', 'Usage: grep <pattern> <file>');
    }

    String pattern = arguments[0];
    String filename = arguments[1];
    StringBuffer resultOutput = StringBuffer();
    int matchCount = 0;

    try {
      File file = File(filename);
      if (!await file.exists()) {
        error?.writeln('File not found: $filename');
        return ProcessResult(0, 1, '', 'File not found: $filename');
      }

      List<String> lines = await file.readAsLines();
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains(pattern)) {
          String matchedLine = '${i + 1}: ${lines[i]}';
          resultOutput.writeln(matchedLine);
          output?.writeln(matchedLine);
          matchCount++;
        }
      }

      String summary = '$matchCount match(es) found';
      resultOutput.writeln(summary);
      output?.writeln(summary);

      return ProcessResult(0, 0, resultOutput.toString(), '');
    } catch (e) {
      error?.writeln('Error reading file: $e');
      return ProcessResult(0, 1, '', 'Error reading file: $e');
    }
  }

  @override
  Grep copy({List<String>? arguments, ShellEnv? env}) {
    return Grep(name: name, arguments: arguments ?? this.arguments, env: env ?? this.env);
  }
}
