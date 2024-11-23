import 'dart:io';

import '../command.dart';

class Ls extends Command
{
 Ls({super.name = "ls", required super.arguments});

 @override
 Future<ProcessResult> execute(
 {
 String? input,
 IOSink? output,
 IOSink? error,
   bool debug = false,
 }
     )
 async {
   // Check if a directory was provided as an argument
  String directoryPath = arguments.isNotEmpty ? arguments[0] : '.';

  // Create a Directory object
  final directory = Directory(directoryPath);
  if(debug) print("LS created dirpath: $directoryPath");

  // Check if the directory exists
  if (await directory.exists()) {
    if(debug) print("LS dir esists ");
    // List all files and directories in the specified path
    List<FileSystemEntity> entities = directory.listSync();
    if(debug) print("LS dir content: $entities");
  StringBuffer result = StringBuffer();
    // Print each entity's name and type
    for (var entity in entities) {
      String type = entity is Directory ? 'Directory' : 'File';
      result.writeln('$type: ${entity.path}');
    }
    if(debug) print("LS about to return : $result ");

    output?.write(result.toString());
      return ProcessResult(0, 0, result.toString(), '');
  } else {
    //print('Directory does not exist: $directoryPath');
    String errorMessage = 'Directory does not exist: $directoryPath';
    if(debug) print("LS error: about to return : $directoryPath ");
    error?.writeln(errorMessage);
    return ProcessResult(0, 1, '', errorMessage);
  }
 }
}
