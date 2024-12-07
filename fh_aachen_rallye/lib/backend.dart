import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/userData.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Backend {
  static late String userId;
  static late SharedPreferences prefs;

  static const List<UserData> users = [
    UserData('test', 'test', '1234'),
  ];

  static const List<Challenge> challenges = [
    Challenge(
      id: 'test',
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
        // Bad states
        ChallengeStepSay('Not quite!', next: -2),
      ],
    ),
  ];

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static int getPoints() {
    return prefs.getInt('user_${userId}_points') ?? 0;
  }

  static List<String> getChallengeIds() {
    return challenges.map((e) => e.id).toList();
  }

  static Challenge getChallenge(String id) {
    return challenges.firstWhere((element) => element.id == id);
  }

  static void setChallengeState(Challenge challenge, int currentStep) {
    prefs.setInt('challenge_${challenge.id}_currentStep', currentStep);

    if (currentStep == -2) {
      prefs.setInt('user_${userId}_points',
          (prefs.getInt('user_${userId}_points') ?? 0) + challenge.points);
    }
  }

  static int getChallengeState(Challenge challenge) {
    return prefs.getInt('challenge_${challenge.id}_currentStep') ?? -1;
  }

  static (bool, String) login(String username, String password) {
    UserData? user = users.firstWhere(
        (element) =>
            element.username == username && element.password == password,
        orElse: () => UserData.empty());
    if (user != UserData.empty()) {
      userId = user.id;
      return (true, '');
    }

    return (false, 'Invalid username or password.');
  }

  static void logout() {
    userId = '';
  }

  static (bool, String) register(String username, String password) {
    return (false, "Registration is not implemented yet.");
    // String newId = 'user_${users.length}';
    //return login(username, password);
  }
}
