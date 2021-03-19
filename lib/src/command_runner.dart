import 'dart:io';

import 'package:app_starter/src/logger.dart';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import 'models/app_model.dart';

class CommandRunner {
  // Method called on app creation
  void create(List<String> args) async {
    final ArgParser parser = ArgParser()
      ..addOption(
        "name",
        abbr: "n",
        defaultsTo: null,
      )
      ..addOption(
        "template",
        abbr: "t",
        defaultsTo: null,
      )
      ..addOption(
        "org",
        abbr: "o",
        defaultsTo: null,
      )
      ..addFlag(
        "save",
        abbr: "s",
        negatable: false,
        defaultsTo: false,
      );

    final results = parser.parse(args);

    final bool save = results["save"];

    final AppModel appModelFomConfig = AppModel.fromConfigFile();

    final AppModel appModel = AppModel(
      name: results["name"] ?? appModelFomConfig.name,
      organization: results["org"] ?? appModelFomConfig.organization,
      templateRepository: results["template"] ?? appModelFomConfig.templateRepository,
    );

    bool hasOneFiledNull = false;

    if (appModel.name == null) {
      Logger.logError("Package identifier argument not found, neither in config. --name or -n to add one.");
      hasOneFiledNull = true;
    }

    if (appModel.organization == null) {
      Logger.logError("Organization identifier not found, neither in config. --org or -o to add one.");
      hasOneFiledNull = true;
    }

    if (appModel.templateRepository == null) {
      Logger.logError("Template url not found, neither in config. --template or -t to use one.");
      hasOneFiledNull = true;
    }

    if (!appModel.hasValidPackageName()) {
      Logger.logError("${appModel.name} is not a dart valid package name");
      hasOneFiledNull = true;
    }

    if (hasOneFiledNull) return;

    if (save) {
      appModel.writeInConfigFile();
    }

    Logger.logInfo("Let's create ${appModel.name} application !");

    final Directory current = Directory.current;
    final String workingDirectoryPath = current.path;

    try {
      Logger.logInfo("Creating flutter project using your current flutter version...");

      Process.runSync(
        "flutter",
        [
          "create",
          "--org",
          appModel.organization!,
          appModel.name!,
        ],
        workingDirectory: workingDirectoryPath,
        runInShell: true,
      );

      Logger.logInfo("Retrieving your template from ${appModel.templateRepository}...");

      Process.runSync(
        "git",
        [
          "clone",
          appModel.templateRepository!,
          "temp",
        ],
        workingDirectory: "$workingDirectoryPath",
        runInShell: true,
      );

      final String content = await File("$workingDirectoryPath/temp/pubspec.yaml").readAsString();
      final mapData = loadYaml(content);
      final String templatePackageName = mapData["name"];

      _copyPasteDirectory(
        "$workingDirectoryPath/temp/lib",
        "$workingDirectoryPath/${appModel.name}/lib",
      );

      _copyPasteDirectory(
        "$workingDirectoryPath/temp/test",
        "$workingDirectoryPath/${appModel.name}/test",
      );

      await _copyPasteFileContent(
        "$workingDirectoryPath/temp/pubspec.yaml",
        "$workingDirectoryPath/${appModel.name}/pubspec.yaml",
      );

      await _changeAllInFile(
        "$workingDirectoryPath/${appModel.name}/pubspec.yaml",
        templatePackageName,
        appModel.name!,
      );

      await _changeAllInDirectory(
        "$workingDirectoryPath/${appModel.name}/lib",
        templatePackageName,
        appModel.name!,
      );

      await _changeAllInDirectory(
        "$workingDirectoryPath/${appModel.name}/test",
        templatePackageName,
        appModel.name!,
      );

      Process.runSync(
        "flutter",
        [
          "pub",
          "get",
        ],
        workingDirectory: "$workingDirectoryPath/${appModel.name}",
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
          "$workingDirectoryPath/${appModel.name}",
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
  Future<void> _copyPasteFileContent(String sourceFilePath, String targetFilePath) async {
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
  Future<void> _changeAllInDirectory(String directoryPath, String oldPackageName, String newPackageName) async {
    final Directory directory = Directory(directoryPath);
    final String dirName = directoryPath.split("/").last;
    if (directory.existsSync()) {
      final List<FileSystemEntity> files = directory.listSync(recursive: true);
      await Future.forEach(
        files,
        (FileSystemEntity fileSystemEntity) async {
          if (fileSystemEntity is File) {
            await _changeAllInFile(fileSystemEntity.path, oldPackageName, newPackageName);
          }
        },
      );
      Logger.logInfo("All files in $dirName updated with new package name ($newPackageName)");
    } else {
      Logger.logWarning("Missing directory $dirName in your template, it will be ignored");
    }
  }

  // Update recursively all imports in [filePath] from [oldPackageName] to [newPackageName]
  Future<void> _changeAllInFile(String filePath, String oldValue, String newValue) async {
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
}
