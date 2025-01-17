import 'dart:async';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';

import '../command.dart';

class Cat extends Command {
  Cat({super.name = "cat", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    StreamSink<String>? output,
    StreamSink<String>? error,
    bool debug = false,
  }) async {
    if (arguments.isEmpty) {
      //errorln('Usage: cat <filename>');
      return ProcessResult(0, 1, '', 'Usage: cat <filename>');
    }

    final file = File(arguments[0]);
    if (!await file.exists()) {
      String errorMessage = 'File does not exist: ${arguments[0]}';
      //errorln(errorMessage);
      return ProcessResult(0, 1, '', errorMessage);
    }

    try {
      String content = await file.readAsString();
      writeln(content);
      return ProcessResult(0, 0, content, '');
    } catch (e) {
      String errorMessage = 'Error reading file: $e';
      //errorln(errorMessage);
      return ProcessResult(0, 1, '', errorMessage);
    }
  }
  @override
  Cat copy({List<String>? arguments, ShellEnv? env}) {
    return Cat(name: name, arguments: arguments ?? this.arguments, env: env?? this.env);
  }
}
