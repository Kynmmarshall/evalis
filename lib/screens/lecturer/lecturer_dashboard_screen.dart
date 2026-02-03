import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../theme.dart';
import '../../widgets/action_card.dart';
import '../../widgets/evalis_app_bar.dart';
import '../../widgets/resource_spotlight.dart';
import '../lecturer/lecturer_approvals_screen.dart';
import '../lecturer/lecturer_exam_manager_screen.dart';
import '../lecturer/lecturer_profile_screen.dart';
import '../lecturer/lecturer_resources_screen.dart';
import '../lecturer/lecturer_results_screen.dart';

class LecturerDashboardScreen extends StatelessWidget {
  const LecturerDashboardScreen({super.key});

  static const routeName = '/lecturer';

  @override
  Widget build(BuildContext context) {
    final cards = [
      ActionCardData(
        title: context.t(AppText.lecturerCardCreate),
        subtitle: context.t(AppText.lecturerCardCreateDesc),
        icon: Icons.library_books,
        accent: AppTheme.primary,
        onTap: () => Navigator.pushNamed(context, LecturerExamManagerScreen.routeName),
      ),
      ActionCardData(
        title: context.t(AppText.lecturerCardResults),
        subtitle: context.t(AppText.lecturerCardResultsDesc),
        icon: Icons.assessment_rounded,
        accent: AppTheme.secondary,
        onTap: () => Navigator.pushNamed(context, LecturerResultsScreen.routeName),
      ),
      ActionCardData(
        title: context.t(AppText.lecturerCardResources),
        subtitle: context.t(AppText.lecturerCardResourcesDesc),
        icon: Icons.auto_stories_rounded,
        accent: AppTheme.accent,
        onTap: () => Navigator.pushNamed(context, LecturerResourcesScreen.routeName),
      ),
      ActionCardData(
        title: context.t(AppText.lecturerProfileTitle),
        subtitle: context.t(AppText.lecturerProfileSubtitle),
        icon: Icons.account_circle_rounded,
        accent: Theme.of(context).colorScheme.primary,
        onTap: () => Navigator.pushNamed(context, LecturerProfileScreen.routeName),
      ),
      ActionCardData(
        title: context.t(AppText.approvalsTitle),
        subtitle: context.t(AppText.approvalsSubtitle),
        icon: Icons.verified_user_rounded,
        accent: Theme.of(context).colorScheme.secondary,
        onTap: () => Navigator.pushNamed(context, LecturerApprovalsScreen.routeName),
      ),
    ];

    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.lecturerDashboardTitle), showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.t(AppText.lecturerDashboardSubtitle),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(context.t(AppText.quickActions),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...cards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ActionCard(data: card),
              )),
          const SizedBox(height: 8),
          Text(
            context.t(AppText.learningVault),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const ResourceSpotlight(),
        ],
      ),
    );
  }
}
