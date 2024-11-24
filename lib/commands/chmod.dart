import 'dart:io';
import '../command.dart';
import '../shell_env.dart';

class Chmod extends Command {
  Chmod({super.name = "chmod", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    IOSink? output,
    IOSink? error,
    bool debug = false,
  }) async {
    if (arguments.length < 2) {
      error?.writeln('Usage: chmod [-R] <mode> <file/directory>');
      return ProcessResult(0, 1, '', 'Usage: chmod [-R] <mode> <file/directory>');
    }

    bool recursive = false;
    String mode = '';
    List<String> targets = [];

    for (String arg in arguments) {
      if (arg == '-R') {
        recursive = true;
      } else if (mode.isEmpty) {
        mode = arg;
      } else {
        targets.add(arg);
      }
    }

    if (mode.isEmpty || targets.isEmpty) {
      error?.writeln('Invalid arguments');
      return ProcessResult(0, 1, '', 'Invalid arguments');
    }

    for (String target in targets) {
      try {
        await _changeMode(target, mode, recursive);
        output?.writeln('Changed mode of $target to $mode');
      } catch (e) {
        error?.writeln('Failed to change mode of $target: $e');
        return ProcessResult(0, 1, '', 'Failed to change mode of $target: $e');
      }
    }

    return ProcessResult(0, 0, 'chmod completed successfully', '');
  }

  Future<void> _changeMode(String path, String mode, bool recursive) async {
    FileSystemEntity entity = await FileSystemEntity.type(path) == FileSystemEntityType.directory
        ? Directory(path)
        : File(path);

    if (entity is File) {
      await _changeModeForFile(entity, mode);
    } else if (entity is Directory) {
      await _changeModeForDirectory(entity, mode, recursive);
    }
  }

  Future<void> _changeModeForFile(File file, String mode) async {
    int modeInt = _parseMode(mode);
    await changeFilePermissions(file.path, '$modeInt');
  }

  Future<void> _changeModeForDirectory(Directory dir, String mode, bool recursive) async {
    int modeInt = _parseMode(mode);
    await changeFilePermissions(dir.path, '$modeInt');


    if (recursive) {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          await _changeModeForFile(entity, mode);
        } else if (entity is Directory) {
          await changeFilePermissions(entity.path, '$modeInt');
        }
      }
    }
  }

  int _parseMode(String mode) {
    if (RegExp(r'^\d+$').hasMatch(mode)) {
      return int.parse(mode, radix: 8);
    } else {
      // Implement symbolic mode parsing here
      // This is a simplified version and doesn't cover all cases
      int result = 0;
      if (mode.contains('r')) result |= 4;
      if (mode.contains('w')) result |= 2;
      if (mode.contains('x')) result |= 1;
      return result * 73; // Apply to user, group, and others
    }
  }

  @override
  Chmod copy({List<String>? arguments, ShellEnv? env}) {
    return Chmod(arguments: arguments ?? this.arguments, env: env ?? this.env);
  }
Future<void> changeFilePermissions(String filePath, String mode) async {
  var result = await Process.run('chmod', [mode, filePath]);
  if (result.exitCode != 0) {
    throw Exception('Failed to change file permissions: ${result.stderr}');
  }
}
}
