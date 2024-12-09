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

class Cache {
  static final Map<Type, Map<String, ServerObject>> serverObjects = {};

  static void clear() {
    print('Clearing cache');
    serverObjects.clear();
  }
}

class SubscriptionManager {
  static final Map<Type, Map<String, List<ServerObjectSubscriber>>>
      _subscribers = {};

  static void subscribeAll<T extends ServerObject>(
      ServerObjectSubscriber subscriber) {
    subscribe<T>(subscriber, '*');
  }

  static void subscribe<T extends ServerObject>(
      ServerObjectSubscriber subscriber, String id,
      {bool forceFetch = false}) {
    if (!_subscribers.containsKey(T)) {
      _subscribers[T] = {};
    }

    if (!_subscribers[T]!.containsKey(id)) {
      _subscribers[T]![id] = [];
    }

    _subscribers[T]![id]!.add(subscriber);

    if (Cache.serverObjects.containsKey(T) &&
        Cache.serverObjects[T]!.containsKey(id)) {
      subscriber.onUpdate(Cache.serverObjects[T]![id]!);
      if (forceFetch) {
        Backend.fetch<T>(id);
      }
    } else {
      subscriber.onUpdate(ServerObject.empty<T>(id));
      Backend.fetch<T>(id);
    }
  }

  static unsubscribe(ServerObjectSubscriber subscriber) {
    var oldSubscribers =
        Map<Type, Map<String, ServerObjectSubscriber>>.from(_subscribers);

    for (var type in oldSubscribers.keys) {
      var oldSubscribersOfType =
          Map<String, ServerObjectSubscriber>.from(oldSubscribers[type]!);
      for (var id in oldSubscribersOfType.keys) {
        if (oldSubscribersOfType[id] == subscriber) {
          _subscribers[type]!.remove(id);
        }
      }
    }
  }

  static void notifyUpdate(ServerObject object) {
    if (!Cache.serverObjects.containsKey(object.runtimeType)) {
      Cache.serverObjects[object.runtimeType] = {};
    }

    Cache.serverObjects[object.runtimeType]![object.id] = object;

    if (!_subscribers.containsKey(object.runtimeType)) {
      return;
    }

    for (var typeSubscribers in _subscribers[object.runtimeType]!.keys) {
      if (typeSubscribers == object.id || typeSubscribers == '*') {
        for (var subscriber
            in _subscribers[object.runtimeType]![typeSubscribers]!) {
          subscriber.onUpdate(object);
        }
      }
    }
  }
}
