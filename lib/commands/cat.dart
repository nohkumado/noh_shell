import 'dart:io';
import '../command.dart';

class Cat extends Command {
  Cat({super.name = "cat", required super.arguments, super.env});

  @override
  Future<ProcessResult> execute({
    String? input,
    IOSink? output,
    IOSink? error,
    bool debug = false,
  }) async {
    if (arguments.isEmpty) {
      error?.writeln('Usage: cat <filename>');
      return ProcessResult(0, 1, '', 'Usage: cat <filename>');
    }

    final file = File(arguments[0]);
    if (!await file.exists()) {
      String errorMessage = 'File does not exist: ${arguments[0]}';
      error?.writeln(errorMessage);
      return ProcessResult(0, 1, '', errorMessage);
    }

    try {
      String content = await file.readAsString();
      output?.write(content);
      return ProcessResult(0, 0, content, '');
    } catch (e) {
      String errorMessage = 'Error reading file: $e';
      error?.writeln(errorMessage);
      return ProcessResult(0, 1, '', errorMessage);
    }
  }
  @override
  Cat copy({List<String>? arguments, Map<String, String>? env}) {
    return Cat(name: name, arguments: arguments ?? this.arguments, env: env?? this.env);
  }
}
