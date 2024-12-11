import 'package:fh_aachen_rallye/data/server_object.dart';

class User extends ServerObject {
  final String username;
  int points;
  final Map<String, int> challengeStates;
  final String? displayName;

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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'points': points,
      'challengeStates': challengeStates,
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
              (item)['step'] as int
      },
      displayName: json['displayName'] as String?,
    );
  }
}
