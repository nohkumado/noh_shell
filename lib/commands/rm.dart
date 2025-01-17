import 'dart:async';
import 'dart:io';
import '../command.dart';
import '../shell_env.dart';

class Rm extends Command {
  Rm({super.name = "rm", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    StreamSink<String>? output,
    StreamSink<String>? error,
    bool debug = false,
  }) async {
    if (arguments.isEmpty) {
      errorln('Usage: rm [-r] <file/directory>');
      return ProcessResult(0, 1, '', 'Usage: rm [-r] <file/directory>');
    }

    bool recursive = false;
    List<String> pathsToRemove = [];

    for (String arg in arguments) {
      if (arg == '-r' || arg == '-R' || arg == '--recursive') {
        recursive = true;
      } else {
        pathsToRemove.add(arg);
      }
    }

    for (String path in pathsToRemove) {
      try {
        FileSystemEntity entity = FileSystemEntity.typeSync(path) == FileSystemEntityType.directory
            ? Directory(path)
            : File(path);

        if (entity is Directory && !recursive) {
          errorln("rm: cannot remove '$path': Is a directory");
          return ProcessResult(0, 1, '', "rm: cannot remove '$path': Is a directory");
        }

        await entity.delete(recursive: recursive);
        writeln('Removed: $path');
      } catch (e) {
        errorln('Failed to remove $path: $e');
        return ProcessResult(0, 1, '', 'Failed to remove $path: $e');
      }
    }

    return ProcessResult(0, 0, 'Removal completed successfully', '');
  }

  @override
  Rm copy({List<String>? arguments, ShellEnv? env}) {
    return Rm(name: name, arguments: arguments ?? this.arguments, env: env ?? this.env);
  }
}
