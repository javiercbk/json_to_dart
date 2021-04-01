class Warning {
  Warning(this.warning, this.path);
  final String warning;
  final String path;

}

class WithWarning<T> {
  WithWarning(this.result, this.warnings);
  final T result;
  final List<Warning> warnings;

}
