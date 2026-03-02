import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/enrollment_request.dart';
import '../../services/enrollment_service.dart';
import '../../widgets/evalis_app_bar.dart';

class LecturerApprovalsScreen extends StatefulWidget {
  const LecturerApprovalsScreen({super.key});

  static const routeName = '/lecturer/approvals';

  @override
  State<LecturerApprovalsScreen> createState() => _LecturerApprovalsScreenState();
}

class _LecturerApprovalsScreenState extends State<LecturerApprovalsScreen> {
  final EnrollmentService _service = EnrollmentService.instance;
  late Future<List<EnrollmentRequest>> _pendingFuture;

  @override
  void initState() {
    super.initState();
    _pendingFuture = _service.fetchPendingApprovals();
  }

  Future<void> _refresh() async {
    setState(() {
      _pendingFuture = _service.fetchPendingApprovals();
    });
    await _pendingFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.approvalsTitle)),
      body: FutureBuilder<List<EnrollmentRequest>>(
        future: _pendingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(onRetry: _refresh, message: snapshot.error.toString());
          }
          final requests = snapshot.data ?? const [];
          if (requests.isEmpty) {
            return _EmptyState(onRefresh: _refresh);
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: requests.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      context.t(AppText.approvalsSubtitle),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }
                final request = requests[index - 1];
                return _RequestCard(
                  request: request,
                  onApprove: () => _handleAction(() => _service.approveRequest(request), AppText.approvedStatus),
                  onReject: () => _handleAction(() => _service.rejectRequest(request), AppText.pendingStatus),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleAction(
    Future<void> Function() action,
    AppText feedback,
  ) async {
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t(feedback))));
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onApprove, required this.onReject});

  final EnrollmentRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                        Text(
                          request.studentName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
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
                      onPressed: onApprove,
                      child: Text(context.t(AppText.approveButton)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
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
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry, required this.message});

  final Future<void> Function() onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                onRetry();
              },
              child: Text(context.t(AppText.retryAction)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            context.t(AppText.noPendingRequests),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
