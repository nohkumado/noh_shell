import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'shell_env.dart';

class Command {
  final String name;
  final String? executable;
  final List<String> arguments;
  final ShellEnv env;
  StreamSink<String>? output;
  StreamSink<String>? error;

  Command({this.name = "command",this.executable, required this.arguments, required this.env});

  //  returns ProcessResult(int pid, int exitCode, dynamic stdout, dynamic stderr)
  Future<ProcessResult> execute({
    String? input,
    StreamSink<String>? output,
    StreamSink<String>? error,
    bool debug = false,
  }) async {
    this.output = output;
    this.error = error;
    Process process =  await Process.start(
      executable??"",
      arguments,
      environment: env.toMap(),
      runInShell: true,
      //stdoutEncoding: null,
      //stderrEncoding: null,
    );


    // Write input as string stream if provided
    if (input != null) {
      process.stdin.write(input);
      await process.stdin.close();
    }

    // Pipe stdout and stderr directly to string sinks
    if (output != null) {
      process.stdout.transform(utf8.decoder).listen(output.add);
    }
    if (error != null) {
      process.stderr.transform(utf8.decoder).listen(error.add);
    }

    // Wait for the process to complete
    final exitCode = await process.exitCode;

    return ProcessResult(
      process.pid,
      exitCode,
      await process.stdout.transform(utf8.decoder).join(),
      await process.stderr.transform(utf8.decoder).join(),
    );
  }

  Command copy({List<String>? arguments, ShellEnv? env}) {
    return Command(name: name, arguments: arguments ?? this.arguments, env: env?? this.env);
  }

  void write(String msg)
  {
    if(output!=null) output!.add(msg);
    else stdout.write("! $msg");
  }
  void writeln(String msg)
  {
    write('$msg\n');
  }
  void errorln(String msg)
  {
    if(error!=null)error!.add('$msg\n');
    else stderr.writeln("! $msg");
  }
}

