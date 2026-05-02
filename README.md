# FORM: Intelligent Fitness Tracking

<div align="center">

**A production-grade Flutter mobile application for strength training analytics and workout management**

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)]()
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20Web-blueviolet)]()

[Features](#-features) • [Architecture](#-architecture) • [Tech Stack](#-tech-stack) • [Installation](#-installation) • [Usage](#-usage) • [Key Achievements](#-key-achievements)

</div>

---

## 📋 Overview

**FORM** is a comprehensive fitness tracking application that bridges the gap between mobile and cloud infrastructure. It enables users to:

- **Log workouts** with real-time set tracking and personal record monitoring
- **Track progress** through detailed analytics dashboards and consistency metrics
- **Sync seamlessly** across platforms with intelligent offline-first architecture
- **Visualize performance** with multi-dimensional charts and historical data analysis

Built with **enterprise-grade architecture patterns**, FORM demonstrates mastery of full-stack mobile development with particular emphasis on **data synchronization**, **offline-first design**, and **cross-platform compatibility**.

---

## ✨ Features

### Core Fitness Tracking
- 🏋️ **Structured Workout Plans** – Pre-configured Push/Pull/Legs routines with customizable exercises
- 📊 **Real-time Set Logging** – Live weight, reps, and form tracking during active sessions
- 🎯 **Personal Records (PRs)** – Automatic detection and storage of personal bests per exercise
- ⏱️ **Rest Timer** – Configurable countdown with haptic feedback and visual indicators

### Analytics & Insights
- 📈 **Volume Tracking** – Weekly, monthly, and quarterly total volume analysis
- 🔥 **Streak Counter** – Motivation through consistency tracking across multiple time periods
- 📉 **Performance Graphs** – Multi-period volume charts and workout frequency visualization
- 📅 **Consistency Grid** – Week-at-a-glance workout completion heatmap

### Cloud & Offline
- ☁️ **Firebase Real-time Sync** – Bi-directional synchronization with Realtime Database
- 🔄 **Offline-First Architecture** – Full functionality without connectivity, automatic queue-based sync
- 📲 **Cross-Platform Support** – Android, iOS, Windows, and Web targeting from single codebase
- 🛡️ **Authentication** – Email/password Firebase Auth with secure session management

### User Experience
- 🎨 **Dark Theme UI** – Modern, accessibility-focused design system
- ⚡ **Performance Optimized** – IndexedStack navigation, efficient state management
- 🔔 **Real-time Notifications** – Status indicators for network state and sync operations
- 📱 **Responsive Layout** – Adaptive UI across device sizes and orientations

---

## 🏗️ Architecture

### Design Patterns
- **Singleton Pattern** – DatabaseService and ConnectivityService for unified state management
- **Repository Pattern** – DatabaseService abstracts Firestore and SQLite operations
- **Observer Pattern** – WidgetsBindingObserver for app lifecycle event handling
- **State Management** – StatefulWidget with ChangeNotifier for simple, predictable updates

### Data Flow
```
┌─────────────┐
│   UI Layer  │ (Screens, Widgets)
└──────┬──────┘
       │
┌──────▼──────┐
│ Model Layer │ (WorkoutPlan, Exercise, LoggedSet)
└──────┬──────┘
       │
┌──────▼───────────────────┐
│ Service Layer             │
├───────────────────────────┤
│ • DatabaseService         │ ◄──────────┐
│ • ConnectivityService     │            │
│ • Error Logging           │            │
└──────┬──────────┬──────────┘            │
       │          │                       │
┌──────▼──┐ ┌─────▼──────┐     ┌─────────┴──────┐
│  SQLite │ │  Firebase  │────→│ Pending Queue   │
│ (Local) │ │ (Cloud)    │     │ (Sync Buffer)   │
└─────────┘ └────────────┘     └─────────────────┘
```

### Key Architectural Decisions

| Decision | Rationale | Implementation |
|----------|-----------|-----------------|
| **Hybrid Storage** | Offline capability + cloud sync | SQLite (local) + Firebase RTDB (cloud) |
| **Pending Operations Queue** | Resilient data sync without data loss | Dedicated table tracking sync state |
| **Singleton Services** | Global state with predictable lifecycle | Factory pattern with _internal constructor |
| **WidgetsBindingObserver** | Lifecycle-aware data refresh | Sync on app resume, background cleanup |
| **IndexedStack Navigation** | Preserve screen state during tab switching | Four screens in IndexedStack, not recreated |

---

## 💻 Tech Stack

### Frontend
- **Framework:** Flutter 3.11+ with Dart 3.11+
- **State Management:** Provider 6.1.5, ChangeNotifier
- **Navigation:** Named routing with custom AppRouter
- **UI/UX:** Material Design 3 with custom dark theme

### Backend & Storage
- **Authentication:** Firebase Auth (Email/Password)
- **Cloud Database:** Firebase Realtime Database
- **Local Storage:** SQLite with sqflite 2.4.2
- **Cross-platform SQLite:** sqflite_common_ffi for Windows/macOS

### Supporting Libraries
- **Connectivity:** connectivity_plus 6.1.0 (network state monitoring)
- **Local Preferences:** shared_preferences 2.5.3
- **Path Management:** path 1.9.1
- **Icons:** cupertino_icons 1.0.8

### Build & Development
- **Flutter Launcher Icons:** Auto-generation for Android/iOS
- **Linting:** flutter_lints 6.0.0
- **Testing:** flutter_test (included)

### Platforms Targeted
- ✅ Android 5.0+
- ✅ iOS 11.0+
- ✅ Windows 10+
- ✅ macOS 10.11+
- ✅ Web (Chrome, Firefox, Safari)

---

## 🚀 Installation

### Prerequisites
- Flutter 3.11+ ([Install](https://flutter.dev/docs/get-started/install))
- Dart 3.11+ (included with Flutter)
- Android Studio or Xcode (for mobile development)
- Firebase project configured

### Step 1: Clone & Setup
```bash
# Clone the repository
git clone <repository-url>
cd final_mobile_project

# Get dependencies
flutter pub get
```

### Step 2: Configure Firebase
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android, iOS, Web platforms to your Firebase project
3. Download configuration files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Replace credentials in `lib/firebase_options.dart` *(already configured)*

### Step 3: Platform-Specific Setup

**Android:**
```bash
cd android
./gradlew build
cd ..
```

**iOS:**
```bash
cd ios
pod install
cd ..
```

**Windows/macOS:**
```bash
flutter config --enable-windows
# or
flutter config --enable-macos
```

### Step 4: Run the App
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific platform
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter run -d macos          # macOS
```

---

## 📖 Usage

### Getting Started
1. **Create Account:** Sign up with email and password on the splash screen
2. **Browse Workouts:** Select Push/Pull/Legs or create custom routines
3. **Log a Workout:** Start an active session and log sets with weight/reps
4. **View Analytics:** Navigate to Stats tab to see volume trends and performance

### Core Workflows

#### Logging a Workout
```
Home Screen → "Log Workout" → Workout Screen 
→ Select workout type → "Start" → Active Workout Screen
→ Log each set → Confirm PRs → "End Workout"
```

#### Viewing Progress
```
Home Screen → Stats Screen → View volume charts, consistency grid, streaks
→ Toggle time periods (1W, 1M, 3M)
```

#### Managing Profile
```
Home Screen → Profile Screen → View personal records, edit preferences
```

### Navigation Structure
```
├── Splash Screen (Auth check)
├── Auth Gate (Route protection)
├── Login/Sign-Up Screens
└── Main Shell (Authenticated)
    ├── Home (Dashboard)
    ├── Workout (Plan selection)
    ├── Stats (Analytics)
    └── Profile (User info & PRs)
```

---

## 🔧 API & Database Schema

### Firebase Realtime Database Structure
```
users/
  {userId}/
    logged_sets/
      {exerciseId}_{date}_{setNum}/
        exerciseId: "bench_press"
        exerciseName: "Barbell Bench Press"
        weight: 185.0
        reps: 8
        date: "2024-05-02T..."
    personal_records/
      {exerciseName}/
        weight: 405.0
        reps: 6
        lastUpdated: "2024-05-02T..."
    sessions/
      {startTime}/
        startTime: "2024-05-02T..."
        endTime: "2024-05-02T..."
        totalSets: 24
```

### SQLite Tables

**logged_sets**
```sql
id (INTEGER, PK)
userId TEXT
exerciseId TEXT
exerciseName TEXT
setNumber INTEGER
weight REAL
reps INTEGER
date TEXT
```

**personal_records**
```sql
id (INTEGER, PK)
userId TEXT
exerciseName TEXT (UNIQUE with userId)
weight REAL
reps INTEGER
lastUpdated TEXT
```

**workout_sessions**
```sql
id (INTEGER, PK)
userId TEXT
startTime TEXT
endTime TEXT
totalSets INTEGER
```

**pending_operations** (Sync Queue)
```sql
id (INTEGER, PK)
tableName TEXT
operation TEXT (INSERT/UPDATE)
data TEXT (JSON)
createdAt TEXT
status TEXT (pending/synced)
```

---

## 🎯 Key Achievements

### Engineering Excellence
✅ **Offline-First Synchronization** – Implemented robust queue-based sync system that prevents data loss and ensures consistency between local SQLite and cloud Firebase databases

✅ **Cross-Platform Development** – Single Flutter codebase targeting 5 platforms (Android, iOS, Windows, macOS, Web) with platform-specific database initialization

✅ **Production-Grade Error Handling** – Centralized error logging with context tracking, FlutterError reporting integration, and stack trace capture for debugging

✅ **Lifecycle-Aware State Management** – Intelligent data refresh on app resume using WidgetsBindingObserver, preventing stale data and ensuring real-time updates

✅ **Real-Time Database Operations** – Bi-directional Firebase sync with automatic queue management and exponential backoff retry logic

### Code Quality & Architecture
✅ **Clean Architecture** – Separation of concerns across UI, Model, Service, and Utility layers with single-responsibility principle

✅ **Design Patterns** – Proper implementation of Singleton, Repository, and Observer patterns for maintainability and testability

✅ **Resource Management** – Proper disposal of controllers, listeners, and services to prevent memory leaks in long-running sessions

✅ **Type Safety** – Strict null safety with Dart 3.0+ and comprehensive type annotations throughout codebase

### User Experience
✅ **Instant Feedback** – Real-time visual indicators for network state, sync progress, and workout timer

✅ **Data Persistence** – Users can log workouts offline and see their data sync automatically when reconnected

✅ **Performance Optimization** – Using IndexedStack for screen preservation, avoiding unnecessary rebuilds, and lazy-loading data

---

## 🎓 What I Learned

### Mobile Development
- Advanced Flutter patterns and lifecycle management
- Cross-platform development challenges and solutions
- Performance profiling and optimization techniques

### Database Design
- Hybrid storage strategy for offline-first apps
- Transaction management and data consistency
- Synchronization algorithms for eventual consistency

### Cloud Architecture
- Firebase Realtime Database structure and querying
- Authentication flows and session management
- Deployment considerations for multi-platform apps

### Software Engineering
- Clean architecture principles in mobile context
- Error handling and debugging in distributed systems
- Testing strategies for database-heavy applications

---

## 📁 Repository Structure

```
final_mobile_project/
├── lib/
│   ├── main.dart                    # App entry point & routing shell
│   ├── firebase_options.dart        # Firebase configuration
│   ├── screens/                     # UI screens (9 screens)
│   │   ├── splash_screen.dart
│   │   ├── auth_gate_screen.dart
│   │   ├── login_screen.dart
│   │   ├── sign_up_screen.dart
│   │   ├── home_screen.dart         # Dashboard & summary
│   │   ├── workout_screen.dart      # Workout selection
│   │   ├── active_workout_screen.dart # Live logging
│   │   ├── stats_screen.dart        # Analytics & charts
│   │   └── profile_screen.dart      # User profile & PRs
│   ├── model/
│   │   └── user_model.dart          # Domain models & data classes
│   ├── services/
│   │   ├── database_service.dart    # SQLite + Firebase sync logic
│   │   └── connectivity_service.dart # Network state monitoring
│   ├── navigation/
│   │   └── app_router.dart          # Named route definitions
│   ├── widgets/
│   │   ├── custom_text_field.dart
│   │   ├── primary_button.dart
│   │   └── widgets.dart             # Reusable UI components
│   └── utils/
│       ├── app_colors.dart          # Color constants & theme
│       ├── app_text_styles.dart     # Typography definitions
│       ├── app_theme.dart           # Theme configuration
│       └── app_error_logger.dart    # Error handling & logging
├── android/                         # Android native code
├── ios/                             # iOS native code
├── windows/                         # Windows native code
├── macos/                           # macOS native code
├── web/                             # Web assets
├── pubspec.yaml                     # Dependencies & configuration
├── pubspec.lock                     # Locked versions
├── firebase.json                    # Firebase configuration
└── analysis_options.yaml            # Linting rules
```

---

## 🛠️ Development

### Code Organization Principles
- **Single Responsibility:** Each class has one reason to change
- **Dependency Injection:** Services passed through constructors or singletons
- **Immutability:** Data classes use `final` fields and named constructors
- **Error Boundaries:** Try-catch blocks around critical operations with logging

### Adding a New Feature
1. Define models in `lib/model/`
2. Add service methods in `lib/services/`
3. Create screens in `lib/screens/`
4. Add routes to `lib/navigation/app_router.dart`
5. Create reusable widgets in `lib/widgets/`

### Testing Commands
```bash
# Run tests
flutter test

# Generate coverage
flutter test --coverage

# Lint analysis
flutter analyze

# Format code
flutter format lib/
```

---

## 🤝 Contributing

This is an academic project, but improvements and suggestions are welcome:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

---

## 👤 Author

**Created as a Level 3 Semester 2 assignment**

Demonstrates expertise in:
- Full-stack mobile development with Flutter
- Cross-platform architecture and deployment
- Cloud database integration and synchronization
- Enterprise-grade code organization and error handling

---

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing documentation
- Review Firebase setup guide

---

## 🙏 Acknowledgments

- Flutter community and documentation
- Firebase for reliable backend infrastructure
- Material Design for UI inspiration
- Community packages (provider, sqflite, connectivity_plus)

---

<div align="center">

**Made with ❤️ using Flutter**

⭐ If you found this helpful, please consider leaving a star!

</div>

