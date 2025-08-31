class User {
  final String id;
  final String username;
  final String email;
  final String name;
  final int? heightFeet;
  final int? heightInches;
  final double? currentWeight;
  final double? goalWeight;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    this.heightFeet,
    this.heightInches,
    this.currentWeight,
    this.goalWeight,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      heightFeet: json['heightFeet'],
      heightInches: json['heightInches'],
      currentWeight: json['currentWeight']?.toDouble(),
      goalWeight: json['goalWeight']?.toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'heightFeet': heightFeet,
      'heightInches': heightInches,
      'currentWeight': currentWeight,
      'goalWeight': goalWeight,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    int? heightFeet,
    int? heightInches,
    double? currentWeight,
    double? goalWeight,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      heightFeet: heightFeet ?? this.heightFeet,
      heightInches: heightInches ?? this.heightInches,
      currentWeight: currentWeight ?? this.currentWeight,
      goalWeight: goalWeight ?? this.goalWeight,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}