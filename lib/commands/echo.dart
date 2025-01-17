import 'dart:async';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import '../command.dart';

class Echo extends Command {
  Echo({super.name = "echo", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    StreamSink<String>? output,
    StreamSink<String>? error,
    bool debug = false,
  }) async {
    bool interpretEscapes = false;
    bool suppressNewline = false;
    List<String> textToEcho = [];

    // Parse options
    for (var arg in arguments) {
      if (arg == '-e') {
        interpretEscapes = true;
      } else if (arg == '-n') {
        suppressNewline = true;
      } else {
        textToEcho.add(arg);
      }
    }

    String result = textToEcho.join(' ');

    if (interpretEscapes) {
      result = _interpretEscapes(result);
    }

    if (!suppressNewline) {
      result += '\n';
    }

    write(result);
    return ProcessResult(0, 0, result, '');
  }

  String _interpretEscapes(String input) {
    return input
        .replaceAll('\\n', '\n')
        .replaceAll('\\t', '\t')
        .replaceAll('\\\\', '\\');
    // Add more escape sequences as needed
  }

  @override
  Echo copy({List<String>? arguments, ShellEnv? env}) {
    return Echo(name: name, arguments: arguments ?? this.arguments, env: env ?? this.env);
  }
}
