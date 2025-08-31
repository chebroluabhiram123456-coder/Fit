class Exercise {
  final String id;
  final String name;
  final String? description;
  final List<String> muscleGroups;
  final String? instructions;
  final String? imageUrl;
  final String? videoUrl;
  final bool? isCustom;
  final String? createdBy;
  final DateTime? createdAt;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    required this.muscleGroups,
    this.instructions,
    this.imageUrl,
    this.videoUrl,
    this.isCustom,
    this.createdBy,
    this.createdAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      muscleGroups: List<String>.from(json['muscleGroups'] ?? []),
      instructions: json['instructions'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      isCustom: json['isCustom'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroups': muscleGroups,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'isCustom': isCustom,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class WorkoutPlan {
  final String id;
  final String userId;
  final String name;
  final int dayOfWeek;
  final List<String> muscleGroups;
  final int estimatedDuration;
  final bool? isActive;
  final DateTime? createdAt;

  WorkoutPlan({
    required this.id,
    required this.userId,
    required this.name,
    required this.dayOfWeek,
    required this.muscleGroups,
    required this.estimatedDuration,
    this.isActive,
    this.createdAt,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      dayOfWeek: json['dayOfWeek'],
      muscleGroups: List<String>.from(json['muscleGroups'] ?? []),
      estimatedDuration: json['estimatedDuration'],
      isActive: json['isActive'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dayOfWeek': dayOfWeek,
      'muscleGroups': muscleGroups,
      'estimatedDuration': estimatedDuration,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class WorkoutSession {
  final String id;
  final String userId;
  final String? workoutPlanId;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final bool? isCompleted;
  final String? notes;

  WorkoutSession({
    required this.id,
    required this.userId,
    this.workoutPlanId,
    required this.name,
    required this.startTime,
    this.endTime,
    this.isCompleted,
    this.notes,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      userId: json['userId'],
      workoutPlanId: json['workoutPlanId'],
      name: json['name'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      isCompleted: json['isCompleted'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'workoutPlanId': workoutPlanId,
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }
}

class ExerciseLog {
  final String id;
  final String workoutSessionId;
  final String exerciseId;
  final int sets;
  final int reps;
  final double? weight;
  final bool? isCompleted;
  final int order;

  ExerciseLog({
    required this.id,
    required this.workoutSessionId,
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.weight,
    this.isCompleted,
    required this.order,
  });

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      id: json['id'],
      workoutSessionId: json['workoutSessionId'],
      exerciseId: json['exerciseId'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight']?.toDouble(),
      isCompleted: json['isCompleted'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutSessionId': workoutSessionId,
      'exerciseId': exerciseId,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'isCompleted': isCompleted,
      'order': order,
    };
  }
}

class WeightLog {
  final String id;
  final String userId;
  final double weight;
  final DateTime date;
  final String? notes;

  WeightLog({
    required this.id,
    required this.userId,
    required this.weight,
    required this.date,
    this.notes,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    return WeightLog(
      id: json['id'],
      userId: json['userId'],
      weight: json['weight'].toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'weight': weight,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }
}
