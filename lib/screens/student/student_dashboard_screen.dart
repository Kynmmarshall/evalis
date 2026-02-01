import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../theme.dart';
import '../../widgets/action_card.dart';
import '../../widgets/evalis_app_bar.dart';
import 'student_exam_screen.dart';
import 'student_feedback_screen.dart';
import 'student_courses_screen.dart';
import 'student_materials_screen.dart';
import 'student_profile_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const routeName = '/student';

  @override
  Widget build(BuildContext context) {
    final cards = [
      ActionCardData(
        title: context.t(AppText.studentTakeExam),
        subtitle: context.t(AppText.studentTakeExamDesc),
        icon: Icons.fact_check_rounded,
        accent: AppTheme.primary,
        onTap: () => Navigator.pushNamed(context, StudentExamScreen.routeName),
      ),
      ActionCardData(
        title: context.t(AppText.studentFeedback),
        subtitle: context.t(AppText.studentFeedbackDesc),
        icon: Icons.bolt_rounded,
        accent: AppTheme.secondary,
        onTap: () => Navigator.pushNamed(context, StudentFeedbackScreen.routeName),
      ),
      ActionCardData(
        title: context.t(AppText.studentMaterials),
        subtitle: context.t(AppText.studentMaterialsDesc),
        icon: Icons.menu_book_rounded,
        accent: AppTheme.accent,
        onTap: () => Navigator.pushNamed(context, StudentMaterialsScreen.routeName),
      ),
      ActionCardData(
        title: context.t(AppText.availableCoursesTitle),
        subtitle: context.t(AppText.pendingApprovalNote),
        icon: Icons.playlist_add_circle,
        accent: Theme.of(context).colorScheme.primary,
        onTap: () => Navigator.pushNamed(context, StudentCoursesScreen.routeName),
      ),
      ActionCardData(
        title: context.t(AppText.studentProfileTitle),
        subtitle: context.t(AppText.studentProfileSubtitle),
        icon: Icons.account_circle_rounded,
        accent: Theme.of(context).colorScheme.secondary,
        onTap: () => Navigator.pushNamed(context, StudentProfileScreen.routeName),
      ),
    ];

    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.studentDashboardTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.t(AppText.studentDashboardSubtitle),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ...cards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ActionCard(data: card),
              )),
        ],
      ),
    );
  }
}
