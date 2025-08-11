class AppUser {
  final String email;
  final String username;
  final String password; // ควรแฮชในระบบจริง
  final List<String> favorites; // idMeal ของเมนูโปรด
  final List<String> allergies; // ชื่อส่วนผสมที่แพ้

  AppUser({
    required this.email,
    required this.username,
    required this.password,
    required this.favorites,
    required this.allergies,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'],
      username: json['username'],
      password: json['password'],
      favorites: List<String>.from(json['favorites']),
      allergies: List<String>.from(json['allergies']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
      'favorites': favorites,
      'allergies': allergies,
    };
  }
}
