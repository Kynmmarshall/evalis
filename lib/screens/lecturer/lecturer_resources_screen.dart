import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/learning_resource.dart';
import '../../services/resource_service.dart';
import '../../widgets/evalis_app_bar.dart';

class LecturerResourcesScreen extends StatefulWidget {
  const LecturerResourcesScreen({super.key});

  static const routeName = '/lecturer/resources';

  @override
  State<LecturerResourcesScreen> createState() => _LecturerResourcesScreenState();
}

class _LecturerResourcesScreenState extends State<LecturerResourcesScreen> {
  final ResourceService _resourceService = ResourceService.instance;
  List<LearningResource> _resources = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = _ErrorView(message: _error!, onRetry: _loadResources);
    } else {
      body = RefreshIndicator(
        onRefresh: _loadResources,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _resources.isEmpty ? 1 : _resources.length,
          itemBuilder: (context, index) {
            if (_resources.isEmpty) {
              return _EmptyState();
            }
            final resource = _resources[index];
            final accent = Theme.of(context).colorScheme.secondary;
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
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.folder_open_rounded, color: accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(resource.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600)),
                                Text(resource.description,
                                    style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        children: [
                          Chip(label: Text(resource.format)),
                          Chip(label: Text(resource.eta)),
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

    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.resourcesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add_circle_outline),
        label: Text(context.t(AppText.addResource)),
      ),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: body),
    );
  }

  Future<void> _loadResources() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final resources = await _resourceService.fetchResources();
      if (!mounted) return;
      setState(() => _resources = resources);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openAddDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formatController = TextEditingController();
    final etaController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    bool isSubmitting = false;

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(context.t(AppText.addResource)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DialogField(controller: titleController, label: context.t(AppText.resourceTitleLabel)),
                    _DialogField(controller: descriptionController, label: context.t(AppText.resourceDescriptionLabel)),
                    _DialogField(controller: formatController, label: context.t(AppText.resourceFormatLabel)),
                    _DialogField(controller: etaController, label: context.t(AppText.resourceEtaLabel)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final values = [
                            titleController.text.trim(),
                            descriptionController.text.trim(),
                            formatController.text.trim(),
                            etaController.text.trim(),
                          ];
                          if (values.any((value) => value.isEmpty)) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(context.t(AppText.formFieldRequired))),
                            );
                            return;
                          }
                          setDialogState(() => isSubmitting = true);
                          try {
                            await _resourceService.addResource(
                              title: values[0],
                              description: values[1],
                              format: values[2],
                              eta: values[3],
                            );
                            if (!context.mounted) return;
                            Navigator.of(dialogContext).pop(true);
                          } catch (error) {
                            setDialogState(() => isSubmitting = false);
                            messenger.showSnackBar(SnackBar(content: Text(error.toString())));
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.t(AppText.addResource)),
                ),
              ],
            );
          },
        );
      },
    );

    if (added == true) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(context.t(AppText.addedResource))));
      await _loadResources();
    }
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            context.t(AppText.resourcesSubtitle),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
