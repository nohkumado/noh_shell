import 'dart:async';
import 'dart:io';

import 'package:noh_shell/process_result_pretty.dart';
import 'package:noh_shell/shell_env.dart';

import 'command.dart';
import 'commands/cat.dart';
import 'commands/cd.dart';
import 'commands/cp.dart';
import 'commands/echo.dart';
import 'commands/export.dart';
import 'commands/grep.dart';
import 'commands/ls.dart';
import 'commands/mkdir.dart';
import 'commands/mv.dart';
import 'commands/pwd.dart';
import 'commands/rm.dart';
import 'commands/touch.dart';
import 'prompt.dart';

class Shell {

  ShellEnv env =ShellEnv();
  final Map<String, Command> commands = {};
  Shell()
  {
    commands["cat"] = Cat(arguments: [], env: env);
    commands["cd"] = Cd(arguments: [], env: env);
    commands["cp"] = Cp(arguments: [], env: env);
    commands["echo"] = Echo(arguments: [], env: env);
    commands["export"] = Export(arguments: [], env: env);
    commands["grep"] = Grep(arguments: [], env: env);
    commands["ls"] = Ls(arguments: [], env: env);
    commands["mkdir"] = Mkdir(arguments: [], env: env);
    commands["mv"] = Mv(arguments: [], env: env);
    commands["pwd"] = Pwd(arguments: [], env: env);
    commands["rm"] = Rm(arguments: [], env: env);
    commands["touch"] = Touch(arguments: [], env: env);
  }

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

      if(input.contains('|')) await processPipe(input);
      else if(input.contains('>')) await processRedirect(input);
      else await processCommand(input);

    }
    print('Goodbye!');

  }

  Future<ProcessResult> processCommand(String input, {bool debug = false})
  async {
    List<String> parts = input.trim().split(' ');
    String commandName = parts[0];
    List<String> args = parts.sublist(1);
    ProcessResult result = ProcessResult(0, 0, '', '');
    if (commands.containsKey(commandName)) {
      StreamController<String> localController = StreamController<String>();
      StreamController<String> errorController = StreamController<String>();
      Command command = commands[commandName]!;
      command = command.copy(arguments: args, env: env);
      result = await command.execute(debug: debug, output: localController.sink, error: errorController.sink);
      stdout.write(result.stdout);
      stderr.write(result.stderr);
    } else {
      result = ProcessResult(result.pid, 1, result.stdout, 'Unknown command: $commandName');
    }
    return result;
  }

  //  returns ProcessResult(int pid, int exitCode, dynamic stdout, dynamic stderr)
  Future<ProcessResult> processPipeSync(String input, {bool debug = false}) async
  {
    List<String> commands = input.split('|').map((s) => s.trim()).toList();
    ProcessResult result = ProcessResult(0, 0, '', '');
    if (commands.length != 2) {
      print('Error: Only one pipe is supported.');
      return result;
    }
    String firstCommand = commands[0];
    String secondCommand = commands[1];

    List<String> firstParts = firstCommand.split(' ');
    String firstCommandName = firstParts[0];
    List<String> firstArgs = firstParts.sublist(1);

    List<String> secondParts = secondCommand.split(' ');
    String secondCommandName = secondParts[0];
    List<String> secondArgs = secondParts.sublist(1);

    if (!this.commands.containsKey(firstCommandName) || !this.commands.containsKey(secondCommandName)) {
      print('Error: Unknown command in pipe.');
      return ProcessResult(0, 1, '', 'Error: Unknown command in pipe.');
    }

    Command firstCmd = this.commands[firstCommandName]!.copy(arguments: firstArgs, env: env);
    Command secondCmd = this.commands[secondCommandName]!.copy(arguments: secondArgs, env: env);
if(debug) print("about to start first cmd: $firstCmd");
    ProcessResult firstResult = await firstCmd.execute(debug: debug);
    if (firstResult.exitCode != 0) {
      stderr.write(firstResult.stderr);
      return firstResult;
    }

    if(debug) print("first cmd completed: ${prettyPrintProcessResult(firstResult)} starting second: $secondCmd");
    ProcessResult secondResult = await secondCmd.execute(input: firstResult.stdout.toString(), debug: debug);
    stdout.write(secondResult.stdout);
    stderr.write(secondResult.stderr);
    if(debug) print("second cmd completed: ${prettyPrintProcessResult(secondResult)}");
    return secondResult;
  }

  Future<ProcessResult> processPipe(String input, {bool debug = false}) async {
    List<String> commands = input.split('|').map((s) => s.trim()).toList();
    if (commands.length != 2) {
      return ProcessResult(0, 1, '', 'Error: Only one pipe is supported.');
    }

    var controller = StreamController<String>();
    var firstCommand = _executeCommand(commands[0], outputSink: controller.sink);
    var secondCommand = _executeCommand(commands[1], inputStream: controller.stream);

    await Future.wait([firstCommand, secondCommand]);
    await controller.close();

    var result = await secondCommand;
    return result;
  }

  Future<ProcessResult> _executeCommand(String commandString, {Stream<String>? inputStream, StreamSink<String>? outputSink}) async {
    List<String> parts = commandString.split(' ');
    String commandName = parts[0];
    List<String> args = parts.sublist(1);

    if (commands.containsKey(commandName)) {
      Command command = commands[commandName]!.copy(arguments: args, env: env);
      return command.execute(
        input: inputStream != null ? await inputStream.join('\n') : null,
        //output: outputSink != null ? StreamSink<String>(outputSink) : null,
        output: outputSink,
      );
    } else {
      return ProcessResult(0, 1, '', 'Unknown command: $commandName');
    }
  }

  Future<ProcessResult> processRedirect(String input) async
  {
    ProcessResult result = ProcessResult(0, 0, '', '');
    return result;
  }
}