import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:form_validator/form_validator.dart';

import '../../providers/auth_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../widgets/glass_card.dart';
import '../../utils/app_theme.dart';

class CreateExerciseScreen extends StatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  State<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final List<String> _selectedMuscleGroups = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _createExercise() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedMuscleGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one muscle group'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);

    try {
      await exerciseProvider.createExercise(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        muscleGroups: _selectedMuscleGroups,
        instructions: _instructionsController.text.trim().isNotEmpty 
            ? _instructionsController.text.trim() 
            : null,
        createdBy: authProvider.user?.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/exercises');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            'Create Exercise',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'e.g., Push-ups',
              ),
              style: const TextStyle(color: Colors.white),
              validator: ValidationBuilder()
                  .minLength(2, 'Name must be at least 2 characters')
                  .required('Exercise name is required')
                  .build(),
            ),

            const SizedBox(height: 24),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'Brief description of the exercise',
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Instructions
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions (Optional)',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'Step-by-step instructions',
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
            ),

            const SizedBox(height: 24),

            // Muscle Groups
            Text(
              'Target Muscle Groups',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExerciseProvider.muscleGroups.map((muscleGroup) {
                final isSelected = _selectedMuscleGroups.contains(muscleGroup);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedMuscleGroups.remove(muscleGroup);
                      } else {
                        _selectedMuscleGroups.add(muscleGroup);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryColor 
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : Colors.white30,
                      ),
                    ),
                    child: Text(
                      muscleGroup,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Create Button
            Consumer<ExerciseProvider>(
              builder: (context, exerciseProvider, child) {
                return PrimaryButton(
                  text: 'Create Exercise',
                  onPressed: _createExercise,
                  isLoading: exerciseProvider.isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}