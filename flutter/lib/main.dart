import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/exercise_provider.dart';
import 'services/api_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/exercises/exercise_library_screen.dart';
import 'screens/exercises/create_exercise_screen.dart';
import 'screens/workouts/weekly_plan_screen.dart';
import 'screens/workouts/workout_session_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const FitTrackerApp());
}

class FitTrackerApp extends StatelessWidget {
  const FitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => WorkoutProvider()),
        ChangeNotifierProvider(create: (context) => ExerciseProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'FitTracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: _createRouter(authProvider),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: authProvider.isAuthenticated ? '/home' : '/login',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.fullPath == '/login' || state.fullPath == '/register';

        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }
        if (isAuthenticated && isLoggingIn) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/exercises',
          builder: (context, state) => const ExerciseLibraryScreen(),
        ),
        GoRoute(
          path: '/create-exercise',
          builder: (context, state) => const CreateExerciseScreen(),
        ),
        GoRoute(
          path: '/weekly-plan',
          builder: (context, state) => const WeeklyPlanScreen(),
        ),
        GoRoute(
          path: '/workout/:planId',
          builder: (context, state) => WorkoutSessionScreen(
            planId: state.pathParameters['planId']!,
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (context, state) => const ProgressScreen(),
        ),
      ],
    );
  }
}
