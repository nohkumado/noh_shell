import 'dart:io';

import 'command.dart';
import 'commands/cat.dart';
import 'commands/cd.dart';
import 'commands/ls.dart';
import 'commands/pwd.dart';

class Shell {

  final Map<String, Command> commands = {
    'ls': Ls(arguments: []),
    'cat': Cat(arguments: []),
    'pwd': Pwd(arguments: []),
    'cd': Cd(arguments: []),
  };

  Future<void> run() async {
    bool running = true;
    while (running)
    {
      stdout.write('> ');
      String? input = stdin.readLineSync();

      if (input == null || input.toLowerCase() == 'quit') {
        break;
      }

      List<String> parts = input.trim().split(' ');
      String commandName = parts[0];
      List<String> args = parts.sublist(1);

      if (commands.containsKey(commandName)) {
        Command command = commands[commandName]!;
        command.copy(arguments: args);
        ProcessResult result = await command.execute();
        stdout.write(result.stdout);
        stderr.write(result.stderr);
      } else {
        print('Unknown command: $commandName');
      }
    }
    print('Goodbye!');

  }
}
