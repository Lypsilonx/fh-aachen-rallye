import 'dart:convert';

import 'package:fh_aachen_rallye/data/cache.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/translation.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Backend {
  static late BackendState state;
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    state = BackendState();
    Translator();
  }

  static const String url =
      'https://www.politischdekoriert.de/fh-aachen-rallye';
  static const String apiUrl = '$url/api/public/index.php/';
  static late SharedPreferences prefs;

  static Future<String> patch(
      ServerObject object, Map<String, dynamic> changes) async {
    print('Patching object: $object with $changes');
    // Patch object on server
    if (object is User) {
      var (_, message) =
          await apiRequest('PATCH', 'users/${object.id}', body: changes);
      fetch<User>(object.id);
      return message;
    }

    return '';
  }

  static void fetch<T extends ServerObject>(String id) async {
    print('Fetching object: $T with id $id');

    String requestEndpoint = '';
    String requestArgs = '';

    if (T.toString() == (User).toString()) {
      requestEndpoint = 'users';
      requestArgs = 'includeChallengeStates=true';
    } else if (T.toString() == (Challenge).toString()) {
      requestEndpoint = 'challenges';
      requestArgs = 'includeSteps=true&language=${Translator.language.name}';
    } else if (T.toString() == (Translation).toString()) {
      requestEndpoint = 'translations';
      requestArgs = '';
    } else {
      throw Exception('Unknown type');
    }

    if (id == '*' || id == 'all') {
      var (requestedObjects, _) =
          await apiRequest('GET', '$requestEndpoint?$requestArgs');
      while (true) {
        if (requestedObjects != null) {
          for (var json in requestedObjects['data']) {
            var object = ServerObject.fromJson<T>(json);
            SubscriptionManager.notifyUpdate(object);
          }

          if (requestedObjects['links']['next'] != null) {
            (requestedObjects, _) = await webRequest(
                'GET', requestedObjects['links']['next'] + '&$requestArgs');
          } else {
            break;
          }
        }
      }
    } else {
      var (requestedObject, _) =
          await apiRequest('GET', '$requestEndpoint/$id?$requestArgs');
      if (requestedObject != null) {
        var user = ServerObject.fromJson<T>(requestedObject['data']);
        SubscriptionManager.notifyUpdate(user);
      }
    }
    SubscriptionManager.notifyAll<T>();
  }

  static String? get userId => prefs.getString('userId');

  static Future<(dynamic, String)> apiRequest(String method, String path,
      {Map<String, dynamic>? body}) async {
    return webRequest(method, "${apiUrl}api/v1/$path", body: body);
  }

  static Future<(dynamic, String)> webRequest(String method, String path,
      {Map<String, dynamic>? body}) async {
    var url = Uri.parse(path);
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (prefs.getString('token') != null) {
      headers.addEntries(
          [MapEntry('Authorization', 'Bearer ${prefs.getString('token')}')]);
    }
    var result = await switch (method) {
      'GET' => http.get(url, headers: headers),
      'POST' => http.post(url, body: jsonEncode(body), headers: headers),
      'PUT' => http.put(url, body: jsonEncode(body), headers: headers),
      'PATCH' => http.patch(url, body: jsonEncode(body), headers: headers),
      'DELETE' => http.delete(url, headers: headers),
      _ => null,
    };

    if (result == null) {
      return (null, 'Invalid method');
    }

    if (result.statusCode != 201 && result.statusCode != 200) {
      if (body != null) {
        print('Body: $body');
      }
      print(
          'The $method request to $path failed with status code ${result.statusCode}');
      print('Response: ${result.body}');
      return (null, result.body);
    }

    return (jsonDecode(result.body), '');
  }

  // TEMP
  static Future<(bool, String)> setChallengeState(
      String challengeId, ChallengeState challengeState) async {
    print('Setting challenge state of $challengeId');
    state.user!.challengeStates[challengeId] = challengeState;

    var (result, message) =
        await apiRequest('POST', 'game/setChallengeState', body: {
      'challenge_id': challengeId,
      'state': jsonEncode(challengeState),
    });
    if (challengeState.step == -2) {
      Backend.fetch<Challenge>('all');
    }
    Backend.fetch<User>(Backend.state.user!.id);
    if (result != null) {
      return (true, '');
    }

    return (false, message);
  }

  static Future<(bool, String)> login(String username, String password) async {
    print('Logging in $username');
    var (result, message) = await apiRequest('POST', 'auth/login', body: {
      'username': username,
      'password': password,
    });
    if (result != null) {
      prefs.setString('userId', result['userId']);
      prefs.setString('token', result['token']);
      state.trySubscribe();
      return (true, '');
    }

    return (false, message);
  }

  static void logout(BuildContext context) {
    Cache.clear(dontDelete: [Translation]);
    Navigator.popUntil(context, (route) => route.isFirst);
    Translator.setLanguage(Translator.defaultLanguage);
    Navigator.pushReplacementNamed(context, '/login');
    prefs.clear();
    state.dispose();
  }

  static Future<(bool, String)> register(
      String username, String password) async {
    print('Registering $username');
    var (result, message) = await apiRequest('POST', 'auth/register', body: {
      'username': username,
      'password': password,
    });
    if (result != null) {
      prefs.setString('userId', result['userId']);
      prefs.setString('token', result['token']);
      state.trySubscribe();
      return (true, '');
    }

    return (false, message);
  }

  static Future<(bool, String)> unlockChallenge(String lockId) async {
    print('Unlocking with lock_id: $lockId');
    var (result, message) = await apiRequest('POST', 'game/unlock', body: {
      'lock_id': lockId,
    });
    fetch<Challenge>('all');
    if (result != null) {
      int unlockedChallenges = result['unlocked_challenges'];
      int totalChallenges = result['total_challenges'];
      return (true, '$unlockedChallenges/$totalChallenges');
    }

    return (false, message);
  }

  static Future<(bool, String)> setChallengeStatus(
      String challengeId, ChallengeUserStatus status) async {
    print('Setting challenge status of $challengeId to ${status.badgeMessage}');
    var (result, message) =
        await apiRequest('POST', 'game/setChallengeStatus', body: {
      'challenge_id': challengeId,
      'status': status.value,
    });
    fetch<User>(Backend.state.user!.id);
    if (result != null) {
      return (true, '');
    }

    return (false, message);
  }
}

class BackendState implements ServerObjectSubscriber {
  User? user;

  BackendState() {
    trySubscribe();
  }

  void trySubscribe() async {
    SubscriptionManager.unsubscribe(this);
    if (Backend.userId != null) {
      SubscriptionManager.subscribe<User>(this, Backend.userId!);
    }
  }

  void dispose() {
    SubscriptionManager.unsubscribe(this);
    user = null;
  }

  @override
  void onUpdate(ServerObject object) {
    if (object is User) {
      user = object;
    }
  }
}
