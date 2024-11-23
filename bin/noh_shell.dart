import 'package:noh_shell/noh_shell.dart' as noh_shell;
import 'package:noh_shell/shell.dart';

Future<void> main(List<String> arguments) async {
  Shell shell = Shell();
  await shell.run();
}
