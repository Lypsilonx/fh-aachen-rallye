import 'dart:convert';
import 'dart:math';

import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Backend {
  static late SharedPreferences prefs;

  static List<User> users = [];

  static const List<Challenge> challenges = [
    Challenge(
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
    ),
  ];

  static void send(ServerObject object) {
    // Send object to server
    if (object is User) {
      users.removeWhere((element) => element.id == object.id);
      users.add(object);
      saveUsers();
      SubscriptionManager.notifyUpdate(object);
    }
  }

  static void fetch<T extends ServerObject>(String id) {
    if (T.toString() == (User).toString()) {
      User? user = users.firstWhere((element) => element.id == id,
          orElse: () => User.empty(''));
      SubscriptionManager.notifyUpdate(user);
    } else if (T.toString() == (Challenge).toString()) {
      Challenge? challenge = challenges.firstWhere(
          (element) => element.id == id,
          orElse: () => Challenge.empty(''));
      SubscriptionManager.notifyUpdate(challenge);
    }
  }

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    users = loadUsers();
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
