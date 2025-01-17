import 'dart:async';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import '../command.dart';

class Grep extends Command {
  Grep({super.name = "grep", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    StreamSink<String>? output,
    StreamSink<String>? error,
    bool debug = false,
  }) async {
    if (arguments.isEmpty) {
      errorln('Usage: grep <pattern> <file>');
      return ProcessResult(0, 1, '', 'Usage: grep <pattern> <file>');
    }

    bool verbose = true;
    String pattern = arguments[0];
    StringBuffer resultOutput = StringBuffer();
    int matchCount = 0;

    try {
      List<String> lines;
      if (input != null) {
        // Handle piped input
        lines = input.split('\n');
      } else if (arguments.length > 1) {
        // Handle file input
        String filename = arguments[1];
        File file = File(filename);
        if (!await file.exists()) {
          errorln('File not found: $filename');
          return ProcessResult(0, 1, '', 'File not found: $filename');
        }
        lines = await file.readAsLines();
      } else {
        errorln('No input provided');
        return ProcessResult(0, 1, '', 'No input provided');
      }

      int counter = 1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains(pattern)) {
          //1: Line 1: Hello World
          String matchedLine = '${verbose ? '$counter:' : ''} ${lines[i]}';
          resultOutput.writeln(matchedLine);
          writeln(matchedLine);
          matchCount++;
          counter++;
        }
      }
      if(matchCount == 0) {
        //errorln('No matches found');
        return ProcessResult(0, 1, '', 'No matches found');
      }

      if (debug || verbose) {
        String summary = '$matchCount match(es) found';
        resultOutput.writeln(summary);
        writeln(summary);
      }

      return ProcessResult(0, 0, resultOutput.toString(), '');
    } catch (e) {
      errorln('Error processing input: $e');
      return ProcessResult(0, 1, '', 'Error processing input: $e');
    }
  }


  @override
  Grep copy({List<String>? arguments, ShellEnv? env}) {
    return Grep(name: name, arguments: arguments ?? this.arguments, env: env ?? this.env);
  }
}
