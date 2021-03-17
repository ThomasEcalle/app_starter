import 'package:example/app.dart';
import 'package:example/core/core.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(ConfigManager(
    apiBaseUrl: "prod_api_base_url",
    flavor: Flavor.prod,
    child: App(),
  ));
}
