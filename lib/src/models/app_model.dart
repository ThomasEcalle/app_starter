import 'dart:convert';
import 'dart:io';

import 'package:app_starter/src/utils.dart';

// Model representing app information
class AppModel {
  final String? name;
  final String? organization;
  final String? templateRepository;

  AppModel({
    required this.name,
    required this.organization,
    required this.templateRepository,
  });

  // Generate AppModel instance from configuration file
  factory AppModel.fromConfigFile() {
    final File configFile = Utils.getConfigFile();
    if (configFile.existsSync()) {
      final Map<String, dynamic> json = jsonDecode(configFile.readAsStringSync());
      return AppModel(
        name: json["name"],
        organization: json["organization"],
        templateRepository: json["template"],
      );
    }

    return AppModel(name: null, organization: null, templateRepository: null);
  }

  // Write information in config file
  void writeInConfigFile() {
    final String jsonText = _toJsonText();
    final File configFile = Utils.getConfigFile();
    configFile.writeAsStringSync(jsonText, mode: FileMode.write);
  }

  // Return if package identifier is a valid one or not, base on dart specifications
  bool hasValidPackageName() {
    if (name != null) {
      final match = Utils.identifierRegExp.matchAsPrefix(name!);
      return match != null && match.end == name!.length;
    }
    return false;
  }

  // Returns Json-String formatted AppModel
  String _toJsonText() {
    final map = {
      "name": name,
      "organization": organization,
      "template": templateRepository,
    };

    return jsonEncode(map);
  }
}
