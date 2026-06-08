import 'dart:convert';

class UserProfile {
  final String name;
  final String? avatarPath;

  UserProfile({
    required this.name,
    this.avatarPath,
  });

  UserProfile copyWith({
    String? name,
    String? avatarPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarPath': avatarPath,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      avatarPath: map['avatarPath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
