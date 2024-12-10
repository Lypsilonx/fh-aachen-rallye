import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/translation.dart';
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
    } else if (T.toString() == (Translation).toString()) {
      return Translation.fromJson(json);
    } else {
      throw Exception('Unknown type');
    }
  }

  static ServerObject empty<T extends ServerObject>(String id) {
    if (T.toString() == (Challenge).toString()) {
      return Challenge.empty(id);
    } else if (T.toString() == (User).toString()) {
      return User.empty(id);
    } else if (T.toString() == (Translation).toString()) {
      return Translation.empty(id);
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

  static void clear({List<Type> dontDelete = const []}) {
    print(
        'Clearing cache${dontDelete.isNotEmpty ? ' except $dontDelete' : ''}');

    for (var type in serverObjects.keys) {
      if (!dontDelete.contains(type)) {
        serverObjects[type]!.clear();
      }
    }
  }
}

class SubscriptionManager {
  static final Map<Type, Map<String, List<ServerObjectSubscriber>>>
      _subscribers = {};

  // Called every time an object of the type T is requested (passes object in onUpdate)
  static void subscribeAny<T extends ServerObject>(
      ServerObjectSubscriber subscriber) {
    subscribe<T>(subscriber, '*');
  }

  // Called ONCE if either a specific object or all objects of the type T are requested (passes EMPTY object in onUpdate)
  static void subscribeAll<T extends ServerObject>(
      ServerObjectSubscriber subscriber) {
    subscribe<T>(subscriber, 'all');
  }

  // Called every time a specific object is requested (passes that object in onUpdate)
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
        Map<Type, Map<String, List<ServerObjectSubscriber>>>.from(_subscribers);

    for (var type in oldSubscribers.keys) {
      var oldSubscribersOfType =
          Map<String, List<ServerObjectSubscriber>>.from(oldSubscribers[type]!);
      for (var id in oldSubscribersOfType.keys) {
        var oldSubscribersOfId =
            List<ServerObjectSubscriber>.from(oldSubscribersOfType[id]!);
        for (var oldSubscriber in oldSubscribersOfId) {
          if (oldSubscriber == subscriber) {
            _subscribers[type]![id]!.remove(subscriber);
          }
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

  static void notifyAll<T extends ServerObject>() {
    if (!Cache.serverObjects.containsKey(T)) {
      return;
    }

    for (var typeSubscribers in _subscribers[T]!.keys) {
      if (typeSubscribers == 'all') {
        for (var subscriber in _subscribers[T]![typeSubscribers]!) {
          subscriber.onUpdate(ServerObject.empty<T>('*'));
        }
      }
    }
  }
}
