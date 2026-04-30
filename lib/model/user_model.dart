import 'package:flutter/foundation.dart';

class AuthUserModel extends ChangeNotifier {
  String? _uid;

  String? get uid => _uid;
  bool get isLoggedIn => _uid != null;

  void setUid(String? uid) {
    _uid = uid;
    notifyListeners();
  }
}

// Exercise model
class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? imageUrl;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'muscleGroup': muscleGroup,
    'sets': sets,
    'reps': reps,
    'restSeconds': restSeconds,
  };
}

// Workout model
class WorkoutPlan {
  final String id;
  final String name;
  final WorkoutType type;
  final List<Exercise> exercises;
  final int estimatedBurnKcal;
  final int estimatedDurationMin;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.exercises,
    required this.estimatedBurnKcal,
    required this.estimatedDurationMin,
  });
}

enum WorkoutType { push, pull, legs, custom }

extension WorkoutTypeLabel on WorkoutType {
  String get label {
    switch (this) {
      case WorkoutType.push:
        return 'Push';
      case WorkoutType.pull:
        return 'Pull';
      case WorkoutType.legs:
        return 'Legs';
      case WorkoutType.custom:
        return 'Custom';
    }
  }
}

// Logged Set
class LoggedSet {
  final int setNumber;
  double weightLbs;
  int reps;
  bool isLogged;

  LoggedSet({
    required this.setNumber,
    required this.weightLbs,
    required this.reps,
    this.isLogged = false,
  });
}

// Personal Record
class PersonalRecord {
  final String exerciseName;
  final String value;
  final String icon;

  const PersonalRecord({
    required this.exerciseName,
    required this.value,
    required this.icon,
  });
}

// User Profile
class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isPro;
  final double weeklyGoalPercent;
  final double proteinPercent;
  final List<PersonalRecord> personalRecords;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.isPro = false,
    this.weeklyGoalPercent = 0.0,
    this.proteinPercent = 0.0,
    this.personalRecords = const [],
  });
}

// Sample data
class SampleData {
  static final pushWorkout = WorkoutPlan(
    id: 'push_1',
    name: 'Push Day',
    type: WorkoutType.push,
    estimatedBurnKcal: 450,
    estimatedDurationMin: 65,
    exercises: const [
      Exercise(
        id: 'bench_press',
        name: 'Barbell Bench Press',
        muscleGroup: 'Chest',
        sets: 4,
        reps: 10,
        restSeconds: 90,
      ),
      Exercise(
        id: 'incline_db',
        name: 'Incline DB Press',
        muscleGroup: 'Chest',
        sets: 3,
        reps: 12,
        restSeconds: 60,
      ),
      Exercise(
        id: 'tricep_push',
        name: 'Tricep Pushdowns',
        muscleGroup: 'Triceps',
        sets: 3,
        reps: 15,
        restSeconds: 45,
      ),
      Exercise(
        id: 'ohp',
        name: 'Overhead Press',
        muscleGroup: 'Shoulders',
        sets: 4,
        reps: 8,
        restSeconds: 90,
      ),
      Exercise(
        id: 'lat_raise',
        name: 'Lateral Raises',
        muscleGroup: 'Shoulders',
        sets: 3,
        reps: 15,
        restSeconds: 45,
      ),
      Exercise(
        id: 'tricep_dips',
        name: 'Tricep Dips',
        muscleGroup: 'Triceps',
        sets: 3,
        reps: 12,
        restSeconds: 60,
      ),
    ],
  );

  static final pullWorkout = WorkoutPlan(
    id: 'pull_1',
    name: 'Pull Day',
    type: WorkoutType.pull,
    estimatedBurnKcal: 380,
    estimatedDurationMin: 55,
    exercises: const [
      Exercise(
        id: 'deadlift',
        name: 'Deadlift',
        muscleGroup: 'Back',
        sets: 4,
        reps: 6,
        restSeconds: 120,
      ),
      Exercise(
        id: 'pullups',
        name: 'Pull-Ups',
        muscleGroup: 'Back',
        sets: 4,
        reps: 8,
        restSeconds: 90,
      ),
      Exercise(
        id: 'barbell_row',
        name: 'Barbell Row',
        muscleGroup: 'Back',
        sets: 3,
        reps: 10,
        restSeconds: 75,
      ),
      Exercise(
        id: 'face_pull',
        name: 'Face Pulls',
        muscleGroup: 'Rear Delts',
        sets: 3,
        reps: 15,
        restSeconds: 45,
      ),
      Exercise(
        id: 'bicep_curl',
        name: 'Bicep Curls',
        muscleGroup: 'Biceps',
        sets: 3,
        reps: 12,
        restSeconds: 60,
      ),
      Exercise(
        id: 'hammer_curl',
        name: 'Hammer Curls',
        muscleGroup: 'Biceps',
        sets: 3,
        reps: 12,
        restSeconds: 60,
      ),
    ],
  );

  static final legsWorkout = WorkoutPlan(
    id: 'legs_1',
    name: 'Leg Day',
    type: WorkoutType.legs,
    estimatedBurnKcal: 520,
    estimatedDurationMin: 75,
    exercises: const [
      Exercise(
        id: 'squat',
        name: 'Barbell Back Squat',
        muscleGroup: 'Quads',
        sets: 5,
        reps: 8,
        restSeconds: 120,
      ),
      Exercise(
        id: 'leg_press',
        name: 'Leg Press',
        muscleGroup: 'Quads',
        sets: 4,
        reps: 12,
        restSeconds: 90,
      ),
      Exercise(
        id: 'rdl',
        name: 'Romanian Deadlift',
        muscleGroup: 'Hamstrings',
        sets: 3,
        reps: 10,
        restSeconds: 90,
      ),
      Exercise(
        id: 'leg_curl',
        name: 'Lying Leg Curl',
        muscleGroup: 'Hamstrings',
        sets: 3,
        reps: 12,
        restSeconds: 60,
      ),
      Exercise(
        id: 'calf_raise',
        name: 'Standing Calf Raise',
        muscleGroup: 'Calves',
        sets: 4,
        reps: 15,
        restSeconds: 45,
      ),
    ],
  );

  static final List<PersonalRecord> records = [
    PersonalRecord(exerciseName: 'Deadlift', value: '405 lbs', icon: '🏋️'),
    PersonalRecord(exerciseName: '5k Run', value: '22:45', icon: '🏃'),
  ];

  static Map<WorkoutType, WorkoutPlan> get workoutsByType => {
    WorkoutType.push: pushWorkout,
    WorkoutType.pull: pullWorkout,
    WorkoutType.legs: legsWorkout,
    WorkoutType.custom: pushWorkout,
  };
}
