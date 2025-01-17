import 'dart:async';
import 'dart:io';
import 'package:noh_shell/shell_env.dart';

import '../command.dart';

class Pwd extends Command {
  Pwd({super.name = "pwd", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    StreamSink<String>? output,
    StreamSink<String>? error,
    bool debug = false,
  }) async {
    String currentDirectory = Directory.current.path;
    write('$currentDirectory\n');
    return ProcessResult(0, 0, currentDirectory, '');
  }
  @override
  Pwd copy({List<String>? arguments, ShellEnv? env}) {
    return Pwd(name: name, arguments: arguments ?? this.arguments, env: env?? this.env);
  }

}
