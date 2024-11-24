import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import '../command.dart';

class Touch extends Command {
  Touch({super.name = "touch", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    IOSink? output,
    IOSink? error,
    bool debug = false,
  }) async {
    if (arguments.isEmpty) {
      error?.writeln('Usage: touch <filename>');
      return ProcessResult(0, 1, '', 'Usage: touch <filename>');
    }

    for (String filename in arguments) {
      try {
        File file = File(filename);
        if (await file.exists()) {
          await file.setLastModified(DateTime.now());
        } else {
          await file.create();
        }
      } catch (e) {
        error?.writeln('Error touching file $filename: $e');
        return ProcessResult(0, 1, '', 'Error touching file $filename: $e');
      }
    }

    return ProcessResult(0, 0, '', '');
  }

  @override
  Touch copy({List<String>? arguments, ShellEnv? env}) {
    return Touch(name: name, arguments: arguments ?? this.arguments, env: env ?? this.env);
  }
}
