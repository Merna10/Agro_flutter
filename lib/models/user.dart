class Users {
  final String email;
  final String username;
  final String userImage;

  Users({
    required this.email,
    required this.username,
    required this.userImage,
  });
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'userImage': userImage,
    };
  }
}
