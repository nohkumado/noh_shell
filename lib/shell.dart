import 'dart:io';

import 'package:noh_shell/shell_env.dart';

import 'command.dart';
import 'commands/cat.dart';
import 'commands/cd.dart';
import 'commands/export.dart';
import 'commands/ls.dart';
import 'commands/pwd.dart';
import 'prompt.dart';

class Shell {

  ShellEnv env =ShellEnv();
  final Map<String, Command> commands = {};
  Shell()
  {
    commands["ls"] = Ls(arguments: [], env: env);
    commands["cat"] = Cat(arguments: [], env: env);
    commands["pwd"] = Pwd(arguments: [], env: env);
    commands["cd"] = Cd(arguments: [], env: env);
    commands["export"] = Export(arguments: [], env: env);
  }
  // Environment variables stored in a Map
  //Map<String, String> env = {
  //  'HOME': Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '.',
  //  'PWD': Directory.current.path,
  //  'USER': Platform.environment['USER'] ?? Platform.environment['USERNAME'] ?? 'user',
  //  'PS1': '\\u\\h:\\w\$ '
  //};

  // Method to set environment variables
  void setEnv(String key, String value) {
    env[key] = value;
  }

  // Method to get environment variables
  String? getEnv(String key) {
    return env[key];
  }
  Future<void> run() async {
    bool running = true;
    Prompt prompt = Prompt(env: env);
    while (running)
    {
      stdout.write('${prompt} ');
      String? input = stdin.readLineSync();

      if (input == null || input.toLowerCase() == 'quit') {
        break;
      }

      List<String> parts = input.trim().split(' ');
      String commandName = parts[0];
      List<String> args = parts.sublist(1);

      if (commands.containsKey(commandName)) {
        Command command = commands[commandName]!;
        command.copy(arguments: args, env: env);
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
