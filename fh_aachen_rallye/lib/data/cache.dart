import 'package:fh_aachen_rallye/data/server_object.dart';

class Cache {
  static final Map<Type,
          Map<String, (ServerObject object, DateTime lastUpdate)>>
      _serverObjects = {};

  static void store(ServerObject object) {
    if (!_serverObjects.containsKey(object.runtimeType)) {
      _serverObjects[object.runtimeType] = {};
    }

    _serverObjects[object.runtimeType]![object.id] = (object, DateTime.now());
  }

  static bool contains(Type t, {String? id}) {
    if (!_serverObjects.containsKey(t)) {
      return false;
    }

    if (id == null) {
      return true;
    }

    if (!_serverObjects[t]!.containsKey(id)) {
      return false;
    }

    return true;
  }

  static T? fetch<T extends ServerObject>(String id) {
    if (!contains(T, id: id)) {
      return null;
    }

    return _serverObjects[T]![id]!.$1 as T;
  }

  static List<T> fetchAll<T extends ServerObject>() {
    if (!contains(T)) {
      return [];
    }

    return _serverObjects[T]!.values.map((e) => e.$1 as T).toList();
  }

  static DateTime? lastUpdate(Type t, {String? id}) {
    if (id == null) {
      DateTime? lastUpdate;

      for (var type in _serverObjects.keys) {
        for (var lastUpdateEntry in _serverObjects[type]!.values) {
          if (lastUpdate == null || lastUpdateEntry.$2.isAfter(lastUpdate)) {
            lastUpdate = lastUpdateEntry.$2;
          }
        }
      }

      return lastUpdate;
    }

    if (!contains(t, id: id)) {
      return null;
    }

    return _serverObjects[t]![id]!.$2;
  }

  static void clearType<T extends ServerObject>() {
    print('Clearing cache for ${T.toString()}');

    if (!contains(T)) {
      return;
    }

    _serverObjects[T]!.clear();
  }

  static void clear({List<Type> dontDelete = const []}) {
    print(
        'Clearing cache${dontDelete.isNotEmpty ? ' except $dontDelete' : ''}');

    for (var type in _serverObjects.keys) {
      if (!dontDelete.contains(type)) {
        _serverObjects[type]!.clear();
      }
    }
  }
}
