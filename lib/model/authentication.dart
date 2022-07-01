
class User {
  final String userid;
  late String name;
  late final String email;
  late final List<String> roles;
  late final String? group;

  User(
    this.userid,
    this.email,
    this.name,
    this.roles, {
    this.group,
  });

  User.fromJson(this.userid, Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    roles = json.containsKey('roles') ? json['roles'] : [];
    group = null;
  }
}

class Authentication {
  final String token;
  final User user;

  Authentication(this.token, this.user);
}
