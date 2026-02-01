import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/app_role.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  static const routeName = '/auth/register';

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  AppRole _role = AppRole.student;
  String _focusArea = 'Assessment innovation';

  final List<String> _focusAreas = const [
    'Assessment innovation',
    'Learning analytics',
    'Curriculum leadership',
    'Student coaching',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t(AppText.registerTitle))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.t(AppText.registerSubtitle), style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.t(AppText.fullNameLabel),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: context.t(AppText.emailLabel),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            Text(context.t(AppText.roleLabel), style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            SegmentedButton<AppRole>(
              segments: [
                ButtonSegment(value: AppRole.lecturer, label: Text(context.t(AppText.lecturerRole))),
                ButtonSegment(value: AppRole.student, label: Text(context.t(AppText.studentRole))),
              ],
              selected: <AppRole>{_role},
              onSelectionChanged: (value) => setState(() => _role = value.first),
            ),
            const SizedBox(height: 20),
            DropdownMenu<String>(
              initialSelection: _focusArea,
              label: Text(context.t(AppText.focusAreaLabel)),
              dropdownMenuEntries:
                  _focusAreas.map((area) => DropdownMenuEntry<String>(value: area, label: area)).toList(),
              onSelected: (value) {
                if (value == null) return;
                setState(() => _focusArea = value);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleRegistration,
                child: Text(context.t(AppText.registerButton)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(context.t(AppText.haveAccount)),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.t(AppText.goToLogin)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegistration() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.t(AppText.registrationSuccess))));
    Navigator.pop(context);
  }
}
