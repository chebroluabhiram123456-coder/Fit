import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/glass_card.dart';
import '../../utils/app_theme.dart';
import '../layout/main_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      await Future.wait([
        workoutProvider.loadUserWorkoutPlans(user.id),
        workoutProvider.loadUserAnalytics(user.id),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      child: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildWeekCalendar(),
                const SizedBox(height: 32),
                _buildGreeting(),
                const SizedBox(height: 24),
                _buildTodayWorkout(),
                const SizedBox(height: 24),
                _buildCustomWorkoutButton(),
                const SizedBox(height: 24),
                _buildQuickStats(),
                const SizedBox(height: 100), // Space for bottom navigation
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('HH:mm').format(DateTime.now()),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Row(
          children: [
            Container(
              width: 20,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.battery_full, color: Colors.white, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekCalendar() {
    final now = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final date = now.add(Duration(days: index - 2));
        final isToday = index == 2;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isToday ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                DateFormat('E').format(date).substring(0, 2),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date.day.toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isToday) ...[
                const SizedBox(height: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white60,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGreeting() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final firstName = authProvider.user?.name.split(' ').first ?? 'Athlete';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get ready, $firstName',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Let's smash today's workout!",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white90,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodayWorkout() {
    return Consumer2<AuthProvider, WorkoutProvider>(
      builder: (context, authProvider, workoutProvider, child) {
        final todayPlan = workoutProvider.getTodayWorkoutPlan();
        
        if (todayPlan == null) {
          return _buildNoWorkoutCard();
        }
        
        return GlassCard(
          onTap: () => context.go('/workout/${todayPlan.id}'),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Special for ${authProvider.user?.name.split(' ').first}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Gym',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${todayPlan.estimatedDuration} min',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                todayPlan.muscleGroups.join(', '),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white90,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildExerciseImage('https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=100&h=100&fit=crop'),
                      _buildExerciseImage('https://images.unsplash.com/photo-1594381898411-846e7d193883?w=100&h=100&fit=crop'),
                      _buildExerciseImage('https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=100&h=100&fit=crop'),
                      _buildExerciseImage('https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=100&h=100&fit=crop'),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoWorkoutCard() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(
            Icons.fitness_center,
            size: 48,
            color: Colors.white60,
          ),
          const SizedBox(height: 16),
          Text(
            'No workout planned for today',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a workout plan to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Create Plan',
            onPressed: () => context.go('/weekly-plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseImage(String url) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCustomWorkoutButton() {
    return GlassCard(
      onTap: () => context.go('/exercises'),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Custom Workout',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white70,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer2<AuthProvider, WorkoutProvider>(
      builder: (context, authProvider, workoutProvider, child) {
        final analytics = workoutProvider.analytics;
        
        return Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '${analytics?['weeklyWorkouts'] ?? 0}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This Week',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '${authProvider.user?.currentWeight?.toStringAsFixed(0) ?? '75'}kg',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current Weight',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
