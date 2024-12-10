import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/translation.dart';
import 'package:flutter/material.dart';

class Translator implements ServerObjectSubscriber {
  static Language _language = Language.en;
  static Language get language => _language;

  static final Map<TranslatedState, Function> _subscribers = {};

  Translator() {
    String? savedLanguage = Backend.prefs.getString('language');
    if (savedLanguage != null) {
      _language = Language.values
          .firstWhere((element) => element.name == savedLanguage);
    }
    SubscriptionManager.subscribeAll<Translation>(this);
  }

  static void subscribe(TranslatedState subscriber, Function setState) {
    if (!_subscribers.containsKey(subscriber)) {
      _subscribers[subscriber] = setState;
    }
  }

  static void unsubscribe(TranslatedState subscriber) {
    _subscribers.remove(subscriber);
  }

  static void setLanguage(Language language) {
    _language = language;
    Backend.prefs.setString('language', language.name);
    updateSubscribers();
  }

  @override
  void onUpdate(ServerObject object) {
    updateSubscribers();
  }

  static void updateSubscribers() {
    for (var subscriberSetState in _subscribers.values) {
      subscriberSetState(() {});
    }
  }

  static String translate(String key, String fallback) {
    if (Cache.serverObjects[Translation] != null) {
      for (var translation in Cache.serverObjects[Translation]!.values) {
        if (translation is Translation) {
          if (translation.key == key &&
              translation.language == _language.name) {
            return translation.value;
          }
        }
      }
    }
    if (fallback.isEmpty) {
      var readableKey = key.replaceAll('_', ' ');
      readableKey =
          readableKey[0].toUpperCase() + readableKey.substring(1).toLowerCase();
      return readableKey;
    }
    return fallback;
  }
}

abstract class TranslatedState<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    Translator.subscribe(this, setState);
  }

  @override
  void dispose() {
    Translator.unsubscribe(this);
    super.dispose();
  }

  String translate(String key, {String fallback = ''}) {
    String translation = Translator.translate(key, fallback);
    return translation;
  }
}

enum Language { en, de }
