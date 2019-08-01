class Warning {
  final String warning;
  final String path;

  Warning(this.warning, this.path);
}

class WithWarning<T> {
  final T result;
  final List<Warning> warnings;

  WithWarning(this.result, this.warnings);
}
