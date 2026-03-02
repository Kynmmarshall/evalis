import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/course_enrollment.dart';
import '../../services/profile_service.dart';
import '../../widgets/evalis_app_bar.dart';
import '../../widgets/profile_error_view.dart';
import 'student_courses_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  static const routeName = '/student/profile';

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late Future<ProfileSnapshot> _profileFuture;
  final ImagePicker _imagePicker = ImagePicker();
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService.instance.fetchStudentSnapshot();
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = ProfileService.instance.fetchStudentSnapshot();
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
      appBar: EvalisAppBar(title: context.t(AppText.studentProfileTitle)),
      body: FutureBuilder<ProfileSnapshot>(
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
          final approvedCourses = data.byStatus(EnrollmentStatus.approved);
          final pendingCourses = data.byStatus(EnrollmentStatus.pending);
          final profile = data.profile;

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
                    Text(profile.headline, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 12),
                  Text(profile.email, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.t(AppText.studentProfileSubtitle),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          _CourseSection(
            title: context.t(AppText.coursesCardTitle),
            enrollments: approvedCourses,
            statusLabel: context.t(AppText.approvedStatus),
          ),
          const SizedBox(height: 16),
          _CourseSection(
            title: context.t(AppText.coursesPendingTitle),
            enrollments: pendingCourses,
            statusLabel: context.t(AppText.pendingStatus),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, StudentCoursesScreen.routeName),
            icon: const Icon(Icons.playlist_add_check_circle_rounded),
            label: Text(context.t(AppText.availableCoursesTitle)),
          ),
        ],
      ),
    );
          },
        ),
      );
    }
  }
class _CourseSection extends StatelessWidget {
  const _CourseSection({
    required this.title,
    required this.enrollments,
    required this.statusLabel,
  });

  final String title;
  final List<CourseEnrollment> enrollments;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    if (enrollments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...enrollments.map((enrollment) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(enrollment.status == EnrollmentStatus.approved
                          ? Icons.verified_rounded
                          : Icons.hourglass_top_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(enrollment.course.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            Text('${enrollment.course.code} • ${enrollment.course.schedule}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Text(statusLabel, style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

