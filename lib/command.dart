import 'dart:io';

import 'shell_env.dart';

class Command {
  final String name;
  final String? executable;
  final List<String> arguments;
  final ShellEnv env;

  Command({this.name = "command",this.executable, required this.arguments, required this.env});

  //  returns ProcessResult(int pid, int exitCode, dynamic stdout, dynamic stderr)
  Future<ProcessResult> execute({
    String? input,
    IOSink? output,
    IOSink? error,
    bool debug = false,
  }) async {
    return Process.run(
      executable??"",
      arguments,
      stdoutEncoding: null,
      stderrEncoding: null,
    );
  }

  Command copy({List<String>? arguments, ShellEnv? env}) {
    return Command(name: this.name, arguments: arguments ?? this.arguments, env: env?? this.env);
  }
}

