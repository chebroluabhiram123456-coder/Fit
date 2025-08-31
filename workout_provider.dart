import 'package:flutter/foundation.dart';
import '../models/exercise_model.dart';
import '../services/api_service.dart';

class WorkoutProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<WorkoutPlan> _workoutPlans = [];
  List<WorkoutSession> _workoutSessions = [];
  List<WeightLog> _weightLogs = [];
  Map<String, dynamic>? _analytics;
  bool _isLoading = false;

  List<WorkoutPlan> get workoutPlans => _workoutPlans;
  List<WorkoutSession> get workoutSessions => _workoutSessions;
  List<WeightLog> get weightLogs => _weightLogs;
  Map<String, dynamic>? get analytics => _analytics;
  bool get isLoading => _isLoading;

  static const List<String> weekDays = [
    'Sunday',
    'Monday', 
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  Future<void> loadUserWorkoutPlans(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _workoutPlans = await _apiService.getUserWorkoutPlans(userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading workout plans: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserWorkoutSessions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _workoutSessions = await _apiService.getUserWorkoutSessions(userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading workout sessions: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserWeightLogs(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _weightLogs = await _apiService.getUserWeightLogs(userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading weight logs: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserAnalytics(String userId) async {
    try {
      _analytics = await _apiService.getUserAnalytics(userId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading analytics: $e');
      }
    }
  }

  Future<void> createWorkoutPlan({
    required String userId,
    required String name,
    required int dayOfWeek,
    required List<String> muscleGroups,
    required int estimatedDuration,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final planData = {
        'userId': userId,
        'name': name,
        'dayOfWeek': dayOfWeek,
        'muscleGroups': muscleGroups,
        'estimatedDuration': estimatedDuration,
        'isActive': true,
      };

      final newPlan = await _apiService.createWorkoutPlan(planData);
      _workoutPlans.add(newPlan);
    } catch (e) {
      throw Exception('Failed to create workout plan: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startWorkoutSession({
    required String userId,
    String? workoutPlanId,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final sessionData = {
        'userId': userId,
        'workoutPlanId': workoutPlanId,
        'name': name,
        'startTime': DateTime.now().toIso8601String(),
        'isCompleted': false,
      };

      final newSession = await _apiService.createWorkoutSession(sessionData);
      _workoutSessions.add(newSession);
    } catch (e) {
      throw Exception('Failed to start workout session: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeWorkoutSession(String sessionId, {String? notes}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updates = {
        'endTime': DateTime.now().toIso8601String(),
        'isCompleted': true,
        'notes': notes,
      };

      final updatedSession = await _apiService.updateWorkoutSession(sessionId, updates);
      
      final index = _workoutSessions.indexWhere((session) => session.id == sessionId);
      if (index != -1) {
        _workoutSessions[index] = updatedSession;
      }
    } catch (e) {
      throw Exception('Failed to complete workout session: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logWeight({
    required String userId,
    required double weight,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final logData = {
        'userId': userId,
        'weight': weight,
        'date': DateTime.now().toIso8601String(),
        'notes': notes,
      };

      final newLog = await _apiService.createWeightLog(logData);
      _weightLogs.add(newLog);
    } catch (e) {
      throw Exception('Failed to log weight: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  WorkoutPlan? getTodayWorkoutPlan() {
    final today = DateTime.now();
    final dayOfWeek = today.weekday == 7 ? 0 : today.weekday; // Convert Sunday from 7 to 0
    
    return _workoutPlans
        .where((plan) => plan.dayOfWeek == dayOfWeek && (plan.isActive ?? true))
        .firstOrNull;
  }

  List<WorkoutSession> getRecentSessions({int limit = 5}) {
    final sessions = List<WorkoutSession>.from(_workoutSessions);
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions.take(limit).toList();
  }

  List<WeightLog> getRecentWeightLogs({int limit = 10}) {
    final logs = List<WeightLog>.from(_weightLogs);
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs.take(limit).toList();
  }
}