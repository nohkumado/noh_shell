import 'dart:async';
import 'dart:io';

import '../command.dart';
import '../shell_env.dart';

class Export extends Command {
  Export({super.name = "export", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    StreamSink<String>? output,
    StreamSink<String>? error,
    bool debug = false,
  }) async {
    if(debug) print("entering export with env: $env");
     StringBuffer resultOutput = StringBuffer();
    if (arguments.isEmpty) {
      if(debug) print("noargs rpinting out env");
      // If no arguments, print all environment variables
        String line = '$env\n';
        writeln(line);
        resultOutput.write(line);
      if(debug) print("output set to $output");
      return ProcessResult(0, 0, resultOutput.toString(), '');
    }

    String arg = arguments.join(' ');
    var parts = arg.split('=');
    if(debug) print("export isolated $parts");
    if (parts.length != 2) {
      String line = 'Usage: export KEY=VALUE';
      errorln(line);
      resultOutput.write(line);
      return ProcessResult(0, 1, resultOutput.toString(), 'Invalid syntax');
    }

    String key = parts[0].trim();
    String value = parts[1].trim();

    env[key] = value;
    writeln('Exported: $key=$value');
    if(debug) print("export exported to env: $key=$value -> $env");

    return ProcessResult(0, 0, 'Exported: $key=$value', '');
  }

  @override
  Export copy({List<String>? arguments, ShellEnv? env}) {
    return Export(arguments: arguments ?? this.arguments, env: env?? this.env);
  }
}
