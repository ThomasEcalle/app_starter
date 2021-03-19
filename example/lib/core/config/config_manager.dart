import 'package:example/core/config/flavor.dart';
import 'package:flutter/cupertino.dart';

class ConfigManager extends InheritedWidget {
  ConfigManager({
    Key key,
    @required Widget child,
    this.apiBaseUrl,
    this.flavor,
  }) : super(key: key, child: child);

  final String apiBaseUrl;
  final Flavor flavor;

  static ConfigManager of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: ConfigManager);
  }

  @override
  bool updateShouldNotify(ConfigManager oldWidget) => oldWidget.apiBaseUrl != apiBaseUrl;
}
