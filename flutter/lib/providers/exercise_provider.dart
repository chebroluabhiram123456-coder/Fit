import 'package:flutter/foundation.dart';
import '../models/exercise_model.dart';
import '../services/api_service.dart';

class ExerciseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedMuscleGroup;

  List<Exercise> get exercises => _filteredExercises;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedMuscleGroup => _selectedMuscleGroup;

  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
    'Cardio',
    'Full Body',
  ];

  Future<void> loadExercises() async {
    _isLoading = true;
    notifyListeners();

    try {
      _exercises = await _apiService.getExercises();
      _applyFilters();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading exercises: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchExercises(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByMuscleGroup(String? muscleGroup) {
    _selectedMuscleGroup = muscleGroup;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredExercises = _exercises.where((exercise) {
      final matchesSearch = _searchQuery.isEmpty ||
          exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (exercise.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesMuscleGroup = _selectedMuscleGroup == null ||
          exercise.muscleGroups.contains(_selectedMuscleGroup);

      return matchesSearch && matchesMuscleGroup;
    }).toList();
  }

  Future<void> createExercise({
    required String name,
    String? description,
    required List<String> muscleGroups,
    String? instructions,
    String? createdBy,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final exerciseData = {
        'name': name,
        'description': description,
        'muscleGroups': muscleGroups,
        'instructions': instructions,
        'isCustom': true,
        'createdBy': createdBy,
      };

      final newExercise = await _apiService.createExercise(exerciseData);
      _exercises.add(newExercise);
      _applyFilters();
    } catch (e) {
      throw Exception('Failed to create exercise: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedMuscleGroup = null;
    _applyFilters();
    notifyListeners();
  }
}
