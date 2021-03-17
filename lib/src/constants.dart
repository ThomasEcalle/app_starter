class Constants {
  // A valid Dart identifier that can be used for a package, i.e. no
  // capital letters.
  // https://dart.dev/guides/language/language-tour#important-concepts
  static final RegExp identifierRegExp = RegExp("[a-z_][a-z0-9_]*");

  // Default Dart Package identifier
  static final String defaultPackageIdentifier = "example";

  // Default Repository where the package will get the template from
  static final String defaultTemplateRepository = "git@github.com:ThomasEcalle/flappy_template.git";

  // Default organization id (here, with the default package identidier beeing 'example',
  // then the package id will be 'com.example.example'
  static final String organization = "com.example";
}
