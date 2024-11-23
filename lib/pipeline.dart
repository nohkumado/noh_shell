import 'command.dart';

class Pipeline {
  final List<Command> commands;

  Pipeline(this.commands);

  Future<void> execute() async {
    // Implement pipeline execution logic here
  }
}

