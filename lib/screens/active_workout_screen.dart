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

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with WidgetsBindingObserver {
  late int _currentExerciseIndex;
  late double _currentWeight;
  late int _currentReps;
  late int _currentSetNumber;
  String _previousWeight = '0';
  String _previousReps = '0';
  final _databaseService = DatabaseService();
  final _userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  bool _currentSetLogged = false;
  bool _isLogging = false;

  // Timer state - now using actual countdown timer
  final GlobalKey<RestTimerCircleState> _timerKey = GlobalKey<RestTimerCircleState>();
  bool _timerActive = false;
  int _restDuration = 90;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentExerciseIndex = 0;
    _currentSetNumber = 1;
    _currentWeight = 185.0;
    _currentReps = 8;
    _startWorkoutSession();
    _loadPreviousSet();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _endWorkoutSession();
    }
  }

  Future<void> _startWorkoutSession() async {
    try {
      await _databaseService.startWorkoutSession(_userId);
    } catch (e, stack) {
      appError('ActiveWorkoutScreen._startWorkoutSession', e, stack);
    }
  }

  Future<void> _endWorkoutSession() async {
    try {
      await _databaseService.endWorkoutSession(_userId);
    } catch (e, stack) {
      appError('ActiveWorkoutScreen._endWorkoutSession', e, stack);
    }
  }

  void _loadPreviousSet() async {
    if (_currentExerciseIndex >= widget.workoutPlan.exercises.length) return;

    final exercise = widget.workoutPlan.exercises[_currentExerciseIndex];
    final lastSet = await _databaseService.getLastLoggedSet(
      userId: _userId,
      exerciseId: exercise.id,
    );

    if (mounted) {
      setState(() {
        if (lastSet != null) {
          _previousWeight = '${(lastSet['weight'] as double).toInt()} lbs';
          _previousReps = '${lastSet['reps']} reps';
          _currentWeight = lastSet['weight'] as double;
          _currentReps = lastSet['reps'] as int;
        } else {
          _previousWeight = 'No data';
          _previousReps = 'No data';
          _currentWeight = 185.0;
          _currentReps = 8;
        }
        // Start rest timer after loading previous set data
        _restDuration = exercise.restSeconds;
        _timerActive = true;
      });
    }
  }

  void _addRestTime(int seconds) {
    final timerState = _timerKey.currentState;
    if (timerState != null) {
      timerState.addTime(seconds);
    }
  }

  void _skipRest() {
    setState(() {
      _timerActive = false;
    });
  }

  void _onTimerComplete() {
    setState(() {
      _timerActive = false;
    });
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

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Set logged: ${_currentWeight.toInt()} lbs × $_currentReps reps'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Mark current set as logged
      if (mounted) {
        setState(() {
          _currentSetLogged = true;
        });
      }

      // Move to next set or exercise
      if (_currentSetNumber < exercise.sets) {
        if (mounted) {
          setState(() {
            _currentSetNumber++;
            _currentSetLogged = false;
            // Start rest timer between sets
            _restDuration = exercise.restSeconds;
            _timerActive = true;
          });
        }
      } else if (_currentExerciseIndex < widget.workoutPlan.exercises.length - 1) {
        if (mounted) {
          setState(() {
            _currentExerciseIndex++;
            _currentSetNumber = 1;
            _currentSetLogged = false;
          });
          _loadPreviousSet();
        }
      } else {
        // Workout complete - end session and show dialog
        await _endWorkoutSession();
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Workout Complete!'),
              content: const Text('Great job! Your workout has been saved.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    if (_currentExerciseIndex >= widget.workoutPlan.exercises.length) {
      return const Scaffold(
        body: Center(child: Text('Workout Complete!')),
      );
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
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1.5,
              ),
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
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
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
                Text('• Rest: ${exercise.restSeconds}s', style: AppTextStyles.label),
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
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              children: [
                                TextSpan(text: 'Set $_currentSetNumber '),
                                TextSpan(
                                  text: 'of ${exercise.sets}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('PREVIOUS', style: AppTextStyles.label),
                          const SizedBox(height: 4),
                          Text(
                            '$_previousWeight × $_previousReps',
                            style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logSet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Log Set'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Show countdown timer when active
            Center(
              child: _timerActive
                  ? RestTimerCircle(
                      key: ValueKey('timer_${_currentExerciseIndex}_$_currentSetNumber'),
                      totalSeconds: _restDuration,
                      onComplete: _onTimerComplete,
                      onSkip: _skipRest,
                    )
                  : const SizedBox(height: 160),
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
                _OutlineActionButton(label: 'Skip', onTap: _skipRest),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _currentExerciseIndex < widget.workoutPlan.exercises.length - 1
                  ? 'Next Exercise'
                  : 'Complete Workout',
              onPressed: () async {
                if (!_currentSetLogged) {
                  // Auto-log the current set before advancing
                  await _logSet();
                  // If logSet fails or moves to workout-complete, don't proceed
                  if (!mounted) return;
                }
                if (_currentExerciseIndex < widget.workoutPlan.exercises.length - 1) {
                  setState(() {
                    _currentExerciseIndex++;
                    _currentSetNumber = 1;
                  });
                  _loadPreviousSet();
                } else {
                  // Complete Workout - mark all sets as logged to allow proceed
                  if (mounted) {
                    setState(() {
                      _currentSetLogged = true;
                    });
                  }
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
