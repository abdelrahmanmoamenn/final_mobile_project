import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

// ─── App Bar ────────────────────────────────────────────────────────────────
class FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showAvatar;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  const FormAppBar({
    super.key,
    this.showAvatar = true,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: showAvatar
          ? Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.language,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            )
          : null,
      title: const Text(
        'FORM',
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
          letterSpacing: 2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: onNotificationTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

// ─── Circular Progress Widget ────────────────────────────────────────────────
class CircularProgressWidget extends StatelessWidget {
  final double percent;
  final String label;
  final double size;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  const CircularProgressWidget({
    super.key,
    required this.percent,
    required this.label,
    this.size = 90,
    this.color = AppColors.primary,
    this.trackColor = AppColors.tertiary,
    this.strokeWidth = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              percent: percent,
              color: color,
              trackColor: trackColor,
              strokeWidth: strokeWidth,
            ),
            child: Center(
              child: Text(
                '${(percent * 100).round()}%',
                style: AppTextStyles.headline3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(letterSpacing: 1.5),
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double percent;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.percent,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter old) =>
      old.percent != percent || old.color != color;
}

// ─── Card Container ──────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: child,
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: AppTextStyles.headline3)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(actionLabel!, style: AppTextStyles.labelPrimary),
                const SizedBox(width: 4),
                const Icon(Icons.edit, color: AppColors.primary, size: 16),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Primary Button ──────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final String? text; // backward-compat alias for label
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? icon; // backward-compat alias for leadingIcon
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isOutlined;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.text = '',
    this.leadingIcon,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary;
    final fg = foregroundColor ?? AppColors.white;
    final displayLabel = label.isEmpty ? (text ?? '') : label;
    final displayIcon = icon ?? leadingIcon;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : bg,
          foregroundColor: isOutlined ? bg : fg,
          side: isOutlined ? BorderSide(color: bg) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (displayIcon != null) ...[
                    Icon(displayIcon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    displayLabel.toUpperCase(),
                    style: AppTextStyles.labelPrimary.copyWith(
                      color: isOutlined ? bg : fg,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Toggle Switch ───────────────────────────────────────────────────────────
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
      inactiveThumbColor: AppColors.neutral,
      inactiveTrackColor: AppColors.tertiary,
    );
  }
}

// ─── Muscle Tag Chip ─────────────────────────────────────────────────────────
class MuscleTag extends StatelessWidget {
  final String label;
  final bool isActive;

  const MuscleTag({super.key, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.tertiary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.primary : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Counter Input ───────────────────────────────────────────────────────────
class CounterInput extends StatelessWidget {
  final String label;
  final double value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final String Function(double) formatter;

  const CounterInput({
    super.key,
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.tertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: AppColors.textSecondary),
                onPressed: onDecrement,
              ),
              Text(
                formatter(value),
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.textSecondary),
                onPressed: onIncrement,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Exercise Row (for workout list) ─────────────────────────────────────────
class ExerciseListTile extends StatelessWidget {
  final String name;
  final String muscleGroup;
  final int sets;
  final int reps;
  final int restSeconds;
  final VoidCallback? onPlay;

  const ExerciseListTile({
    super.key,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Exercise image placeholder
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  _getExerciseIcon(muscleGroup),
                  color: AppColors.primary.withValues(alpha: 0.6),
                  size: 28,
                ),
                Positioned(
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${sets}x$reps',
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    MuscleTag(label: muscleGroup, isActive: true),
                    const SizedBox(width: 8),
                    Text('• Rest: ${restSeconds}s', style: AppTextStyles.label),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getExerciseIcon(String muscle) {
    switch (muscle.toLowerCase()) {
      case 'chest':
        return Icons.fitness_center;
      case 'back':
        return Icons.airline_seat_flat;
      case 'legs':
      case 'quads':
      case 'hamstrings':
        return Icons.directions_run;
      case 'shoulders':
        return Icons.sports_gymnastics;
      case 'triceps':
      case 'biceps':
        return Icons.sports_martial_arts;
      default:
        return Icons.fitness_center;
    }
  }
}

// ─── Rest Timer Circle (Stateful - actual working timer) ─────────────────────
class RestTimerCircle extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final bool isRunning;

  const RestTimerCircle({
    super.key,
    required this.totalSeconds,
    this.onComplete,
    this.onSkip,
    this.isRunning = true,
  });

  @override
  State<RestTimerCircle> createState() => RestTimerCircleState();
}

class RestTimerCircleState extends State<RestTimerCircle> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    if (widget.isRunning) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(RestTimerCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _remainingSeconds = widget.totalSeconds;
        _startTimer();
      } else {
        _timer?.cancel();
        _remainingSeconds = widget.totalSeconds;
      }
    } else if (widget.totalSeconds != oldWidget.totalSeconds &&
        !widget.isRunning) {
      _remainingSeconds = widget.totalSeconds;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            timer.cancel();
            widget.onComplete?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void addTime(int seconds) {
    if (mounted) {
      setState(() {
        _remainingSeconds += seconds;
      });
    }
  }

  void reset(int seconds) {
    if (mounted) {
      setState(() {
        _timer?.cancel();
        _remainingSeconds = seconds;
        _startTimer();
      });
    }
  }

  void togglePause() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
    if (mounted) setState(() {}); // Ensure UI updates to show Play/Pause
  }

  bool get isTimerRunning => _timer?.isActive ?? false;

  void skip() {
    _timer?.cancel();
    widget.onSkip?.call();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalSeconds > 0
        ? _remainingSeconds / widget.totalSeconds
        : 0.0;
    final minutes = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(
            painter: _TimerPainter(
              progress: progress,
              isActive: widget.isRunning,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                    style: AppTextStyles.headline1.copyWith(
                      fontSize: 36,
                      color: widget.isRunning
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.isRunning
                        ? ((_timer?.isActive ?? false) ? 'REST' : 'PAUSED')
                        : 'READY',
                    style: AppTextStyles.label.copyWith(
                      color: widget.isRunning
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final bool isActive;

  _TimerPainter({required this.progress, this.isActive = true});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.tertiary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Glow effect (subtle when inactive)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = (isActive ? AppColors.primary : AppColors.neutral).withValues(
          alpha: 0.15,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    // Progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = isActive
            ? AppColors.primary
            : AppColors.neutral.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TimerPainter old) =>
      old.progress != progress || old.isActive != isActive;
}
