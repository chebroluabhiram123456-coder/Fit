import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/glass_card.dart';
import '../../utils/app_theme.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final String planId;

  const WorkoutSessionScreen({
    super.key,
    required this.planId,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  DateTime? _sessionStartTime;
  bool _isSessionActive = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlan();
  }

  Future<void> _loadWorkoutPlan() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      await workoutProvider.loadUserWorkoutPlans(user.id);
    }
  }

  Future<void> _startWorkout() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final plan = workoutProvider.workoutPlans
        .where((p) => p.id == widget.planId)
        .firstOrNull;

    if (plan == null) return;

    try {
      await workoutProvider.startWorkoutSession(
        userId: user.id,
        workoutPlanId: plan.id,
        name: plan.name,
      );

      setState(() {
        _sessionStartTime = DateTime.now();
        _isSessionActive = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout started!'),
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

  Future<void> _completeWorkout() async {
    if (!_isSessionActive) return;

    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final recentSessions = workoutProvider.workoutSessions;
    
    if (recentSessions.isEmpty) return;

    final currentSession = recentSessions.last;

    try {
      await workoutProvider.completeWorkoutSession(
        currentSession.id,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      setState(() {
        _isSessionActive = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout completed!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
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

  String _formatDuration() {
    if (_sessionStartTime == null) return '00:00';
    
    final duration = DateTime.now().difference(_sessionStartTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
                  child: _buildWorkoutContent(),
                ),
              ),
              if (_isSessionActive) _buildActionButtons(),
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
          Expanded(
            child: Consumer<WorkoutProvider>(
              builder: (context, workoutProvider, child) {
                final plan = workoutProvider.workoutPlans
                    .where((p) => p.id == widget.planId)
                    .firstOrNull;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan?.name ?? 'Workout',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_isSessionActive) ...[
                      const SizedBox(height: 4),
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          return Text(
                            _formatDuration(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutContent() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final plan = workoutProvider.workoutPlans
            .where((p) => p.id == widget.planId)
            .firstOrNull;

        if (plan == null) {
          return const Center(
            child: Text(
              'Workout plan not found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Column(
          children: [
            _buildPlanOverview(plan),
            const SizedBox(height: 24),
            if (!_isSessionActive) _buildStartButton() else _buildWorkoutProgress(),
            if (_isSessionActive) ...[
              const SizedBox(height: 24),
              _buildNotesSection(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPlanOverview(dynamic plan) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '${plan.estimatedDuration} min',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.fitness_center, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            plan.muscleGroups.join(', '),
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        return PrimaryButton(
          text: 'Start Workout',
          onPressed: _startWorkout,
          isLoading: workoutProvider.isLoading,
        );
      },
    );
  }

  Widget _buildWorkoutProgress() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout in Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Time', _formatDuration()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Sets', '0'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Keep pushing! You\'re doing great!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white90,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout Notes (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'How did the workout feel? Any observations?',
              hintStyle: const TextStyle(color: Colors.white60),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _isSessionActive = false;
                });
                context.pop();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Consumer<WorkoutProvider>(
              builder: (context, workoutProvider, child) {
                return PrimaryButton(
                  text: 'Complete Workout',
                  onPressed: _completeWorkout,
                  isLoading: workoutProvider.isLoading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
