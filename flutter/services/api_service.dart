import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/exercise_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000'; // Change for production
  
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  // Authentication endpoints
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // User endpoints
  Future<User> getUser(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user: ${response.body}');
    }
  }

  Future<User> updateUser(String userId, Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: headers,
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  // Exercise endpoints
  Future<List<Exercise>> getExercises({String? search, String? muscleGroup}) async {
    String url = '$baseUrl/api/exercises';
    List<String> queryParams = [];
    
    if (search != null && search.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search)}');
    }
    if (muscleGroup != null && muscleGroup.isNotEmpty) {
      queryParams.add('muscleGroup=${Uri.encodeComponent(muscleGroup)}');
    }
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Exercise.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch exercises: ${response.body}');
    }
  }

  Future<Exercise> createExercise(Map<String, dynamic> exerciseData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/exercises'),
      headers: headers,
      body: jsonEncode(exerciseData),
    );

    if (response.statusCode == 200) {
      return Exercise.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create exercise: ${response.body}');
    }
  }

  // Workout Plan endpoints
  Future<List<WorkoutPlan>> getUserWorkoutPlans(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/workout-plans/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WorkoutPlan.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch workout plans: ${response.body}');
    }
  }

  Future<WorkoutPlan> createWorkoutPlan(Map<String, dynamic> planData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/workout-plans'),
      headers: headers,
      body: jsonEncode(planData),
    );

    if (response.statusCode == 200) {
      return WorkoutPlan.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create workout plan: ${response.body}');
    }
  }

  // Workout Session endpoints
  Future<List<WorkoutSession>> getUserWorkoutSessions(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/workout-sessions/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WorkoutSession.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch workout sessions: ${response.body}');
    }
  }

  Future<WorkoutSession> createWorkoutSession(Map<String, dynamic> sessionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/workout-sessions'),
      headers: headers,
      body: jsonEncode(sessionData),
    );

    if (response.statusCode == 200) {
      return WorkoutSession.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create workout session: ${response.body}');
    }
  }

  Future<WorkoutSession> updateWorkoutSession(String sessionId, Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/workout-sessions/$sessionId'),
      headers: headers,
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return WorkoutSession.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update workout session: ${response.body}');
    }
  }

  // Weight Log endpoints
  Future<List<WeightLog>> getUserWeightLogs(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/weight-logs/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WeightLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch weight logs: ${response.body}');
    }
  }

  Future<WeightLog> createWeightLog(Map<String, dynamic> logData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/weight-logs'),
      headers: headers,
      body: jsonEncode(logData),
    );

    if (response.statusCode == 200) {
      return WeightLog.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create weight log: ${response.body}');
    }
  }

  // Analytics endpoints
  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/analytics/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch analytics: ${response.body}');
    }
  }
}
