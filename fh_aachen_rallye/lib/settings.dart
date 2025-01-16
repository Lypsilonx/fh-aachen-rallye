import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_setting.dart';

class Settings {
  static FunSetting getWidget<T>(SettingsEntry<T> entry) {
    return FunSetting<T>(
      entry,
    );
  }

  static T get<T>(SettingsEntry<T> entry) {
    var value = Backend.prefs.get(entry.key);
    if (value == null) {
      return entry.defaultValue;
    }
    return value as T;
  }

  static void set<T>(SettingsEntry<T> entry, T value) {
    switch (T) {
      case bool:
        Backend.prefs.setBool(entry.key, value as bool);
        break;
      case int:
        int intValue = value as int;
        intValue = intValue
            .clamp(
              entry.options['min'] ?? double.negativeInfinity,
              entry.options['max'] ?? double.infinity,
            )
            .toInt();
        Backend.prefs.setInt(entry.key, intValue);
        break;
      case double:
        double doubleValue = value as double;
        doubleValue = doubleValue
            .clamp(
              entry.options['min'] ?? double.negativeInfinity,
              entry.options['max'] ?? double.infinity,
            )
            .toDouble();
        Backend.prefs.setDouble(entry.key, doubleValue);
        break;
      case String:
        String stringValue = value as String;
        if (entry.options['maxLength'] != null &&
            stringValue.length > entry.options['maxLength']) {
          stringValue = stringValue.substring(0, entry.options['maxLength']);
        }
        if (entry.options['minLength'] != null &&
            stringValue.length < entry.options['minLength']) {
          return;
        }
        if (entry.options['regex'] != null &&
            !RegExp(entry.options['regex']).hasMatch(stringValue)) {
          return;
        }
        Backend.prefs.setString(entry.key, stringValue);
        break;
      default:
        throw Exception('Unknown type');
    }
  }

  // Show WIP Challenges
  static FunSetting get showWipChallengesWidget =>
      getWidget(SettingsEntry.showWipChallenges);
  static bool get showWipChallenges => get(SettingsEntry.showWipChallenges);
  static set showWipChallenges(bool value) =>
      set(SettingsEntry.showWipChallenges, value);
}

class SettingsEntry<T> {
  final String key;
  final T defaultValue;
  final Map<String, dynamic> options;

  const SettingsEntry(this.key, this.defaultValue, {this.options = const {}});

  static const showWipChallenges =
      SettingsEntry<bool>('SETTING_SHOW_WIP_CHALLENGES', false);
}
