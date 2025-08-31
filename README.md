# FitTracker - Flutter Mobile App

A comprehensive fitness tracking mobile application built with Flutter, designed to help users manage their workout routines, track exercises, monitor progress, and achieve their fitness goals.

## Features

### 🔐 Authentication System
- **User Registration & Login**: Secure account creation and authentication
- **Profile Management**: Update personal information, height, weight, and fitness goals
- **Session Persistence**: Stay logged in across app sessions

### 💪 Exercise Management
- **Exercise Library**: Browse a comprehensive collection of exercises
- **Custom Exercises**: Create and save your own custom exercises
- **Exercise Search & Filter**: Find exercises by name or muscle group
- **Muscle Group Categories**: Chest, Back, Shoulders, Arms, Legs, Core, Cardio, Full Body

### 📅 Workout Planning
- **Weekly Workout Plans**: Create structured workout schedules for each day of the week
- **Customizable Plans**: Set duration, target muscle groups, and exercise combinations
- **Today's Workout**: Quick access to today's scheduled workout
- **Plan Management**: Edit, update, and manage your workout plans

### 🏃‍♂️ Workout Tracking
- **Live Workout Sessions**: Start and track workout sessions in real-time
- **Session Timer**: Monitor workout duration with live timer
- **Progress Logging**: Record sets, reps, and weights for each exercise
- **Workout Notes**: Add personal notes and observations after workouts

### 📊 Progress Monitoring
- **Weight Tracking**: Log and visualize weight changes over time
- **Interactive Charts**: Beautiful charts showing weight progress trends
- **Workout Analytics**: View workout statistics and achievements
- **Progress History**: Track your fitness journey with detailed history

### 🎨 Beautiful UI/UX
- **Glass-morphism Design**: Modern, elegant glass-effect interface
- **Dark Theme**: Eye-friendly dark theme with gradient backgrounds
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Responsive Design**: Optimized for various screen sizes

## Technology Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider pattern
- **UI Components**: Custom glass-morphism widgets
- **Navigation**: GoRouter for type-safe routing
- **Charts**: FL Chart for data visualization
- **HTTP Client**: Dio for API communication
- **Local Storage**: SharedPreferences for data persistence

### Backend Integration
- **API Communication**: RESTful API integration
- **Authentication**: JWT-based session management
- **Real-time Updates**: Efficient data synchronization
- **Error Handling**: Comprehensive error management

## App Architecture

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   └── exercise_model.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── exercise_provider.dart
│   └── workout_provider.dart
├── services/                 # API services
│   └── api_service.dart
├── screens/                  # UI screens
│   ├── auth/
│   ├── home/
│   ├── exercises/
│   ├── workouts/
│   ├── profile/
│   ├── progress/
│   └── layout/
├── widgets/                  # Reusable components
│   └── glass_card.dart
└── utils/                    # Utilities
    └── app_theme.dart
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- Android Studio / VS Code
- Running backend server (Node.js + Express)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   Update the `baseUrl` in `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://your-backend-url:5000';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Development Setup

1. **Enable Flutter development**
   ```bash
   flutter doctor
   ```

2. **Run on specific device**
   ```bash
   flutter devices
   flutter run -d <device-id>
   ```

3. **Build for release**
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

## Key Screens

### 🏠 Home Screen
- Welcome message with personalized greeting
- Week calendar with today's highlight
- Today's workout overview with quick start
- Custom workout access
- Quick stats (weekly workouts, current weight)

### 🔍 Exercise Library
- Searchable exercise database
- Filter by muscle groups
- Exercise details with images/videos
- Create custom exercises
- Exercise categorization

### 📋 Weekly Plan
- Visual weekly workout schedule
- Day-by-day workout planning
- Quick workout creation
- Plan editing and management
- Rest day scheduling

### 🎯 Workout Session
- Live workout tracking
- Session timer and progress
- Exercise logging
- Workout notes
- Session completion

### 👤 Profile
- Personal information management
- Physical metrics (height, weight, goals)
- Account settings
- App preferences

### 📈 Progress
- Weight tracking charts
- Workout statistics
- Progress visualization
- Achievement tracking
- Historical data

## API Integration

The app integrates with a Node.js/Express backend providing:

- **Authentication endpoints**: `/api/auth/login`, `/api/auth/register`
- **User management**: `/api/users/*`
- **Exercise data**: `/api/exercises/*`
- **Workout plans**: `/api/workout-plans/*`
- **Session tracking**: `/api/workout-sessions/*`
- **Progress data**: `/api/weight-logs/*`, `/api/analytics/*`

## State Management

Uses Provider pattern for efficient state management:

- **AuthProvider**: User authentication and profile management
- **ExerciseProvider**: Exercise library and search functionality
- **WorkoutProvider**: Workout plans, sessions, and progress tracking

## Design System

### Color Palette
- **Primary**: Purple gradient (#6366F1)
- **Secondary**: Violet (#8B5CF6)
- **Accent**: Pink (#EC4899)
- **Background**: Dark purple gradient
- **Glass**: Semi-transparent white overlays

### Typography
- **Font Family**: Poppins
- **Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700), Black (900)
- **Responsive sizing**: Scales across different screen sizes

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions, issues, or feature requests, please:
1. Check existing issues
2. Create a new issue with detailed description
3. Provide steps to reproduce any bugs
4. Include device/platform information

---

Built with ❤️ using Flutter for an amazing fitness tracking experience!
