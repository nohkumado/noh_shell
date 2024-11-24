import 'dart:io';
import '../command.dart';
import '../shell_env.dart';

class Mv extends Command {
  Mv({super.name = "mv", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    IOSink? output,
    IOSink? error,
    bool debug = false,
  }) async {
    if (arguments.length < 2) {
      error?.writeln('Usage: mv [-i] <source> <destination>');
      return ProcessResult(0, 1, '', 'Usage: mv [-i] <source> <destination>');
    }

    bool interactive = false;
    List<String> sources = [];
    String destination = arguments.last;

    for (String arg in arguments.sublist(0, arguments.length - 1)) {
      if (arg == '-i') {
        interactive = true;
      } else {
        sources.add(arg);
      }
    }

    bool isDestinationDirectory = await FileSystemEntity.isDirectory(destination);

    for (String source in sources) {
      try {
        FileSystemEntity sourceEntity = await FileSystemEntity.type(source) == FileSystemEntityType.directory
            ? Directory(source)
            : File(source);

        String actualDestination = isDestinationDirectory
            ? '${destination}/${sourceEntity.uri.pathSegments.last}'
            : destination;

        if (interactive && await FileSystemEntity.isFile(actualDestination)) {
          output?.write("mv: overwrite '$actualDestination'? ");
          String? response = stdin.readLineSync()?.toLowerCase();
          if (response != 'y' && response != 'yes') {
            continue;
          }
        }

        await sourceEntity.rename(actualDestination);
        output?.writeln('Moved: $source to $actualDestination');
      } catch (e) {
        error?.writeln('Failed to move $source: $e');
        return ProcessResult(0, 1, '', 'Failed to move $source: $e');
      }
    }

    return ProcessResult(0, 0, 'Move completed successfully', '');
  }

  @override
  Mv copy({List<String>? arguments, ShellEnv? env}) {
    return Mv(arguments: arguments ?? this.arguments, env: env ?? this.env);
  }
}
