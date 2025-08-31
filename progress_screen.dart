import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/glass_card.dart';
import '../../utils/app_theme.dart';
import '../layout/main_layout.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final TextEditingController _weightController = TextEditingController();

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
        workoutProvider.loadUserWeightLogs(user.id),
        workoutProvider.loadUserWorkoutSessions(user.id),
        workoutProvider.loadUserAnalytics(user.id),
      ]);
    }
  }

  Future<void> _logWeight() async {
    if (_weightController.text.trim().isEmpty) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    try {
      await workoutProvider.logWeight(
        userId: user.id,
        weight: double.parse(_weightController.text),
      );

      if (mounted) {
        _weightController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weight logged successfully'),
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
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 3,
      child: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildQuickStats(),
                const SizedBox(height: 24),
                _buildWeightChart(),
                const SizedBox(height: 24),
                _buildLogWeight(),
                const SizedBox(height: 24),
                _buildRecentWorkouts(),
                const SizedBox(height: 100), // Space for bottom navigation
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Your Progress',
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer2<AuthProvider, WorkoutProvider>(
      builder: (context, authProvider, workoutProvider, child) {
        final analytics = workoutProvider.analytics;
        final user = authProvider.user;
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Workouts',
                '${analytics?['totalWorkouts'] ?? 0}',
                Icons.fitness_center,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'This Week',
                '${analytics?['weeklyWorkouts'] ?? 0}',
                Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Current Weight',
                '${user?.currentWeight?.toStringAsFixed(1) ?? '75.0'}kg',
                Icons.monitor_weight,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final weightLogs = workoutProvider.getRecentWeightLogs(limit: 10);
        
        if (weightLogs.isEmpty) {
          return GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.trending_up,
                  size: 48,
                  color: Colors.white60,
                ),
                const SizedBox(height: 16),
                Text(
                  'No weight data yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start logging your weight to see progress',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weight Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: weightLogs.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.weight,
                          );
                        }).toList(),
                        isCurved: true,
                        color: AppTheme.primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primaryColor.withOpacity(0.1),
                        ),
                      ),
                    ],
                    minY: weightLogs.map((log) => log.weight).reduce((a, b) => a < b ? a : b) - 2,
                    maxY: weightLogs.map((log) => log.weight).reduce((a, b) => a > b ? a : b) + 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start: ${weightLogs.last.weight.toStringAsFixed(1)}kg',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Latest: ${weightLogs.first.weight.toStringAsFixed(1)}kg',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogWeight() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log Weight',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter weight (kg)',
                    hintStyle: TextStyle(color: Colors.white60),
                    suffixText: 'kg',
                    suffixStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Consumer<WorkoutProvider>(
                builder: (context, workoutProvider, child) {
                  return ElevatedButton(
                    onPressed: workoutProvider.isLoading ? null : _logWeight,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: workoutProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Log'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorkouts() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final recentSessions = workoutProvider.getRecentSessions();
        
        return GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Workouts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (recentSessions.isEmpty)
                Text(
                  'No workouts completed yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                )
              else
                ...recentSessions.map((session) => _buildWorkoutItem(session)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutItem(dynamic session) {
    final duration = session.endTime != null
        ? session.endTime!.difference(session.startTime)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: session.isCompleted == true 
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              session.isCompleted == true ? Icons.check : Icons.schedule,
              color: session.isCompleted == true ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(session.startTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (duration != null)
            Text(
              '${duration.inMinutes}m',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}