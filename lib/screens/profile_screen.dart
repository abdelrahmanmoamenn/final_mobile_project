import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../navigation/app_router.dart';
import '../services/database_service.dart';
import '../utils/app_colors.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  final _databaseService = DatabaseService();
  final _userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  late Future<List<PersonalRecord>> _personalRecordsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _personalRecordsFuture = _databaseService.getPersonalRecords(_userId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPersonalRecords();
    }
  }

  Future<void> _loadPersonalRecords() async {
    if (!mounted) return;
    setState(() {
      _personalRecordsFuture = _databaseService.getPersonalRecords(_userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const FormAppBar(showAvatar: false),
      body: RefreshIndicator(
        onRefresh: () async {
          await _databaseService.getPersonalRecords(_userId);
          setState(() {}); // Trigger rebuild with new data
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Header
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?u=alex',
                        ),
                        backgroundColor: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PRO MEMBER',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Fitness Goals
              AppCard(
                child: Column(
                  children: [
                    const SectionHeader(
                      title: 'Fitness Goals',
                      icon: Icons.track_changes,
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircularProgressWidget(
                          percent: 0.82,
                          label: 'Weekly Goal',
                          color: AppColors.primary,
                        ),
                        CircularProgressWidget(
                          percent: 0.45,
                          label: 'Protein',
                          color: AppColors.brandBlue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Personal Records
              AppCard(
                child: Column(
                  children: [
                    const SectionHeader(
                      title: 'Personal Records',
                      icon: Icons.emoji_events_outlined,
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<PersonalRecord>>(
                      future: _personalRecordsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final records = snapshot.data ?? [];

                        if (records.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No records yet. Start logging your workouts!',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            ...records.asMap().entries.map((entry) {
                              final index = entry.key;
                              final record = entry.value;
                              return Column(
                                children: [
                                  _PRTile(
                                    label: record.exerciseName,
                                    value: record.value,
                                    icon: Icons.fitness_center,
                                  ),
                                  if (index < records.length - 1)
                                    const SizedBox(height: 12),
                                ],
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Log Out Button
              PrimaryButton(
                label: 'Log Out',
                leadingIcon: Icons.logout,
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.authGate,
                      (route) => false,
                    );
                  }
                },
                backgroundColor: AppColors.danger.withValues(alpha: 1),
                foregroundColor: AppColors.danger,
                isOutlined: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PRTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PRTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;

  const _SettingsRow({
    required this.label,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        AppToggle(value: value, onChanged: (v) {}),
      ],
    );
  }
}
