import 'dart:convert';

import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Backend {
  static late BackendState state;
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    state = BackendState();

    // Challenge testChallenge = const Challenge(
    //   'test',
    //   title: 'Test Challenge',
    //   difficulty: Difficulty.easy,
    //   points: 10,
    //   category: ChallengeCategory.general,
    //   descriptionStart: 'This is a test challenge.',
    //   descriptionEnd: 'You did it!',
    //   steps: [
    //     ChallengeStepSay('Hello!'),
    //     ChallengeStepOptions('Decide!', {'Option 1': 1, 'Back': -1}),
    //     ChallengeStepStringInput('Type something!', 'something!', 2),
    //     ChallengeStepSay('Whoo!', isLast: true),
    //     ChallengeStepSay('Not quite!', next: -2),
    //   ],
    // );

    // await apiRequest('POST', 'challenges', body: testChallenge.toJson());
  }

  static const String apiUrl =
      'http://www.politischdekoriert.de/fh-aachen-rallye/api/public/index.php/';
  static late SharedPreferences prefs;

  static void send(ServerObject object) {
    print('Sending object: $object');
    // Send object to server
    if (object is User) {
      apiRequest('PUT', 'users/${object.id}', body: object.toJson())
          .then((value) {
        fetch<User>(object.id);
      });
    }
  }

  static void patch(ServerObject object, Map<String, dynamic> changes) {
    print('Patching object: $object with $changes');
    // Patch object on server
    if (object is User) {
      apiRequest('PATCH', 'users/${object.id}', body: changes).then((value) {
        fetch<User>(object.id);
      });
    }
  }

  static void fetch<T extends ServerObject>(String id) async {
    print('Fetching object: $T with id $id');
    if (T.toString() == (User).toString()) {
      if (id == '*') {
        var requestedUsers =
            await apiRequest('GET', 'users?includeChallengeStates=true');
        if (requestedUsers != null) {
          for (var userJson in requestedUsers['data']) {
            var user = User.fromJson(userJson);
            SubscriptionManager.notifyUpdate(user);
          }
        }
      } else {
        var requestedUser =
            await apiRequest('GET', 'users/$id?includeChallengeStates=true');
        if (requestedUser != null) {
          var user = User.fromJson(requestedUser['data']);
          SubscriptionManager.notifyUpdate(user);
        }
      }
    } else if (T.toString() == (Challenge).toString()) {
      if (id == '*') {
        var requestedChallenges =
            await apiRequest('GET', 'challenges?includeSteps=true');
        if (requestedChallenges != null) {
          for (var challengeJson in requestedChallenges['data']) {
            var challenge = Challenge.fromJson(challengeJson);
            SubscriptionManager.notifyUpdate(challenge);
          }
        }
      } else {
        var requestedChallenge =
            await apiRequest('GET', 'challenges/$id?includeSteps=true');
        if (requestedChallenge != null) {
          var challenge = Challenge.fromJson(requestedChallenge['data']);
          SubscriptionManager.notifyUpdate(challenge);
        }
      }
    }
  }

  static String? get userId => prefs.getString('userId');

  static Future<dynamic> apiRequest(String method, String path,
      {Map<String, dynamic>? body}) async {
    return webRequest(method, "api/v1/$path", body: body);
  }

  static Future<dynamic> webRequest(String method, String path,
      {Map<String, dynamic>? body}) async {
    var url = Uri.parse('$apiUrl$path');
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
      return null;
    }

    if (result.statusCode != 201 && result.statusCode != 200) {
      if (body != null) {
        print('Body: $body');
      }
      print(
          'The $method request to $path failed with status code ${result.statusCode}');
      print('Response: ${result.body}');
      return null;
    }

    return jsonDecode(result.body);
  }

  // TEMP
  static void setChallengeState(String challengeId, int currentStep) {
    if (state.user == null) {
      return;
    }

    state.user!.challengeStates[challengeId] = currentStep;

    if (currentStep == -2) {
      List<Challenge> challenges = Cache.serverObjects[Challenge]!.values
          .map((e) => e as Challenge)
          .toList();
      state.user!.points += (challenges
          .firstWhere((element) => element.id == challengeId)
          .points);
      Backend.patch(state.user!, {'points': state.user!.points});
    }

    Backend.patch(state.user!,
        {'challengeStates': jsonEncode(state.user!.challengeStates)});
  }

  static Future<(bool, String)> login(String username, String password) async {
    print('Logging in $username');
    var result = await apiRequest('POST', 'auth/login', body: {
      'username': username,
      'password': password,
    });
    if (result != null) {
      prefs.setString('userId', result['userId']);
      prefs.setString('token', result['token']);
      state.trySubscribe();
      return (true, '');
    }

    return (false, 'Login failed.');
  }

  static void logout() {
    prefs.remove('userId');
    prefs.remove('token');
    state.user = null;
    Cache.clear();
  }

  static Future<(bool, String)> register(
      String username, String password) async {
    print('Registering $username');
    var result = await apiRequest('POST', 'auth/register', body: {
      'username': username,
      'password': password,
    });
    if (result != null) {
      prefs.setString('userId', result['userId']);
      prefs.setString('token', result['token']);
      state.trySubscribe();
      return (true, '');
    }

    return (false, 'Registration failed.');
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
