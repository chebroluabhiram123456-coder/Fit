import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/glass_card.dart';
import '../../utils/app_theme.dart';
import '../layout/main_layout.dart';

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  @override
  void initState() {
    super.initState();
    _loadWorkoutPlans();
  }

  Future<void> _loadWorkoutPlans() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      await workoutProvider.loadUserWorkoutPlans(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2,
      child: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildWeeklyPlan(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Weekly Plan',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton(
            onPressed: _showCreatePlanDialog,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlan() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        return Column(
          children: [
            ...WorkoutProvider.weekDays.asMap().entries.map((entry) {
              final dayIndex = entry.key;
              final dayName = entry.value;
              
              final dayPlan = workoutProvider.workoutPlans
                  .where((plan) => plan.dayOfWeek == dayIndex)
                  .firstOrNull;
              
              return _buildDayCard(dayName, dayIndex, dayPlan);
            }),
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        );
      },
    );
  }

  Widget _buildDayCard(String dayName, int dayIndex, dynamic dayPlan) {
    final isToday = DateTime.now().weekday == (dayIndex == 0 ? 7 : dayIndex);
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    dayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday ? AppTheme.primaryColor : Colors.white,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (dayPlan != null)
                IconButton(
                  onPressed: () => _showEditPlanDialog(dayPlan, dayIndex),
                  icon: const Icon(Icons.edit, color: Colors.white60, size: 20),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (dayPlan != null) ...[
            Text(
              dayPlan.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.white60,
                ),
                const SizedBox(width: 4),
                Text(
                  '${dayPlan.estimatedDuration} min',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.fitness_center,
                  size: 16,
                  color: Colors.white60,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    dayPlan.muscleGroups.join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isToday) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/workout/${dayPlan.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Start Workout'),
                ),
              ),
            ],
          ] else ...[
            Text(
              'Rest day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showCreatePlanDialog(dayIndex),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Add Workout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCreatePlanDialog([int? selectedDay]) async {
    await showDialog(
      context: context,
      builder: (context) => _CreatePlanDialog(selectedDay: selectedDay),
    );
    _loadWorkoutPlans();
  }

  Future<void> _showEditPlanDialog(dynamic plan, int dayIndex) async {
    await showDialog(
      context: context,
      builder: (context) => _CreatePlanDialog(
        selectedDay: dayIndex,
        existingPlan: plan,
      ),
    );
    _loadWorkoutPlans();
  }
}

class _CreatePlanDialog extends StatefulWidget {
  final int? selectedDay;
  final dynamic existingPlan;

  const _CreatePlanDialog({this.selectedDay, this.existingPlan});

  @override
  State<_CreatePlanDialog> createState() => _CreatePlanDialogState();
}

class _CreatePlanDialogState extends State<_CreatePlanDialog> {
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  int? _selectedDay;
  final List<String> _selectedMuscleGroups = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
    if (widget.existingPlan != null) {
      _nameController.text = widget.existingPlan.name;
      _durationController.text = widget.existingPlan.estimatedDuration.toString();
      _selectedMuscleGroups.addAll(List<String>.from(widget.existingPlan.muscleGroups));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _savePlan() async {
    if (_nameController.text.trim().isEmpty ||
        _durationController.text.trim().isEmpty ||
        _selectedDay == null ||
        _selectedMuscleGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    try {
      await workoutProvider.createWorkoutPlan(
        userId: authProvider.user!.id,
        name: _nameController.text.trim(),
        dayOfWeek: _selectedDay!,
        muscleGroups: _selectedMuscleGroups,
        estimatedDuration: int.parse(_durationController.text),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout plan saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
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
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: Text(
        widget.existingPlan != null ? 'Edit Workout Plan' : 'Create Workout Plan',
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Plan Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Day Selection
            if (widget.selectedDay == null)
              DropdownButtonFormField<int>(
                value: _selectedDay,
                dropdownColor: AppTheme.surfaceColor,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Day of Week',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: WorkoutProvider.weekDays.asMap().entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedDay = value),
              ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Muscle Groups
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Muscle Groups',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ExerciseProvider.muscleGroups.map((group) {
                final isSelected = _selectedMuscleGroups.contains(group);
                return FilterChip(
                  label: Text(group),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMuscleGroups.add(group);
                      } else {
                        _selectedMuscleGroups.remove(group);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        Consumer<WorkoutProvider>(
          builder: (context, workoutProvider, child) {
            return TextButton(
              onPressed: workoutProvider.isLoading ? null : _savePlan,
              child: workoutProvider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save', style: TextStyle(color: AppTheme.primaryColor)),
            );
          },
        ),
      ],
    );
  }
}