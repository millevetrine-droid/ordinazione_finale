class Logger {
  static void info(String message) {
    // Nessun print - completamente silenzioso in produzione
    // I log appariranno solo in modalità debug
    assert(() {
      // Questo codice viene rimosso in produzione
      return true;
    }());
  }

  static void warning(String message) {
    assert(() {
      return true;
    }());
  }

  static void error(String message) {
    assert(() {
      return true;
    }());
  }

  static void success(String message) {
    assert(() {
      return true;
    }());
  }

  static void debug(String message) {
    assert(() {
      return true;
    }());
  }
}