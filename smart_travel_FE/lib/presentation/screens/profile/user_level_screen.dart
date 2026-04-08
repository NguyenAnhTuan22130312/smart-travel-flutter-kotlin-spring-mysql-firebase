import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/l10n/app_localizations.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_event.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_state.dart';
import 'package:smart_travel/presentation/widgets/profile/level_progress_widget.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

import '../../../domain/entities/user.dart';

class UserLevelScreen extends StatefulWidget {
  const UserLevelScreen({super.key});

  @override
  State<UserLevelScreen> createState() => _UserLevelScreenState();
}

class _UserLevelScreenState extends State<UserLevelScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadLevel());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userLevelTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) {
          // Rebuild when state changes OR always rebuild (to pick up theme changes)
          return true;
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/travel_is_fun.json',
                width: 200,
                height: 500,
                repeat: true,
              ),
            );
          }

          if (state is LevelLoaded) {
            final level = state.level;

            return _buildLevelContent(context, level);
          }

          // Error or initial state
          return _buildErrorState(context);
        },
      ),
    );
  }

  Widget _buildLevelContent(BuildContext context, UserLevel level) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Progress Card
          LevelProgressWidget(
            currentLevel: level.currentLevel,
            experiencePoints: level.experiencePoints,
            nextLevelAt: level.nextLevelAt,
            progressPercentage: level.progressPercentage,
          ),

          const SizedBox(height: 24),

          // Level Benefits Section
          Text(
            AppLocalizations.of(context)!.levelBenefitsTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildBenefitCard(
            context: context,
            icon: Icons.diamond,
            title: AppLocalizations.of(context)!.levelDiamond,
            color: const Color(0xFFB9F2FF),
            benefits: [
              AppLocalizations.of(context)!.benefitDiscount15,
              AppLocalizations.of(context)!.benefitPrioritySupport247,
              AppLocalizations.of(context)!.benefitFreeRoomUpgrade,
              AppLocalizations.of(context)!.benefitLateCheckoutFree,
              AppLocalizations.of(context)!.benefitTriplePoints,
            ],
            requirement: AppLocalizations.of(context)!.requirementDiamond,
          ),

          const SizedBox(height: 12),

          _buildBenefitCard(
            context: context,
            icon: Icons.workspace_premium,
            title: AppLocalizations.of(context)!.levelGold,
            color: const Color(0xFFFFD700),
            benefits: [
              AppLocalizations.of(context)!.benefitDiscount10,
              AppLocalizations.of(context)!.benefitPrioritySupport,
              AppLocalizations.of(context)!.benefitDoublePoints,
              AppLocalizations.of(context)!.benefitEarlyCheckinFree,
            ],
            requirement: AppLocalizations.of(context)!.requirementGold,
          ),

          const SizedBox(height: 12),

          _buildBenefitCard(
            context: context,
            icon: Icons.stars,
            title: AppLocalizations.of(context)!.levelSilver,
            color: const Color(0xFFC0C0C0),
            benefits: [
              AppLocalizations.of(context)!.benefitDiscount5,
              AppLocalizations.of(context)!.benefitOnePointFiveTimes,
              AppLocalizations.of(context)!.benefitSeasonalOffers,
            ],
            requirement: AppLocalizations.of(context)!.requirementSilver,
          ),

          const SizedBox(height: 12),

          _buildBenefitCard(
            context: context,
            icon: Icons.emoji_events,
            title: AppLocalizations.of(context)!.levelBronze,
            color: const Color(0xFFCD7F32),
            benefits: [
              AppLocalizations.of(context)!.benefitEarnPointsEachBooking,
              AppLocalizations.of(context)!.benefitReceiveSpecialDeals,
              AppLocalizations.of(context)!.benefitPromoUpdates,
            ],
            requirement: AppLocalizations.of(context)!.requirementBronze,
          ),

          const SizedBox(height: 24),

          // How to earn XP
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.earnXpTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildEarnXPItem(
                  AppLocalizations.of(context)!.earnXpBookingHotel,
                ),
                _buildEarnXPItem(
                  AppLocalizations.of(context)!.earnXpWriteReview,
                ),
                _buildEarnXPItem(
                  AppLocalizations.of(context)!.earnXpCompleteProfile,
                ),
                _buildEarnXPItem(
                  AppLocalizations.of(context)!.earnXpReferFriends,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.errorLoadLevel,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(LoadLevel());
            },
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required List<String> benefits,
    required String requirement,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      requirement,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(benefit, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnXPItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
