class User {
  final int? id;
  final String username;
  final String password;
  final bool isAdmin;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.isAdmin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'isAdmin': isAdmin ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      isAdmin: map['isAdmin'] == 1,
    );
  }
}
