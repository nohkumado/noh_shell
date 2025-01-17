import 'dart:io';

String prettyPrintProcessResult(ProcessResult result) {
  return '''
ProcessResult:
  pid: ${result.pid}
  exitCode: ${result.exitCode}
  stdout: ${result.stdout}
  stderr: ${result.stderr}
''';
}