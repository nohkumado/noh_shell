import 'dart:async';
import 'dart:io';
import 'package:noh_shell/utils/binary_number.dart';

import '../command.dart';
import '../shell_env.dart';

class Chmod extends Command {
  Chmod({super.name = "chmod", required super.arguments, required super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    StreamSink<String>? output,
    StreamSink<String>? error,
    bool debug = false,
  }) async {
    if (arguments.length < 2) {
      errorln('Usage: chmod [-R] <mode> <file/directory>');
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
      errorln('Invalid arguments');
      return ProcessResult(0, 1, '', 'Invalid arguments');
    }

    for (String target in targets) {
      try {
        await _changeMode(target, mode, recursive);
        writeln('Changed mode of $target to $mode');
      } catch (e) {
        errorln('Failed to change mode of $target: $e');
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
    print("parsing mode: $mode");

    // Check if the mode is numeric
    if (RegExp(r'^\d+$').hasMatch(mode)) {
      var splitted = mode.split('');
      bool ok = true;
      for(int i = 0; i < splitted.length; i++){
        ok &= (int.parse(splitted[i]) < 8) ;
      }
      return int.parse(mode, radix: 10);
    }
    else
    {
      //sst rwx rwx rwx extended 9 bits otherwise
      BinaryNumber bn = BinaryNumber(length: 12);
      // Parse symbolic mode
      int result = 0;
      final RegExp chmodRegex = RegExp(r'([ugoa]*)([=+-])([rwxXst-]*)');
      Iterable<RegExpMatch> matches = chmodRegex.allMatches(mode);
      for (var match in matches) {
        String categories = match.group(1) ?? 'a';  // Default to 'all' if not specified
        String operator = match.group(2)?? '+';
        String permTypes = match.group(3)!;

        int pos = 0;
        if(categories.contains('u')  ||categories.contains('a'))
        {
          pos = 3;
          setPerm(operator, pos, bn, permTypes);
        }
        if(categories.contains('g')  ||categories.contains('a'))
        {
          pos = 6;
          setPerm(operator, pos, bn, permTypes);
        }
        if(categories.contains('o')  ||categories.contains('a'))
        {
          pos = 9;
          setPerm(operator, pos, bn, permTypes);
        }
      }

    }

    //print("returning symbolic mode: ${toOctal()}");
    //return result;
    return 755;
  }

  void setPerm(String operator, int pos, BinaryNumber bn, String permTypes) {
    if(operator == '=')
    {
      for(int n = pos; n< pos+3; n++) bn[n] = 1;
      operator = '+';
    }
    if(operator == '+')
    {
      if (permTypes.contains('r')) bn[pos]= 1;
      if (permTypes.contains('w')) bn[pos+1] = 1;
      if (permTypes.contains('x')) bn[pos+2] = 1;
      if (permTypes.contains('s') && (pos == 3 || pos == 6)) bn[pos - 3] = 1;
      if (permTypes.contains('t') && pos == 9) bn[0] = 1;
    }
    else if(operator == '-')
    {
      if (permTypes.contains('r')) bn[pos]= 0;
      if (permTypes.contains('w')) bn[pos+1] = 0;
      if (permTypes.contains('x')) bn[pos+2] = 0;
      // Handle special permissions
      if (permTypes.contains('s') && (pos == 3 || pos == 6)) bn[pos - 3] = 1;
      if (permTypes.contains('t') && pos == 9) bn[0] = 1;
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
