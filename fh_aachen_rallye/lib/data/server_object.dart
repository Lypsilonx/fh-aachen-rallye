import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/user.dart';

abstract class ServerObject {
  final String id;

  const ServerObject(this.id);

  Map<String, dynamic> toJson();

  ServerObject fromJson<T extends ServerObject>(Map<String, dynamic> json) {
    if (T.toString() == (Challenge).toString()) {
      return Challenge.fromJson(json);
    } else if (T.toString() == (User).toString()) {
      return User.fromJson(json);
    } else {
      throw Exception('Unknown type');
    }
  }

  static ServerObject empty<T extends ServerObject>(String id) {
    if (T.toString() == (Challenge).toString()) {
      return Challenge.empty(id);
    } else if (T.toString() == (User).toString()) {
      return User.empty(id);
    } else {
      throw Exception('Unknown type');
    }
  }
}

abstract class ServerObjectSubscriber {
  void onUpdate(ServerObject object);
}

class SubscriptionManager {
  static final Map<Type, List<ServerObjectSubscriber>> _subscribers = {};
  static final Map<Type, Map<String, ServerObject>> _cachedObjects = {};

  static void subscribe<T extends ServerObject>(
      ServerObjectSubscriber subscriber,
      {String id = ''}) {
    if (!_subscribers.containsKey(T)) {
      _subscribers[T] = [];
    }

    _subscribers[T]!.add(subscriber);

    if (id.isNotEmpty) {
      if (_cachedObjects.containsKey(T) && _cachedObjects[T]!.containsKey(id)) {
        subscriber.onUpdate(_cachedObjects[T]![id]!);
      } else {
        subscriber.onUpdate(ServerObject.empty<T>(id));
        Backend.fetch<T>(id);
      }
    }
  }

  static void unsubscribe<T extends ServerObject>(
      ServerObjectSubscriber subscriber) {
    if (!_subscribers.containsKey(T)) {
      return;
    }

    _subscribers[T]!.remove(subscriber);
  }

  static void notifyUpdate(ServerObject object) {
    if (!_cachedObjects.containsKey(object.runtimeType)) {
      _cachedObjects[object.runtimeType] = {};
    }

    _cachedObjects[object.runtimeType]![object.id] = object;

    if (!_subscribers.containsKey(object.runtimeType)) {
      return;
    }

    for (var element in _subscribers[object.runtimeType]!) {
      element.onUpdate(object);
    }
  }
}
