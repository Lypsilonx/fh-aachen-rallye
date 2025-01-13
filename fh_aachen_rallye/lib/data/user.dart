import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';

class User extends ServerObject {
  final String username;
  int points;
  final Map<String, ChallengeState> challengeStates;
  final String? displayName;

  String get name => displayName ?? username;

  User(super.id, this.username, this.points, this.challengeStates,
      {this.displayName});

  static User empty(String id) => User(
        id,
        'LOADING',
        0,
        {},
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'points': points,
      'challengeStates': challengeStates.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'displayName': displayName,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'] as String,
      json['username'] as String,
      json['points'] as int,
      {
        for (var item in json['challengeStates'] as List)
          (item as Map<String, dynamic>)['challenge_id'] as String:
              ChallengeState.fromJson(item),
      },
      displayName: json['displayName'] as String?,
    );
  }
}

class ChallengeState {
  final int step;
  final int? shuffleSource;
  final List<int> shuffleTargets;
  final ChallengeUserStatus userStatus;

  ChallengeState(
      this.step, this.shuffleSource, this.shuffleTargets, this.userStatus);

  factory ChallengeState.fromJson(Map<String, dynamic> json) {
    return ChallengeState(
      json['step'] as int,
      json['shuffleSource'] as int?,
      json['shuffleTargets'] == null || json['shuffleTargets'] == ''
          ? []
          : (json['shuffleTargets'] as String)
              .split(',')
              .map(int.parse)
              .toList(),
      ChallengeUserStatus.fromInt(json['userStatus'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'shuffleSource': shuffleSource,
      'shuffleTargets': shuffleTargets.join(','),
      'userStatus': userStatus.value,
    };
  }
}
