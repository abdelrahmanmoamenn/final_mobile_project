import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../services/database_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_error_logger.dart';
import '../widgets/widgets.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutPlan workoutPlan;

  const ActiveWorkoutScreen({super.key, required this.workoutPlan});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late int _currentExerciseIndex;
  late double _currentWeight;
  late int _currentReps;
  late int _currentSetNumber;
  final _databaseService = DatabaseService();
  final _userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  bool _isLogging = false;
  bool _isSessionEnded = false;

  // Timer state - now using actual countdown timer
  final GlobalKey<RestTimerCircleState> _timerKey =
      GlobalKey<RestTimerCircleState>();
  bool _timerActive = false;
  int _restDuration = 90;

  @override
  void initState() {
    super.initState();
    _currentExerciseIndex = 0;
    _currentSetNumber = 1;
    _currentWeight = 185.0;
    _currentReps = 8;
    _startWorkoutSession();
  }

  @override
  void dispose() {
    _endWorkoutSession();
    super.dispose();
  }

  Future<void> _startWorkoutSession() async {
    try {
      await _databaseService.startWorkoutSession(_userId);
    } catch (e, stack) {
      appError('ActiveWorkoutScreen._startWorkoutSession', e, stack);
    }
  }

  Future<void> _endWorkoutSession() async {
    if (_isSessionEnded) return;
    _isSessionEnded = true;
    try {
      await _databaseService.endWorkoutSession(_userId);
    } catch (e, stack) {
      appError('ActiveWorkoutScreen._endWorkoutSession', e, stack);
    }
  }

  void _startRestTimer(int seconds) {
    if (seconds <= 0) return;
    setState(() {
      _restDuration = seconds;
      _timerActive = true;
    });
    // Force the child widget to reset and start
    _timerKey.currentState?.reset(seconds);
  }

  void _stopRestTimer() {
    setState(() {
      _timerActive = false;
      _restDuration = 0;
    });
  }

  void _addRestTime(int seconds) {
    final timerState = _timerKey.currentState;
    if (timerState != null) {
      timerState.addTime(seconds);
    }
  }

  void _togglePause() {
    if (!_timerActive) {
      final exercise = widget.workoutPlan.exercises[_currentExerciseIndex];
      _startRestTimer(exercise.restSeconds);
    } else {
      _timerKey.currentState?.togglePause();
      setState(() {});
    }
  }

  void _onTimerComplete() {
    _stopRestTimer();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rest complete! Ready for the next set?'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _decrementWeight() {
    if (_currentWeight > 5) {
      setState(() => _currentWeight -= 5);
    }
  }

  void _incrementWeight() {
    setState(() => _currentWeight += 5);
  }

  void _decrementReps() {
    if (_currentReps > 1) {
      setState(() => _currentReps--);
    }
  }

  void _incrementReps() {
    setState(() => _currentReps++);
  }

  Future<void> _logSet() async {
    if (_currentExerciseIndex >= widget.workoutPlan.exercises.length) return;
    if (_isLogging) return;
    if (_currentWeight <= 0 || _currentReps <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weight and reps must be greater than 0'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    _isLogging = true;

    final exercise = widget.workoutPlan.exercises[_currentExerciseIndex];

    try {
      // Save to database
      await _databaseService.insertLoggedSet(
        userId: _userId,
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        setNumber: _currentSetNumber,
        weight: _currentWeight,
        reps: _currentReps,
      );

      // Update personal record if this is a new max
      await _databaseService.updatePersonalRecord(
        userId: _userId,
        exerciseName: exercise.name,
        weight: _currentWeight,
        reps: _currentReps,
      );

      // Show confirmation and update state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Set $_currentSetNumber logged: ${_currentWeight.toInt()} lbs × $_currentReps reps',
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        setState(() {
          if (_currentSetNumber < exercise.sets) {
            // Move to next set in current exercise
            _currentSetNumber++;
            _startRestTimer(exercise.restSeconds);
          } else if (_currentExerciseIndex <
              widget.workoutPlan.exercises.length - 1) {
            // All sets done for this exercise, move to next exercise automatically
            _currentExerciseIndex++;
            _currentSetNumber = 1;
            // Set reps to the next exercise's default
            _currentReps =
                widget.workoutPlan.exercises[_currentExerciseIndex].reps;
            // Start rest timer before starting next exercise
            _startRestTimer(exercise.restSeconds);
          } else {
            // Workout complete - last set of last exercise logged
            _endWorkoutSession();
            _showWorkoutCompleteDialog();
          }
        });
      }
    } catch (e, stack) {
      appError('ActiveWorkoutScreen._logSet', e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error logging set. Please try again.')),
        );
      }
    } finally {
      _isLogging = false;
    }
  }

  void _showWorkoutCompleteDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Workout Complete!'),
        content: const Text('Great job! Your workout has been saved.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to workout list
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentExerciseIndex >= widget.workoutPlan.exercises.length) {
      return const Scaffold(body: Center(child: Text('Workout Complete!')));
    }

    final exercise = widget.workoutPlan.exercises[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.workoutPlan.name.toUpperCase(),
              style: AppTextStyles.labelPrimary,
            ),
            Text(
              'Exercise ${_currentExerciseIndex + 1} of ${widget.workoutPlan.exercises.length}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // End workout session early if they quit
              await _endWorkoutSession();
              if (mounted) {
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text(
              'End',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(exercise.name, style: AppTextStyles.headline2),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                MuscleTag(label: exercise.muscleGroup, isActive: true),
                const SizedBox(width: 8),
                Text(
                  '• Rest: ${exercise.restSeconds}s',
                  style: AppTextStyles.label,
                ),
              ],
            ),
            const SizedBox(height: 32),
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CURRENT SET', style: AppTextStyles.label),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: AppTextStyles.headline3,
                              children: [
                                TextSpan(text: 'Set $_currentSetNumber '),
                                TextSpan(
                                  text: 'of ${exercise.sets}',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CounterInput(
                          label: 'Weight (lbs)',
                          value: _currentWeight,
                          onDecrement: _decrementWeight,
                          onIncrement: _incrementWeight,
                          formatter: (v) => v.toInt().toString(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CounterInput(
                          label: 'Reps',
                          value: _currentReps.toDouble(),
                          onDecrement: _decrementReps,
                          onIncrement: _incrementReps,
                          formatter: (v) => v.toInt().toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Log Set',
                    leadingIcon: Icons.check_circle_outline,
                    onPressed: _logSet,
                    isLoading: _isLogging,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Permanent timer display
            Center(
              child: RestTimerCircle(
                key: _timerKey,
                totalSeconds: _timerActive
                    ? _restDuration
                    : exercise.restSeconds,
                isRunning: _timerActive,
                onComplete: _onTimerComplete,
                onSkip: _stopRestTimer,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OutlineActionButton(
                  label: '+30s',
                  onTap: () => _addRestTime(30),
                ),
                const SizedBox(width: 16),
                _OutlineActionButton(
                  label: (_timerKey.currentState?.isTimerRunning ?? false)
                      ? 'Pause'
                      : 'Play',
                  onTap: _togglePause,
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label:
                  _currentExerciseIndex <
                      widget.workoutPlan.exercises.length - 1
                  ? 'Next Exercise'
                  : 'Finish Workout',
              onPressed: () async {
                if (_currentExerciseIndex <
                    widget.workoutPlan.exercises.length - 1) {
                  setState(() {
                    _currentExerciseIndex++;
                    _currentSetNumber = 1;
                    _currentReps = widget
                        .workoutPlan
                        .exercises[_currentExerciseIndex]
                        .reps;
                    _timerActive = false; // Stop timer if moving manually
                  });
                } else {
                  // Final exercise manual finish
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Finish Workout?'),
                      content: const Text('Mark this workout as complete?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Continue'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _endWorkoutSession();
                            if (mounted) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: const Text('Complete'),
                        ),
                      ],
                    ),
                  );
                }
              },
              leadingIcon: null,
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.tertiary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
