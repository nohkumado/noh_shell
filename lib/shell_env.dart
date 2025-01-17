import 'dart:io';

class ShellEnv {
  final Map<String, String> _env = {};

  @override
  String toString() {
    StringBuffer result = StringBuffer();
    _env.forEach((key, value) {
      String line = '$key=$value\n';
      result.write(line);
    });
    return '$result';
  }

  ShellEnv() {
    // Initialize with system environment variables
    _env.addAll(Platform.environment);
  }

  String? operator [](String key) {
    return _env[key] ?? Platform.environment[key];
  }

  void operator []=(String key, String value) {
    _env[key] = value;
  }

  void set(String key, String value) {
    _env[key] = value;
  }

  void unset(String key) {
    _env.remove(key);
  }

  bool contains(String key) {
    return _env.containsKey(key) || Platform.environment.containsKey(key);
  }

  Map<String, String> getAll() {
    return Map<String, String>.from(_env)..addAll(Platform.environment);
  }

  String get(String key, {String defaultValue = ''}) {
    return this[key] ?? defaultValue;
  }

  // Convenience getters for common environment variables
  String get user => get('USER', defaultValue: 'user');
  String get home => get('HOME', defaultValue: '/');
  String get hostname => get('HOSTNAME', defaultValue: 'localhost');
  String get pwd => get('PWD', defaultValue: Directory.current.path);

  toMap()
  {
    return _env;
  }
}
