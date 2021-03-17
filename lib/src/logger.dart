class Logger {
  static void logInfo(String message, {bool lineBreak = false}) {
    if (lineBreak) {
      print("\n[INFO] $message");
    } else {
      print("[INFO] $message");
    }
  }

  static void logWarning(String message) {
    print("[WARNING] $message");
  }

  static void logError(String message) {
    print("[ERROR] $message");
  }
}
