class UserData {
  final String id;
  final String username;
  final String password;

  const UserData(this.id, this.username, this.password);

  static UserData empty() => UserData('', '', '');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserData && runtimeType == other.runtimeType && id == other.id;
}
