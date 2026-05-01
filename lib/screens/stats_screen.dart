import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/widgets.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _db = DatabaseService();
  late final String _userId;

  String _selectedVolumePeriod = '1M';

  // Loaded from DB
  double? _avgWeight;
  double? _weightChange;
  Map<String, List<double>> _volumeData = {
    '1W': [0],
    '1M': [0, 0, 0, 0],
    '3M': List.filled(12, 0),
  };
  List<List<int>> _consistencyData = List.generate(5, (_) => List.filled(7, 0));

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);

    final results = await Future.wait([
      _db.getAverageWeight(_userId),
      _db.getWeightChangeSinceLastWeek(_userId),
      _db.getWeeklyVolume(_userId, weeks: 1),
      _db.getWeeklyVolume(_userId, weeks: 4),
      _db.getWeeklyVolume(_userId, weeks: 12),
      _db.getConsistencyGrid(_userId, weeks: 5),
    ]);

    setState(() {
      _avgWeight = results[0] as double?;
      _weightChange = results[1] as double?;
      _volumeData = {
        '1W': results[2] as List<double>,
        '1M': results[3] as List<double>,
        '3M': results[4] as List<double>,
      };
      _consistencyData = results[5] as List<List<int>>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final avgWeightStr = _avgWeight != null
        ? _avgWeight!.toStringAsFixed(1)
        : '—';

    String weightChangeStr = '—';
    Color weightChangeColor = AppColors.textMuted;
    if (_weightChange != null) {
      final sign = _weightChange! >= 0 ? '+' : '';
      weightChangeStr = '$sign${_weightChange} lbs';
      weightChangeColor =
      _weightChange! < 0 ? AppColors.success : AppColors.danger;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CoachAIAppBar(),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : RefreshIndicator(
        onRefresh: _loadStats,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Performance', style: AppTextStyles.headline1),
              const SizedBox(height: 4),
              const Text(
                'Track your progress and consistency over time.',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // ── Top Stats Grid ────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.show_chart,
                      iconColor: AppColors.textSecondary,
                      label: 'Total Volume',
                      value: _formatVolume(
                        (_volumeData['1M'] ?? []).fold(0.0, (a, b) => a + b),
                      ),
                      sub: '+8% this week',
                      subColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.monitor_weight_outlined,
                      iconColor: AppColors.primary,
                      label: 'Avg Weight',
                      value: avgWeightStr,
                      valueUnit: _avgWeight != null ? 'lbs' : null,
                      sub: weightChangeStr,
                      subColor: weightChangeColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer_outlined,
                      iconColor: AppColors.textSecondary,
                      label: 'Avg Duration',
                      value: '45',
                      valueUnit: 'min',
                      sub: 'Optimal',
                      subColor: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department,
                      iconColor: AppColors.primary,
                      label: 'Current Streak',
                      value: _calcStreak().toString(),
                      valueUnit: 'days',
                      sub: 'Keep it up!',
                      subColor: AppColors.primary,
                      highlight: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Volume Lifted Chart ───────────────────────────────
              _VolumeChartCard(
                selectedPeriod: _selectedVolumePeriod,
                volumeData: _volumeData,
                onPeriodChanged: (p) =>
                    setState(() => _selectedVolumePeriod = p),
              ),
              const SizedBox(height: 16),

              // ── Consistency Heatmap ───────────────────────────────
              _ConsistencyCard(data: _consistencyData),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Counts how many consecutive days (ending today) have workout data.
  int _calcStreak() {
    int streak = 0;
    final flat = _consistencyData.reversed.expand((w) => w.reversed).toList();
    for (final v in flat) {
      if (v > 0) streak++;
      else break;
    }
    return streak;
  }

  String _formatVolume(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toInt().toString();
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? valueUnit;
  final String sub;
  final Color subColor;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueUnit,
    required this.sub,
    required this.subColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.18)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.cardBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: highlight ? AppColors.primary : AppColors.textPrimary,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (valueUnit != null) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    valueUnit!,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 11,
              color: subColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Volume Lifted Chart Card ───────────────────────────────────────────────────

class _VolumeChartCard extends StatelessWidget {
  final String selectedPeriod;
  final Map<String, List<double>> volumeData;
  final ValueChanged<String> onPeriodChanged;

  const _VolumeChartCard({
    required this.selectedPeriod,
    required this.volumeData,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final data = volumeData[selectedPeriod] ?? [];
    final labels =
    List.generate(data.length, (i) => 'W${i + 1}');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Volume\nLifted',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Weight × Reps per week',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: ['1W', '1M', '3M'].map((p) {
                  final isSelected = p == selectedPeriod;
                  return GestureDetector(
                    onTap: () => onPeriodChanged(p),
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(
                            color:
                            AppColors.primary.withValues(alpha: 0.5))
                            : null,
                      ),
                      child: Text(
                        p,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          data.every((v) => v == 0)
              ? const SizedBox(
            height: 140,
            child: Center(
              child: Text(
                'No workouts logged yet.\nStart a workout to see your volume!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          )
              : SizedBox(
            height: 140,
            child: _BarChart(data: data, labels: labels),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  const _BarChart({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();
    final maxVal = data.reduce(max);
    if (maxVal == 0) return const SizedBox();
    final highlightIndex = data.indexOf(maxVal);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(data.length, (i) {
              final ratio = maxVal > 0 ? data[i] / maxVal : 0.0;
              final isHighlight = i == highlightIndex;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: data.length > 6 ? 2 : 6,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        height: 100 * ratio,
                        decoration: BoxDecoration(
                          color: isHighlight
                              ? AppColors.brandBlueLight.withValues(alpha: 0.85)
                              : AppColors.brandBlue.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(data.length, (i) {
            final showLabel = data.length <= 4 ||
                i % (data.length ~/ 4 + 1) == 0 ||
                i == data.length - 1;
            return Expanded(
              child: Text(
                showLabel ? labels[i] : '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Consistency Heatmap Card ───────────────────────────────────────────────────

class _ConsistencyCard extends StatelessWidget {
  final List<List<int>> data;

  const _ConsistencyCard({required this.data});

  Color _cellColor(int intensity) {
    switch (intensity) {
      case 1:
        return AppColors.brandBlue.withValues(alpha: 0.25);
      case 2:
        return AppColors.brandBlue.withValues(alpha: 0.55);
      case 3:
        return AppColors.brandBlueLight.withValues(alpha: 0.85);
      default:
        return AppColors.tertiary.withValues(alpha: 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consistency',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Workout days',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Less',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ...List.generate(
                    4,
                        (i) => Container(
                      margin: const EdgeInsets.only(left: 3),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _cellColor(i),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'More',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: days
                .map((d) => Expanded(
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 8),
          ...data.map((week) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: week
                  .map((intensity) => Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 2),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _cellColor(intensity),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
          )),
        ],
      ),
    );
  }
}