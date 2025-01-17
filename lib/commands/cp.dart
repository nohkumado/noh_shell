import 'dart:async';
import 'dart:io';
import '../command.dart';
import '../shell_env.dart';

class Cp extends Command {
  Cp({super.name = "cp", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    StreamSink<String>? output,
    StreamSink<String>? error,
    bool debug = false,
  }) async {
    if (arguments.length < 2) {
      errorln('Usage: cp [-r] <source> ... <destination>');
      return ProcessResult(0, 1, '', 'Usage: cp [-r] <source> ... <destination>');
    }

    bool recursive = false;
    List<String> sources = [];
    String destination = arguments.last;

    for (String arg in arguments.sublist(0, arguments.length - 1)) {
      if (arg == '-r' || arg == '-R') {
        recursive = true;
      } else {
        sources.add(arg);
      }
    }

    bool isDestinationDirectory = await FileSystemEntity.isDirectory(destination);

    for (String source in sources) {
      try {
        FileSystemEntity sourceEntity = FileSystemEntity.typeSync(source) == FileSystemEntityType.directory
            ? Directory(source)
            : File(source);

        if (sourceEntity is Directory && !recursive) {
          errorln("cp: omitting directory '$source'");
          return ProcessResult(0, 1, '', 'cp: omitting directory "$source"');
        }

        String actualDestination = isDestinationDirectory
            ? '${destination}/${sourceEntity.uri.pathSegments.last}'
            : destination;

        if (sourceEntity is File) {
          await _copyFile(sourceEntity, actualDestination);
        } else if (sourceEntity is Directory) {
          await _copyDirectory(sourceEntity, actualDestination, recursive);
        }

        writeln('Copied: $source to $actualDestination');
      } catch (e) {
        errorln('Failed to copy $source: $e');
        return ProcessResult(0, 1, '', 'Failed to copy $source: $e');
      }
    }

    return ProcessResult(0, 0, 'Copy completed successfully', '');
  }


  Future<void> _copyFile(File source, String destination) async {
    File destFile = File(destination);
    if (await destFile.exists() && await destFile.stat() == await source.stat()) {
      return; // Files are identical, no need to copy
    }
    await source.copy(destination);
  }

  Future<void> _copyDirectory(Directory source, String destination, bool recursive) async {
    Directory destDir = Directory(destination);
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    await for (var entity in source.list(recursive: recursive)) {
      String newPath = destination + entity.path.substring(source.path.length);
      if (entity is File) {
        await _copyFile(entity, newPath);
      } else if (entity is Directory) {
        await Directory(newPath).create(recursive: true);
      }
    }
  }

  @override
  Cp copy({List<String>? arguments, ShellEnv? env}) {
    return Cp(arguments: arguments ?? this.arguments, env: env ?? this.env);
  }
}
