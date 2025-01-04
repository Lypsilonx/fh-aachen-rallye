import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/cache.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/translation.dart';
import 'package:fh_aachen_rallye/data/user.dart';

abstract class ServerObject {
  final String id;

  const ServerObject(this.id);

  Map<String, dynamic> toJson();

  static ServerObject fromJson<T extends ServerObject>(
      Map<String, dynamic> json) {
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
      ServerObjectSubscriber subscriber, String id) {
    if (!_subscribers.containsKey(T)) {
      _subscribers[T] = {};
    }

    if (!_subscribers[T]!.containsKey(id)) {
      _subscribers[T]![id] = [];
    }

    _subscribers[T]![id]!.add(subscriber);

    if (Cache.contains(T, id: id)) {
      subscriber.onUpdate(Cache.fetch<T>(id)!);
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

            if (_subscribers[type]![id]!.isEmpty) {
              _subscribers[type]!.remove(id);
            }
          }
        }
      }
    }
  }

  static void pollCache() async {
    var pollList = createCachePollList();
    var (result, message) =
        await Backend.apiRequest('POST', 'pollCache', body: {
      'poll_list': pollList,
    });

    if (result == null) {
      return;
    }

    if (!result.containsKey('update_list')) {
      return;
    }

    List<String> updateList =
        result['update_list'].map<String>((e) => e as String).toList();

    for (var update in updateList) {
      var type = update.split(':')[0];
      var id = update.split(':')[1];

      if (type == 'Challenge') {
        if (Backend.state.user != null) {
          Backend.fetch<Challenge>(id);
        }
      } else if (type == 'User') {
        if (Backend.state.user != null) {
          Backend.fetch<User>(id);
        }
      } else if (type == 'Translation') {
        Backend.fetch<Translation>(id);
      }
    }
  }

  static List<Map<String, dynamic>> createCachePollList() {
    List<Map<String, dynamic>> pollList = [];
    for (var type in _subscribers.keys) {
      var typeString = "";

      if (type.toString() == (Challenge).toString()) {
        typeString = "Challenge";
      } else if (type.toString() == (User).toString()) {
        typeString = "User";
      } else if (type.toString() == (Translation).toString()) {
        typeString = "Translation";
      }

      if (_subscribers[type]!.containsKey('*')) {
        pollList.add({
          "type": typeString,
          "id": "*",
          "lastUpdate": Cache.lastUpdate(type)?.millisecondsSinceEpoch ?? 0
        });
        continue;
      }
      if (_subscribers[type]!.containsKey('all')) {
        pollList.add({
          "type": typeString,
          "id": "all",
          "lastUpdate": Cache.lastUpdate(type)?.millisecondsSinceEpoch ?? 0
        });
      }
      for (var id in _subscribers[type]!.keys) {
        if (id != '*' && id != 'all') {
          pollList.add({
            "type": typeString,
            "id": id,
            "lastUpdate":
                Cache.lastUpdate(type, id: id)?.millisecondsSinceEpoch ?? 0
          });
        }
      }
    }

    return pollList;
  }

  static void notifyUpdate(ServerObject object) {
    Cache.store(object);

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
    if (!Cache.contains(T)) {
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
