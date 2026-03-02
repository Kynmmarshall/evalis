import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../services/profile_service.dart';
import '../../widgets/evalis_app_bar.dart';
import '../../widgets/profile_error_view.dart';
import '../lecturer/lecturer_approvals_screen.dart';

class LecturerProfileScreen extends StatefulWidget {
  const LecturerProfileScreen({super.key});

  static const routeName = '/lecturer/profile';

  @override
  State<LecturerProfileScreen> createState() => _LecturerProfileScreenState();
}

class _LecturerProfileScreenState extends State<LecturerProfileScreen> {
  late Future<LecturerProfileSnapshot> _profileFuture;
  final ImagePicker _imagePicker = ImagePicker();
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService.instance.fetchLecturerSnapshot();
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = ProfileService.instance.fetchLecturerSnapshot();
    });
    await _profileFuture;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAvatarUpload() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) {
      return;
    }

    setState(() => _uploadingAvatar = true);

    try {
      final bytes = await pickedFile.readAsBytes();
      final mimeType = lookupMimeType(pickedFile.name, headerBytes: bytes);
      await ProfileService.instance.uploadAvatar(bytes: bytes, contentType: mimeType);
      if (!mounted) return;
      await _refresh();
      if (!mounted) return;
      _showSnack(context.t(AppText.profilePhotoSuccess));
    } catch (error) {
      if (!mounted) return;
      _showSnack(context.t(AppText.profilePhotoFailure));
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.lecturerProfileTitle)),
      body: FutureBuilder<LecturerProfileSnapshot>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ProfileErrorView(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = snapshot.requireData;
          final profile = data.profile;
          final courses = data.courses;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: profile.avatarUrl == null
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : null,
                    backgroundImage:
                        profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                    child: profile.avatarUrl == null
                        ? const Icon(Icons.photo_camera_front_outlined, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t(AppText.profilePhotoTitle),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.t(AppText.profilePhotoSubtitle),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: _uploadingAvatar ? null : _handleAvatarUpload,
                          icon: _uploadingAvatar
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.2),
                                )
                              : const Icon(Icons.upload_rounded),
                          label: Text(context.t(AppText.profilePhotoButton)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(profile.roleLabel, style: Theme.of(context).textTheme.bodyMedium),
                  if (profile.headline.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: colorScheme.secondary.withValues(alpha: 0.18),
                          child: const Icon(Icons.person_outline_rounded),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            profile.headline,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(profile.email, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.t(AppText.profileQuickStats),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.t(AppText.coursesCardTitle),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (courses.isEmpty)
                    Text(
                      context.t(AppText.pendingApprovalNote),
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...courses.map(
                      (course) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(Icons.class_rounded, color: colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(course.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(fontWeight: FontWeight.w600)),
                                  Text('${course.code} • ${course.schedule}',
                                      style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, LecturerApprovalsScreen.routeName),
                    icon: const Icon(Icons.verified_user_rounded),
                    label: Text(context.t(AppText.approvalsTitle)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(context.t(AppText.pendingApprovalNote)),
            ),
          ),
        ],
      ),
    );
          },
        ),
      );
    }
  }
