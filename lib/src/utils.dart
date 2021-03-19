import 'dart:io';

class Utils {
  // A valid Dart identifier that can be used for a package, i.e. no
  // capital letters.
  // https://dart.dev/guides/language/language-tour#important-concepts
  static final RegExp identifierRegExp = RegExp("[a-z_][a-z0-9_]*");

  // Name of the config file used to store information
  static const String configFileName = ".app_starter_config";

  // Return the config file
  static File getConfigFile() {
    final envVarMap = Platform.environment;
    final String home = envVarMap["HOME"] ?? "";

    return File("$home/${Utils.configFileName}");
  }
}
