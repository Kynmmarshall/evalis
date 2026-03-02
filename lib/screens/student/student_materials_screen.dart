import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/past_material.dart';
import '../../services/resource_service.dart';
import '../../widgets/evalis_app_bar.dart';

class StudentMaterialsScreen extends StatefulWidget {
  const StudentMaterialsScreen({super.key});

  static const routeName = '/student/materials';

  @override
  State<StudentMaterialsScreen> createState() => _StudentMaterialsScreenState();
}

class _StudentMaterialsScreenState extends State<StudentMaterialsScreen> {
  final ResourceService _resourceService = ResourceService.instance;
  List<PastMaterial> _materials = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = _ErrorView(message: _error!, onRetry: _loadMaterials);
    } else {
      body = RefreshIndicator(
        onRefresh: _loadMaterials,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _materials.isEmpty ? 1 : _materials.length,
          itemBuilder: (context, index) {
            if (_materials.isEmpty) {
              return const _EmptyState();
            }
            final material = _materials[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(material.topic, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        children: [
                          Chip(label: Text(material.duration)),
                          Chip(label: Text(material.difficulty)),
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
      appBar: EvalisAppBar(title: context.t(AppText.materialsTitle)),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: body),
    );
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final materials = await _resourceService.fetchPastMaterials();
      if (!mounted) return;
      setState(() => _materials = materials);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          Icon(Icons.menu_book_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            context.t(AppText.materialsSubtitle),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
