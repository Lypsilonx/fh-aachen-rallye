import 'package:fh_aachen_rallye/data/server_object.dart';

class User extends ServerObject {
  final String username;
  final String password;
  int points;
  final Map<String, int> challengeStates;

  User(super.id, this.username, this.password, this.points,
      this.challengeStates);

  static User empty(String id) => User(
        id,
        'Loading...',
        '',
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
      'password': password,
      'points': points,
      'challengeStates': challengeStates,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'] as String,
      json['username'] as String,
      json['password'] as String,
      json['points'] as int,
      json['challengeStates'] == "{}"
          ? {}
          : (json['challengeStates'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value as int)),
    );
  }
}
