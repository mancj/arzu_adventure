class GamePreferencesManager {
  Map<String, dynamic> prefs = {};

  bool get isSoundEnabled => prefs.containsKey('sounds');

  set isSoundEnabled(bool value) => prefs['sounds'] = value;
}
