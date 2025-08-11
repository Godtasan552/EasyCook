class AppUser {
  final String email;
  final String username;
  final String password; // demo only — hash in production
  final List<String> favorites; // store meal.idMeal
  final List<String> allergies;

  AppUser({
    required this.email,
    required this.username,
    required this.password,
    List<String>? favorites,
    List<String>? allergies,
  })  : favorites = favorites ?? [],
        allergies = allergies ?? [];

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'],
      username: json['username'],
      password: json['password'],
      favorites: List<String>.from(json['favorites'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'username': username,
        'password': password,
        'favorites': favorites,
        'allergies': allergies,
      };
}
