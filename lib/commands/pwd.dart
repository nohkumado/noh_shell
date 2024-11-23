import 'dart:io';
import '../command.dart';

class Pwd extends Command {
  Pwd({super.name = "pwd", required super.arguments, super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    IOSink? output,
    IOSink? error,
    bool debug = false,
  }) async {
    String currentDirectory = Directory.current.path;
    output?.write('$currentDirectory\n');
    return ProcessResult(0, 0, currentDirectory, '');
  }
  @override
  Pwd copy({List<String>? arguments, Map<String, String>? env}) {
    return Pwd(name: name, arguments: arguments ?? this.arguments, env: env?? this.env);
  }
}
