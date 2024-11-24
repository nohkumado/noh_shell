import 'dart:io';
import 'package:noh_shell/shell_env.dart';
import '../command.dart';

class Mkdir extends Command {
  Mkdir({super.name = "mkdir", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    IOSink? output,
    IOSink? error,
    bool debug = false,
  }) async {
    if (arguments.isEmpty) {
      error?.writeln('Usage: mkdir <directory_name>');
      return ProcessResult(0, 1, '', 'Usage: mkdir <directory_name>');
    }

    bool recursive = false;
    List<String> directoriesToCreate = [];

    for (String arg in arguments) {
      if (arg == '-p' || arg == '--parents') {
        recursive = true;
      } else {
        directoriesToCreate.add(arg);
      }
    }

    for (String dirPath in directoriesToCreate) {
      try {
        Directory dir = Directory(dirPath);
        if (await dir.exists()) {
          if (!recursive) {
            error?.writeln("mkdir: cannot create directory '$dirPath': File exists");
            return ProcessResult(0, 1, '', "mkdir: cannot create directory '$dirPath': File exists");
          }
          // If recursive, we just skip existing directories
          continue;
        }
        if (recursive) {
          await dir.create(recursive: true);
        } else {
          await dir.create();
        }
        output?.writeln('Created directory: $dirPath');
      } catch (e) {
        error?.writeln('Failed to create directory $dirPath: $e');
        return ProcessResult(0, 1, '', 'Failed to create directory $dirPath: $e');
      }
    }

    return ProcessResult(0, 0, 'Directories created successfully', '');
  }

  @override
  Mkdir copy({List<String>? arguments, ShellEnv? env}) {
    return Mkdir(name: name, arguments: arguments ?? this.arguments, env: env ?? this.env);
  }
}
