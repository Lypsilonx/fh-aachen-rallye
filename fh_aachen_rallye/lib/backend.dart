import 'dart:convert';
import 'dart:math';

import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Backend {
  static const String apiUrl =
      'http://www.politischdekoriert.de/fh-aachen-rallye/api/public/index.php/api/v1/';
  static late SharedPreferences prefs;

  static List<User> users = [];

  static List<Challenge> challenges = [];

  static void send(ServerObject object) {
    // Send object to server
    if (object is User) {
      users.removeWhere((element) => element.id == object.id);
      users.add(object);
      saveUsers();
    }
  }

  static void fetch<T extends ServerObject>(String id) {
    if (T.toString() == (User).toString()) {
      User? user = users.firstWhere((element) => element.id == id,
          orElse: () => User.empty(''));
      if (user != User.empty('')) {
        SubscriptionManager.notifyUpdate(user);
      }
    } else if (T.toString() == (Challenge).toString()) {
      Challenge? challenge = challenges.firstWhere(
          (element) => element.id == id,
          orElse: () => Challenge.empty(''));
      if (challenge != Challenge.empty('')) {
        SubscriptionManager.notifyUpdate(challenge);
      }
    }
  }

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    Challenge testChallenge = const Challenge(
      'test',
      title: 'Test Challenge',
      difficulty: Difficulty.easy,
      points: 10,
      category: ChallengeCategory.general,
      descriptionStart: 'This is a test challenge.',
      descriptionEnd: 'You did it!',
      steps: [
        ChallengeStepSay('Hello!'),
        ChallengeStepOptions('Decide!', {'Option 1': 1, 'Back': -1}),
        ChallengeStepStringInput('Type something!', 'something!', 2),
        ChallengeStepSay('Whoo!', isLast: true),
        ChallengeStepSay('Not quite!', next: -2),
      ],
    );

    //sendChallenge(testChallenge);

    users = loadUsers();
    challenges = await getChallenges();
  }

  // TEMP
  static void sendChallenge(Challenge challenge) async {
    var result = await http.post(Uri.parse('${apiUrl}challenges'),
        body: jsonEncode(challenge.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        });

    if (result.statusCode != 201) {
      print(result.statusCode);
      print(result.body);
      return;
    }

    int i = 0;
    for (var challengeStep in challenge.steps) {
      i = i + 1;
      var challengeJson = challengeStep.toJson();
      // add challenge_id
      challengeJson['id'] = "${challenge.id}_$i";
      challengeJson['challenge_id'] = challenge.id;
      result = await http.post(Uri.parse('${apiUrl}challengeSteps'),
          body: jsonEncode(challengeJson),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          });

      if (result.statusCode != 201) {
        print(result.statusCode);
        print(result.body);
        print(challengeJson);
        return;
      }
    }
  }

  static List<User> loadUsers() {
    String usersJson = prefs.getString('users') ?? '[]';
    return (jsonDecode(usersJson) as List)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static void saveUsers() {
    prefs.setString('users', jsonEncode(users.map((e) => e.toJson()).toList()));
  }

  static String? get userId => prefs.getString('userId');

  static Future<List<Challenge>> getChallenges() async {
    var result =
        await http.get(Uri.parse('${apiUrl}challenges?includeSteps=true'));
    if (result.statusCode == 200) {
      List<Challenge> challenges = [];
      for (var challengeJson in jsonDecode(result.body)["data"]) {
        challenges.add(Challenge.fromJson(challengeJson));
        SubscriptionManager.notifyUpdate(challenges.last);
      }
      return challenges;
    } else {
      return [];
    }
  }

  static List<String> getChallengeIds() {
    return challenges.map((e) => e.id).toList();
  }

  static Challenge getChallenge(String id) {
    return challenges.firstWhere((element) => element.id == id);
  }

  static void setChallengeState(String challengeId, int currentStep) {
    User user = users.firstWhere((element) => element.id == userId,
        orElse: () => User.empty(''));
    user.challengeStates[challengeId] = currentStep;

    if (currentStep == -2) {
      user.points += (getChallenge(challengeId).points);
    }

    Backend.send(user);
  }

  static (bool, String) login(String username, String password) {
    User? user = users.firstWhere(
        (element) =>
            element.username == username && element.password == password,
        orElse: () => User.empty(''));
    if (user != User.empty('')) {
      prefs.setString('userId', user.id);
      return (true, '');
    }

    return (false, 'Invalid username or password.');
  }

  static void logout() {
    prefs.remove('userId');
  }

  static (bool, String) register(String username, String password) {
    String newId = generateId();
    User newUser = User(newId, username, password, 0, {});
    users.add(newUser);
    send(newUser);
    return login(username, password);
  }

  static String generateId() {
    Random random = Random();
    String id = '';
    for (int i = 0; i < 16; i++) {
      id += random.nextInt(10).toString();
    }
    return id;
  }
}
