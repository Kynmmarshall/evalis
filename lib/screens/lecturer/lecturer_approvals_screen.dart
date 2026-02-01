import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../data/mock_data.dart';
import '../../l10n/app_texts.dart';
import '../../services/enrollment_service.dart';
import '../../widgets/evalis_app_bar.dart';

class LecturerApprovalsScreen extends StatelessWidget {
  LecturerApprovalsScreen({super.key});

  static const routeName = '/lecturer/approvals';

  final EnrollmentService _service = EnrollmentService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.approvalsTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: pendingApprovals.length,
        itemBuilder: (context, index) {
          final request = pendingApprovals[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.person_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(request.studentName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              Text(request.submittedOn, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('${request.course.code} • ${request.course.title}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Text(request.course.schedule, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _handleAction(
                              context,
                              () => _service.approveRequest(request),
                              AppText.approvedStatus,
                            ),
                            child: Text(context.t(AppText.approveButton)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleAction(
                              context,
                              () => _service.rejectRequest(request),
                              AppText.pendingStatus,
                            ),
                            child: Text(context.t(AppText.rejectButton)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    Future<void> Function() action,
    AppText feedback,
  ) async {
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t(feedback))));
  }
}
