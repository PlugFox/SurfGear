/// Не найдены модули. Например, пользователь указал неправильный путь.
class ModulesNotFoundException implements Exception {
  final String message;

  ModulesNotFoundException(this.message);
}

/// Модуль, помеченный как stable, был изменён.
class StableModulesWasModifiedException implements Exception {
  final String message;

  StableModulesWasModifiedException(this.message);
}

class ModuleNotReadyForOpenSours implements Exception {
  final String message;

  ModuleNotReadyForOpenSours(this.message);
}

class ModuleNotReadyReleaseVersion implements Exception {
  final String message;

  ModuleNotReadyReleaseVersion(this.message);
}
