import 'dart:io';

class Command {
  final String name;
  final String? executable;
  final List<String> arguments;
  final Map<String, String> env;

  Command({this.name = "command",this.executable, required this.arguments, this.env = const {}});

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

  Command copy({List<String>? arguments, Map<String, String>? env}) {
    return Command(name: this.name, arguments: arguments ?? this.arguments, env: env?? this.env);
  }
}

