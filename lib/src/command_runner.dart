import 'dart:io';

import 'package:app_starter/src/logger.dart';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import 'constants.dart';

class CommandRunner {
  // Method called on app creation
  void create(List<String> args) async {
    final ArgParser parser = ArgParser();
    parser.addOption("name",
        abbr: "n", defaultsTo: Constants.defaultPackageIdentifier);
    parser.addOption("template",
        abbr: "t", defaultsTo: Constants.defaultTemplateRepository);
    parser.addOption("org", abbr: "o", defaultsTo: Constants.organization);

    final results = parser.parse(args);

    final String _projectName = results["name"];
    final String _gitRemoteURL = results["template"];
    final String _organization = results["org"];

    if (!_isValidPackageName(_projectName)) {
      Logger.logError("This is not a dart valid package name");
      return;
    }

    Logger.logInfo("Let's create $_projectName application !");

    final Directory current = Directory.current;
    final String workingDirectoryPath = current.path;

    try {
      Logger.logInfo(
          "Creating flutter project using your current flutter version...");

      Process.runSync(
        "flutter",
        [
          "create",
          "--org",
          _organization,
          _projectName,
        ],
        workingDirectory: workingDirectoryPath,
        runInShell: true,
      );

      Logger.logInfo("Retrieving your template from $_gitRemoteURL...");

      Process.runSync(
        "git",
        [
          "clone",
          _gitRemoteURL,
          "temp",
        ],
        workingDirectory: "$workingDirectoryPath",
        runInShell: true,
      );

      final String content =
          await File("$workingDirectoryPath/temp/pubspec.yaml").readAsString();
      final mapData = loadYaml(content);
      final String templatePackageName = mapData["name"];

      _copyPasteDirectory(
        "$workingDirectoryPath/temp/lib",
        "$workingDirectoryPath/$_projectName/lib",
      );

      _copyPasteDirectory(
        "$workingDirectoryPath/temp/test",
        "$workingDirectoryPath/$_projectName/test",
      );

      await _copyPasteFileContent(
        "$workingDirectoryPath/temp/pubspec.yaml",
        "$workingDirectoryPath/$_projectName/pubspec.yaml",
      );

      await _changeAllInFile(
        "$workingDirectoryPath/$_projectName/pubspec.yaml",
        templatePackageName,
        _projectName,
      );

      await _changeAllInDirectory(
        "$workingDirectoryPath/$_projectName/lib",
        templatePackageName,
        _projectName,
      );

      await _changeAllInDirectory(
        "$workingDirectoryPath/$_projectName/test",
        templatePackageName,
        _projectName,
      );

      Process.runSync(
        "flutter",
        [
          "pub",
          "get",
        ],
        workingDirectory: "$workingDirectoryPath/$_projectName",
      );

      Logger.logInfo("Deleting temp files used for generation...");

      Process.runSync(
        "rm",
        [
          "-rf",
          "$workingDirectoryPath/temp",
        ],
      );

      Logger.logInfo("You are good to go ! :)", lineBreak: true);
    } catch (error) {
      Logger.logError("Error creating project : $error");

      Process.runSync(
        "rm",
        [
          "-rf",
          "$workingDirectoryPath/$_projectName",
        ],
      );
      Process.runSync(
        "rm",
        [
          "-rf",
          "$workingDirectoryPath/temp",
        ],
      );
    }
  }

  // Copy all the content of [sourceFilePath] and paste it in [targetFilePath]
  Future<void> _copyPasteFileContent(
      String sourceFilePath, String targetFilePath) async {
    try {
      final File sourceFile = File(sourceFilePath);
      final File targetFile = File(targetFilePath);

      final String sourceContent = sourceFile.readAsStringSync();
      targetFile.writeAsStringSync(sourceContent);
    } catch (error) {
      Logger.logError("Error copying file contents : $error");
    }
  }

  // Copy all the content of [sourceDirPath] and paste it in [targetDirPath]
  void _copyPasteDirectory(
    String sourceDirPath,
    String targetDirPath,
  ) {
    Process.runSync(
      "rm",
      [
        "-rf",
        targetDirPath,
      ],
    );

    Process.runSync(
      "cp",
      [
        "-r",
        sourceDirPath,
        targetDirPath,
      ],
    );
  }

  // Update recursively all imports in [directoryPath] from [oldPackageName] to [newPackageName]
  Future<void> _changeAllInDirectory(String directoryPath,
      String oldPackageName, String newPackageName) async {
    final Directory directory = Directory(directoryPath);
    final String dirName = directoryPath.split("/").last;
    if (directory.existsSync()) {
      final List<FileSystemEntity> files = directory.listSync(recursive: true);
      await Future.forEach(
        files,
        (FileSystemEntity fileSystemEntity) async {
          if (fileSystemEntity is File) {
            await _changeAllInFile(
                fileSystemEntity.path, oldPackageName, newPackageName);
          }
        },
      );
      Logger.logInfo(
          "All files in $dirName updated with new package name ($newPackageName)");
    } else {
      Logger.logWarning(
          "Missing directory $dirName in your template, it will be ignored");
    }
  }

  // Update recursively all imports in [filePath] from [oldPackageName] to [newPackageName]
  Future<void> _changeAllInFile(
      String filePath, String oldValue, String newValue) async {
    try {
      final File file = File(filePath);
      final String content = file.readAsStringSync();
      if (content.contains(oldValue)) {
        final String newContent = content.replaceAll(oldValue, newValue);
        file.writeAsStringSync(newContent);
      }
    } catch (error) {
      Logger.logError("Error updating file $filePath : $error");
    }
  }

  // Return if package identifier is a valid one or not, base on dart specifications
  bool _isValidPackageName(String name) {
    final match = Constants.identifierRegExp.matchAsPrefix(name);
    return match != null && match.end == name.length;
  }
}
