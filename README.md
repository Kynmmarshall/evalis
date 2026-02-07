# Evalis

> Multi-role assessment orchestration for lecturers and students, built with Flutter.

Evalis is a cross-platform prototype that helps teaching teams design inclusive assessments while giving students a focused practice, feedback, and enrollment hub. The app currently targets Flutter 3.19+ (Dart 3.9) and runs on mobile, desktop, and web from a single codebase.

## Highlights

- **Role-aware onboarding:** Dedicated lecturer/student flows with guest access and quick toggles for language and theme in [lib/screens/auth/login_screen.dart](lib/screens/auth/login_screen.dart) and [lib/screens/auth/registration_screen.dart](lib/screens/auth/registration_screen.dart).
- **Student practice loop:** Dashboards, mock exams, remediation materials, enrollment tracking, and feedback review live under [lib/screens/student](lib/screens/student) with curated data from [lib/data/mock_data.dart](lib/data/mock_data.dart).
- **Lecturer control room:** Exam builders, approvals, analytics-ready exports, and a teaching resource vault ship from [lib/screens/lecturer](lib/screens/lecturer).
- **Built-in localization & theming:** `AppSettings` + `L10n` toggle languages and light/dark palettes globally via [lib/app_settings.dart](lib/app_settings.dart) and [lib/l10n/app_texts.dart](lib/l10n/app_texts.dart).
- **Composable UI kit:** Shared widgets (`EvalisAppBar`, `ActionCard`, `ResourceSpotlight`, toggles) reduce layout drift and keep screens focused on pedagogy.

## Product Tour

### Student Journey

- **Mission control:** The dashboard in [lib/screens/student/student_dashboard_screen.dart](lib/screens/student/student_dashboard_screen.dart) surfaces the main actions (exams, feedback, materials, enrollments, profile).
- **Smart exam sandbox:** [lib/screens/student/student_exam_screen.dart](lib/screens/student/student_exam_screen.dart) locks responses per question, nudges with contextual tips, and bridges to the feedback screen for remediation.
- **Learning vault:** Materials, past drills, and difficulty tags render via [lib/screens/student/student_materials_screen.dart](lib/screens/student/student_materials_screen.dart), while ongoing enrollments and requests are handled in [lib/screens/student/student_courses_screen.dart](lib/screens/student/student_courses_screen.dart).
- **Progress evidence:** Students review answer rationales inside [lib/screens/student/student_feedback_screen.dart](lib/screens/student/student_feedback_screen.dart) and keep their profile plus course badges current through [lib/screens/student/student_profile_screen.dart](lib/screens/student/student_profile_screen.dart).

### Lecturer Workspace

- **Quick actions:** [lib/screens/lecturer/lecturer_dashboard_screen.dart](lib/screens/lecturer/lecturer_dashboard_screen.dart) aggregates exam creation, analytics, resources, approvals, and profile management.
- **Exam lifecycle:** Configure sittings, add MCQs, and manage drafts with [lib/screens/lecturer/lecturer_exam_manager_screen.dart](lib/screens/lecturer/lecturer_exam_manager_screen.dart) and the builder at [lib/screens/lecturer/lecturer_create_mcq_screen.dart](lib/screens/lecturer/lecturer_create_mcq_screen.dart).
- **Evidence & exports:** Scoreboards plus PDF generation hooks live inside [lib/screens/lecturer/lecturer_results_screen.dart](lib/screens/lecturer/lecturer_results_screen.dart) backed by [lib/services/pdf_export_service.dart](lib/services/pdf_export_service.dart).
- **Enrollment governance:** Approve or reject student requests through [lib/screens/lecturer/lecturer_approvals_screen.dart](lib/screens/lecturer/lecturer_approvals_screen.dart) using the async flows defined in [lib/services/enrollment_service.dart](lib/services/enrollment_service.dart).
- **Resource vault:** Curate teaching assets and future integrations via [lib/screens/lecturer/lecturer_resources_screen.dart](lib/screens/lecturer/lecturer_resources_screen.dart) and [lib/services/resource_service.dart](lib/services/resource_service.dart).

## Architecture & Design

- **Entry point:** [lib/main.dart](lib/main.dart) wires `AppSettingsScope`, localization, and the dynamic router (`AppRouter.onGenerateRoute`).
- **Settings model:** [lib/app_settings.dart](lib/app_settings.dart) (InheritedNotifier) centralizes theme/language state and is consumed everywhere through `context.settings`.
- **Routing:** [lib/routing/app_router.dart](lib/routing/app_router.dart) (not shown above) maps semantic route names (`/student`, `/lecturer/exams`, etc.) to screens for predictable navigation.
- **Theming:** Dual palettes and hero gradients are declared in [lib/theme.dart](lib/theme.dart), keeping typography and color tokens consistent.
- **Copy deck:** All user strings flow through [lib/l10n/app_texts.dart](lib/l10n/app_texts.dart) so future translations only require updating that file and the localization delegates.

## Data & Services

- Mock domain objects for courses, enrollments, exams, resources, and user profiles sit in [lib/data/mock_data.dart](lib/data/mock_data.dart). Swap this file with live providers when wiring a backend.
- Lightweight async services represent integration seams:
	- Enrollment actions → [lib/services/enrollment_service.dart](lib/services/enrollment_service.dart)
	- PDF exports → [lib/services/pdf_export_service.dart](lib/services/pdf_export_service.dart)
	- Resource publishing → [lib/services/resource_service.dart](lib/services/resource_service.dart)

## Getting Started

### Prerequisites

- Flutter 3.19+ (which bundles Dart 3.9)
- Xcode / Android Studio tooling for native builds (optional but recommended)

### Setup

1. Clone the repo and move into the project folder.
2. Fetch packages:
	 ```bash
	 flutter pub get
	 ```
3. Launch a device or simulator, then run:
	 ```bash
	 flutter run -d <device-id>
	 ```

### Helpful Commands

- Format: `dart format lib test`
- Static analysis: `flutter analyze`
- Unit/widget tests: `flutter test`
- Clean derived artifacts if builds misbehave: `flutter clean && flutter pub get`

## Project Structure (excerpt)

```
lib/
	app_settings.dart        # Global theme/language controller
	data/mock_data.dart      # Mock domain objects powering the prototype
	l10n/app_texts.dart      # Centralized copy + localization helpers
	routing/app_router.dart  # Named-route factory
	screens/
		auth/                  # Login & registration flows
		landing/               # Marketing/CTA hero
		startup/               # Splash + boot logic
		student/               # Student dashboards, exams, materials, profile
		lecturer/              # Lecturer dashboards, approvals, resources, analytics
	services/                # Enrollment, PDF export, resource actions
	widgets/                 # Shared UI components (ActionCard, toggles, AppBar)
```

## Localization, Theming & Accessibility

- All screens consume translated strings via `context.t(AppText.*)` so adding a locale is as simple as expanding [lib/l10n/app_texts.dart](lib/l10n/app_texts.dart).
- Theme switching is instant because `AppSettings` notifies the entire widget tree; extend `AppTheme` to add branded palettes or typography.
- Components favor large tap targets, high-contrast gradients, and Material 3 widgets for baseline accessibility across devices.

## Roadmap

1. Replace mock services with real API clients and persistence.
2. Add authentication and secure storage for lecturer/student accounts.
3. Wire exam analytics, item statistics, and remediation notifications.
4. Expand localization coverage and integrate Flutter's `gen-l10n` pipeline.
5. Automate CI (format, analyze, test) via GitHub Actions for every PR.
