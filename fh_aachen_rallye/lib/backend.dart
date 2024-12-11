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

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class Backend {
  static late BackendState state;
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    state = BackendState();
    Translator();
  }

  static const String apiUrl =
      'http://www.politischdekoriert.de/fh-aachen-rallye/api/public/index.php/';
  static late SharedPreferences prefs;

  static Future<String> send(ServerObject object) async {
    print('Sending object: $object');
    // Send object to server
    if (object is User) {
      var (_, message) =
          await apiRequest('PUT', 'users/${object.id}', body: object.toJson());
      fetch<User>(object.id);
      return message;
    }

    return '';
  }

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
    if (T.toString() == (User).toString()) {
      if (id == '*' || id == 'all') {
        var (requestedUsers, _) =
            await apiRequest('GET', 'users?includeChallengeStates=true');
        while (true) {
          if (requestedUsers != null) {
            for (var userJson in requestedUsers['data']) {
              var user = User.fromJson(userJson);
              SubscriptionManager.notifyUpdate(user);
            }

            if (requestedUsers['links']['next'] != null) {
              (requestedUsers, _) =
                  await webRequest('GET', requestedUsers['links']['next']);
            } else {
              break;
            }
          }
        }
      } else {
        var (requestedUser, _) =
            await apiRequest('GET', 'users/$id?includeChallengeStates=true');
        if (requestedUser != null) {
          var user = User.fromJson(requestedUser['data']);
          SubscriptionManager.notifyUpdate(user);
        }
      }
      SubscriptionManager.notifyAll<User>();
    } else if (T.toString() == (Challenge).toString()) {
      if (id == '*' || id == 'all') {
        var (requestedChallenges, _) =
            await apiRequest('GET', 'challenges?includeSteps=true');
        while (true) {
          if (requestedChallenges != null) {
            for (var challengeJson in requestedChallenges['data']) {
              var challenge = Challenge.fromJson(challengeJson);
              SubscriptionManager.notifyUpdate(challenge);
            }
          }

          if (requestedChallenges['links']['next'] != null) {
            (requestedChallenges, _) =
                await webRequest('GET', requestedChallenges['links']['next']);
          } else {
            break;
          }
        }
      } else {
        var (requestedChallenge, _) =
            await apiRequest('GET', 'challenges/$id?includeSteps=true');
        if (requestedChallenge != null) {
          var challenge = Challenge.fromJson(requestedChallenge['data']);
          SubscriptionManager.notifyUpdate(challenge);
        }
      }
      SubscriptionManager.notifyAll<Challenge>();
    } else if (T.toString() == (Translation).toString()) {
      if (id == '*' || id == 'all') {
        var (requestedTranslations, _) =
            await apiRequest('GET', 'translations');
        while (true) {
          if (requestedTranslations != null) {
            for (var translationJson in requestedTranslations['data']) {
              var translation = Translation.fromJson(translationJson);
              SubscriptionManager.notifyUpdate(translation);
            }
          }

          if (requestedTranslations['links']['next'] != null) {
            (requestedTranslations, _) =
                await webRequest('GET', requestedTranslations['links']['next']);
          } else {
            break;
          }
        }
      } else {
        var (requestedTranslation, _) =
            await apiRequest('GET', 'translations/$id');
        if (requestedTranslation != null) {
          var translation = Translation.fromJson(requestedTranslation['data']);
          SubscriptionManager.notifyUpdate(translation);
        }
      }
      SubscriptionManager.notifyAll<Translation>();
    } else {
      throw Exception('Unknown type');
    }
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
  static Future<String> setChallengeState(
      String challengeId, int currentStep) async {
    state.user!.challengeStates[challengeId] = currentStep;

    var message = await Backend.patch(state.user!,
        {'challengeStates': jsonEncode(state.user!.challengeStates)});
    if (currentStep == -2) {
      Backend.fetch<Challenge>('all');
    }

    return message;
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
    Navigator.popUntil(context, (route) => route.isFirst);
    Translator.setLanguage(Language.en);
    Navigator.pushReplacementNamed(context, '/login');
    prefs.clear();
    state.user = null;
    Cache.clear(dontDelete: [Translation]);
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

  static Future<String> unlockChallenge(String lockId) async {
    print('Unlocking with lock_id: $lockId');
    var (result, message) = await apiRequest('POST', 'game/unlock', body: {
      'lock_id': lockId,
    });
    fetch<Challenge>('all');
    if (result != null) {
      return '';
    }

    return message;
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

  @override
  void onUpdate(ServerObject object) {
    if (object is User) {
      user = object;
    }
  }
}
