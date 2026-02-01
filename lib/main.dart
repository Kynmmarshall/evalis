import 'package:flutter/material.dart';

import 'theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AppSettings _settings = AppSettings();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: _settings,
      child: AnimatedBuilder(
        animation: _settings,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: L10n.text(_settings.language, AppText.appTitle),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _settings.themeMode,
            initialRoute: LandingScreen.routeName,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case LandingScreen.routeName:
        page = const LandingScreen();
        break;
      case LecturerDashboardScreen.routeName:
        page = const LecturerDashboardScreen();
        break;
      case LecturerCreateMcqScreen.routeName:
        page = const LecturerCreateMcqScreen();
        break;
      case LecturerResultsScreen.routeName:
        page = const LecturerResultsScreen();
        break;
      case LecturerResourcesScreen.routeName:
        page = const LecturerResourcesScreen();
        break;
      case StudentDashboardScreen.routeName:
        page = const StudentDashboardScreen();
        break;
      case StudentExamScreen.routeName:
        page = const StudentExamScreen();
        break;
      case StudentFeedbackScreen.routeName:
        page = const StudentFeedbackScreen();
        break;
      case StudentMaterialsScreen.routeName:
        page = const StudentMaterialsScreen();
        break;
      default:
        page = const LandingScreen();
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}

enum AppLanguage { english, french }

enum AppText {
  appTitle,
  heroTitle,
  heroSubtitle,
  lecturerCta,
  studentCta,
  lecturerDashboardTitle,
  lecturerDashboardSubtitle,
  lecturerCardCreate,
  lecturerCardCreateDesc,
  lecturerCardResults,
  lecturerCardResultsDesc,
  lecturerCardResources,
  lecturerCardResourcesDesc,
  createMcqTitle,
  createMcqSubtitle,
  questionFieldLabel,
  answerOptionLabel,
  correctAnswerLabel,
  explanationLabel,
  previewButton,
  publishButton,
  publishSnack,
  resultsTitle,
  resultsSubtitle,
  resultsListTitle,
  generatePdf,
  pdfSuccess,
  resourcesTitle,
  resourcesSubtitle,
  addResource,
  addedResource,
  studentDashboardTitle,
  studentDashboardSubtitle,
  studentTakeExam,
  studentTakeExamDesc,
  studentFeedback,
  studentFeedbackDesc,
  studentMaterials,
  studentMaterialsDesc,
  examTitle,
  examSubtitle,
  examLockedHint,
  resumeExam,
  viewFeedback,
  viewMaterials,
  feedbackTitle,
  feedbackSubtitle,
  feedbackSnack,
  materialsTitle,
  materialsSubtitle,
  responseLocked,
  responseCorrect,
  responseIncorrect,
  themeToggle,
  languageLabel,
  prototypeMessage,
  pdfReady,
  pdfPending,
  quickActions,
  learningVault,
}

class L10n {
  static final Map<AppLanguage, Map<AppText, String>> _localized = {
    AppLanguage.english: {
      AppText.appTitle: 'Evalis Classroom',
      AppText.heroTitle: 'Design assessments that inspire learning',
      AppText.heroSubtitle:
          'Lecturers build bilingual MCQs, students respond once, receive instant insights, and revisit curated practice vaults.',
      AppText.lecturerCta: 'Lecturer workspace',
      AppText.studentCta: 'Student space',
      AppText.lecturerDashboardTitle: 'Lecturer cockpit',
      AppText.lecturerDashboardSubtitle:
          'Launch quick actions to craft MCQs, monitor live submissions, and circulate reinforcement exercises.',
      AppText.lecturerCardCreate: 'Build MCQ banks',
      AppText.lecturerCardCreateDesc: 'Structure stems, distractors, and correct keys with clarity.',
      AppText.lecturerCardResults: 'Instant scorebooks',
      AppText.lecturerCardResultsDesc: 'Compile sign-in rosters and export polished PDF briefings.',
      AppText.lecturerCardResources: 'Learning capsules',
      AppText.lecturerCardResourcesDesc: 'Share past exams, drills, and remedial prompts in seconds.',
      AppText.createMcqTitle: 'Compose MCQs',
      AppText.createMcqSubtitle:
          'Capture question intent, generate four distractors, and highlight the right insight per item.',
      AppText.questionFieldLabel: 'Question prompt',
      AppText.answerOptionLabel: 'Choice',
      AppText.correctAnswerLabel: 'Correct choice',
      AppText.explanationLabel: 'Coaching note (optional)',
      AppText.previewButton: 'Preview flow',
      AppText.publishButton: 'Publish to exam room',
      AppText.publishSnack: 'Prototype save complete. Content staged for review.',
      AppText.resultsTitle: 'Exam summaries',
      AppText.resultsSubtitle:
          'Monitor completion, lock answers, then export official transcripts for your cohort.',
      AppText.resultsListTitle: 'Recent cohorts',
      AppText.generatePdf: 'Generate PDF summary',
      AppText.pdfSuccess: 'A polished PDF will be mailed to your inbox shortly.',
      AppText.resourcesTitle: 'Learning resources',
      AppText.resourcesSubtitle: 'Drop curated drills or inspirational practice into the student vault.',
      AppText.addResource: 'Add learning capsule',
      AppText.addedResource: 'Resource pinned for students. Keep iterating!',
      AppText.studentDashboardTitle: 'Student launchpad',
      AppText.studentDashboardSubtitle:
          'Attempt graded sets once, see verdicts instantly, and revisit teacher-sent practice.',
      AppText.studentTakeExam: 'Take scheduled exam',
      AppText.studentTakeExamDesc: 'Respond in one sitting. Each choice locks automatically.',
      AppText.studentFeedback: 'Feedback pulse',
      AppText.studentFeedbackDesc: 'Review verdicts, rationales, and high-impact tips.',
      AppText.studentMaterials: 'Past questions hub',
      AppText.studentMaterialsDesc: 'Download capsules shared by your lecturers for extra drills.',
      AppText.examTitle: 'Prototype exam room',
      AppText.examSubtitle: 'Respond once per item. Feedback appears right after you lock a choice.',
      AppText.examLockedHint: 'Selections cannot be edited once saved. Focus before tapping.',
      AppText.resumeExam: 'Finish review',
      AppText.viewFeedback: 'View feedback summary',
      AppText.viewMaterials: 'Open past materials',
      AppText.feedbackTitle: 'Feedback timeline',
      AppText.feedbackSubtitle: 'Snapshots of your latest submissions and auto-coaching.',
      AppText.feedbackSnack: 'Feedback shared for exploration mode.',
      AppText.materialsTitle: 'Practice library',
      AppText.materialsSubtitle: 'Slides, case studies, and rapid-fire drills curated for you.',
      AppText.responseLocked: 'Response locked in',
      AppText.responseCorrect: 'Nice! That was the right call.',
      AppText.responseIncorrect: 'Keep at it. Review the insight shared below.',
      AppText.themeToggle: 'Toggle color mode',
      AppText.languageLabel: 'Switch language',
      AppText.prototypeMessage: 'Interactive prototype only. Full workflow coming soon.',
      AppText.pdfReady: 'PDF sent',
      AppText.pdfPending: 'Awaiting export',
      AppText.quickActions: 'Quick actions',
      AppText.learningVault: 'Learning vault',
    },
    AppLanguage.french: {
      AppText.appTitle: 'Evalis Classroom',
      AppText.heroTitle: 'Concevez des évaluations qui motivent',
      AppText.heroSubtitle:
          'Les enseignants créent des QCM bilingues, les étudiants répondent une seule fois, reçoivent un retour immédiat et révisent grâce aux ressources partagées.',
      AppText.lecturerCta: 'Espace enseignant',
      AppText.studentCta: 'Espace étudiant',
      AppText.lecturerDashboardTitle: 'Cockpit enseignant',
      AppText.lecturerDashboardSubtitle:
          'Accédez rapidement à la création des QCM, au suivi des copies et à l’envoi des exercices.',
      AppText.lecturerCardCreate: 'Créer des banques QCM',
      AppText.lecturerCardCreateDesc:
          'Structurez l’énoncé, les distracteurs et la bonne réponse avec clarté.',
      AppText.lecturerCardResults: 'Bulletins instantanés',
      AppText.lecturerCardResultsDesc:
          'Compilez les listes, verrouillez les notes et exportez des PDF élégants.',
      AppText.lecturerCardResources: 'Capsules pédagogiques',
      AppText.lecturerCardResourcesDesc:
          'Partagez anciens sujets, entraînements et remédiations en un geste.',
      AppText.createMcqTitle: 'Composer des QCM',
      AppText.createMcqSubtitle:
          'Rédigez la question, proposez quatre choix et précisez l’explication clé.',
      AppText.questionFieldLabel: 'Énoncé de la question',
      AppText.answerOptionLabel: 'Choix',
      AppText.correctAnswerLabel: 'Bonne réponse',
      AppText.explanationLabel: 'Note pédagogique (optionnel)',
      AppText.previewButton: 'Prévisualiser',
      AppText.publishButton: 'Publier dans la salle d’examen',
      AppText.publishSnack: 'Prototype enregistré. Révision possible ultérieurement.',
      AppText.resultsTitle: 'Synthèses d’examen',
      AppText.resultsSubtitle:
          'Suivez la complétion, verrouillez les réponses puis exportez les relevés officiels.',
      AppText.resultsListTitle: 'Dernières cohortes',
      AppText.generatePdf: 'Générer un PDF',
      AppText.pdfSuccess:
          'Un PDF finalisé sera envoyé à votre boîte mail dans un instant.',
      AppText.resourcesTitle: 'Ressources pédagogiques',
      AppText.resourcesSubtitle:
          'Ajoutez des entraînements ciblés dans l’espace de révision des étudiants.',
      AppText.addResource: 'Ajouter une capsule',
      AppText.addedResource: 'Ressource partagée. Continuez à alimenter la bibliothèque.',
      AppText.studentDashboardTitle: 'Plateforme étudiant',
      AppText.studentDashboardSubtitle:
          'Passez les épreuves une seule fois, découvrez le verdict immédiatement, puis révisez.',
      AppText.studentTakeExam: 'Passer l’examen planifié',
      AppText.studentTakeExamDesc:
          'Répondez en une séance. Chaque choix se verrouille automatiquement.',
      AppText.studentFeedback: 'Retour express',
      AppText.studentFeedbackDesc:
          'Analysez vos réponses, les raisons et les pistes d’amélioration.',
      AppText.studentMaterials: 'Banque d’anciens sujets',
      AppText.studentMaterialsDesc:
          'Téléchargez les capsules publiées par vos enseignants.',
      AppText.examTitle: 'Salle d’examen prototype',
      AppText.examSubtitle:
          'Une réponse par question. Le retour s’affiche juste après la sélection.',
      AppText.examLockedHint:
          'Impossible de modifier un choix validé. Concentrez-vous avant de valider.',
      AppText.resumeExam: 'Terminer et relire',
      AppText.viewFeedback: 'Voir le récapitulatif',
      AppText.viewMaterials: 'Voir les ressources',
      AppText.feedbackTitle: 'Historique des retours',
      AppText.feedbackSubtitle:
          'Vos dernières copies avec verdicts automatiques et conseils ciblés.',
      AppText.feedbackSnack: 'Retour partagé pour la version démo.',
      AppText.materialsTitle: 'Bibliothèque pratique',
      AppText.materialsSubtitle:
          'Diapositives, études de cas et exercices rapides conseillés.',
      AppText.responseLocked: 'Réponse verrouillée',
      AppText.responseCorrect: 'Bravo ! C’était la bonne option.',
      AppText.responseIncorrect:
          'Encore un effort. Lisez l’explication fournie ci-dessous.',
      AppText.themeToggle: 'Changer de mode de couleur',
      AppText.languageLabel: 'Changer de langue',
      AppText.prototypeMessage: 'Prototype interactif. Parcours complet à venir.',
      AppText.pdfReady: 'PDF envoyé',
      AppText.pdfPending: 'Export en attente',
      AppText.quickActions: 'Actions rapides',
      AppText.learningVault: 'Coffre pédagogique',
    },
  };

  static String text(AppLanguage language, AppText key) {
    return _localized[language]![key]!;
  }

  static String languageName(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.french:
        return 'Français';
    }
  }
}

class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  AppLanguage _language = AppLanguage.english;

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({required AppSettings settings, required Widget child, super.key})
      : super(notifier: settings, child: child);

  static AppSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope not found in context');
    return scope!.notifier!;
  }
}

extension EvalisContext on BuildContext {
  AppSettings get settings => AppSettingsScope.of(this);
  String t(AppText key) => L10n.text(settings.language, key);
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.settings.themeMode == ThemeMode.dark;
    return IconButton(
      tooltip: context.t(AppText.themeToggle),
      icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
      onPressed: context.settings.toggleTheme,
    );
  }
}

class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppLanguage>(
      tooltip: context.t(AppText.languageLabel),
      icon: const Icon(Icons.language),
      initialValue: context.settings.language,
      onSelected: context.settings.setLanguage,
      itemBuilder: (ctx) => AppLanguage.values
          .map(
            (language) => PopupMenuItem<AppLanguage>(
              value: language,
              child: Text(L10n.languageName(language)),
            ),
          )
          .toList(),
    );
  }
}

class EvalisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EvalisAppBar({required this.title, this.showBack = true, super.key});

  final String title;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      actions: const [ThemeToggleButton(), LanguageMenuButton()],
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [ThemeToggleButton(), SizedBox(width: 8), LanguageMenuButton()],
                ),
                const Spacer(),
                Text(
                  context.t(AppText.heroTitle),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(
                  context.t(AppText.heroSubtitle),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white.withOpacity(0.88)),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit_note_rounded),
                      label: Text(context.t(AppText.lecturerCta)),
                      onPressed: () => Navigator.pushNamed(context, LecturerDashboardScreen.routeName),
                    ),
                    FilledButton.icon(
                      icon: const Icon(Icons.school_rounded),
                      label: Text(context.t(AppText.studentCta)),
                      onPressed: () => Navigator.pushNamed(context, StudentDashboardScreen.routeName),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.t(AppText.prototypeMessage),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.arrow_downward_rounded, color: colorScheme.secondary.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LecturerDashboardScreen extends StatelessWidget {
  const LecturerDashboardScreen({super.key});

  static const routeName = '/lecturer';

  @override
  Widget build(BuildContext context) {
    final cards = [
      _DashboardCardData(
        title: context.t(AppText.lecturerCardCreate),
        subtitle: context.t(AppText.lecturerCardCreateDesc),
        icon: Icons.library_books,
        accent: AppTheme.primary,
        onTap: () => Navigator.pushNamed(context, LecturerCreateMcqScreen.routeName),
      ),
      _DashboardCardData(
        title: context.t(AppText.lecturerCardResults),
        subtitle: context.t(AppText.lecturerCardResultsDesc),
        icon: Icons.assessment_rounded,
        accent: AppTheme.secondary,
        onTap: () => Navigator.pushNamed(context, LecturerResultsScreen.routeName),
      ),
      _DashboardCardData(
        title: context.t(AppText.lecturerCardResources),
        subtitle: context.t(AppText.lecturerCardResourcesDesc),
        icon: Icons.auto_stories_rounded,
        accent: AppTheme.accent,
        onTap: () => Navigator.pushNamed(context, LecturerResourcesScreen.routeName),
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
                child: _ActionCard(data: card),
              )),
          const SizedBox(height: 8),
          Text(
            context.t(AppText.learningVault),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const _ResourceSpotlight(),
        ],
      ),
    );
  }
}

class LecturerCreateMcqScreen extends StatefulWidget {
  const LecturerCreateMcqScreen({super.key});

  static const routeName = '/lecturer/create-mcq';

  @override
  State<LecturerCreateMcqScreen> createState() => _LecturerCreateMcqScreenState();
}

class _LecturerCreateMcqScreenState extends State<LecturerCreateMcqScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (index) => TextEditingController());
  int _correctIndex = 0;

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alphabet = ['A', 'B', 'C', 'D'];
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.createMcqTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t(AppText.createMcqSubtitle),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.t(AppText.questionFieldLabel),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(_optionControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _optionControllers[index],
                  decoration: InputDecoration(
                    labelText:
                        '${context.t(AppText.answerOptionLabel)} ${alphabet[index]}',
                    prefixIcon: CircleAvatar(
                      radius: 14,
                      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                      child: Text(alphabet[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _correctIndex,
              decoration: InputDecoration(
                labelText: context.t(AppText.correctAnswerLabel),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              items: List.generate(
                4,
                (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text('${context.t(AppText.answerOptionLabel)} ${alphabet[index]}'),
                ),
              ),
              onChanged: (value) => setState(() => _correctIndex = value ?? 0),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _explanationController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: context.t(AppText.explanationLabel),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                FilledButton(
                  onPressed: () => _showSnack(context, AppText.prototypeMessage),
                  child: Text(context.t(AppText.previewButton)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showSnack(context, AppText.publishSnack),
                    child: Text(context.t(AppText.publishButton)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, AppText key) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t(key))),
    );
  }
}

class LecturerResultsScreen extends StatelessWidget {
  const LecturerResultsScreen({super.key});

  static const routeName = '/lecturer/results';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.resultsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t(AppText.resultsSubtitle),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              onPressed: () => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(context.t(AppText.pdfSuccess)))),
              label: Text(context.t(AppText.generatePdf)),
            ),
            const SizedBox(height: 24),
            Text(
              context.t(AppText.resultsListTitle),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: mockScores.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final score = mockScores[index];
                  final colorScheme = Theme.of(context).colorScheme;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  score.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Chip(
                                backgroundColor:
                                    (score.sent ? colorScheme.secondary : colorScheme.tertiary).withOpacity(0.12),
                                label: Text(
                                  score.sent
                                      ? context.t(AppText.pdfReady)
                                      : context.t(AppText.pdfPending),
                                  style: TextStyle(
                                    color: score.sent ? colorScheme.secondary : colorScheme.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: score.score / 100,
                                  backgroundColor: colorScheme.primary.withOpacity(0.08),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('${score.score} / 100'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LecturerResourcesScreen extends StatelessWidget {
  const LecturerResourcesScreen({super.key});

  static const routeName = '/lecturer/resources';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.resourcesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.t(AppText.addedResource)))),
        icon: const Icon(Icons.add_circle_outline),
        label: Text(context.t(AppText.addResource)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockResources.length,
        itemBuilder: (context, index) {
          final resource = mockResources[index];
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
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.folder_open_rounded,
                              color: Theme.of(context).colorScheme.secondary),
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
}

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const routeName = '/student';

  @override
  Widget build(BuildContext context) {
    final cards = [
      _DashboardCardData(
        title: context.t(AppText.studentTakeExam),
        subtitle: context.t(AppText.studentTakeExamDesc),
        icon: Icons.fact_check_rounded,
        accent: AppTheme.primary,
        onTap: () => Navigator.pushNamed(context, StudentExamScreen.routeName),
      ),
      _DashboardCardData(
        title: context.t(AppText.studentFeedback),
        subtitle: context.t(AppText.studentFeedbackDesc),
        icon: Icons.bolt_rounded,
        accent: AppTheme.secondary,
        onTap: () => Navigator.pushNamed(context, StudentFeedbackScreen.routeName),
      ),
      _DashboardCardData(
        title: context.t(AppText.studentMaterials),
        subtitle: context.t(AppText.studentMaterialsDesc),
        icon: Icons.menu_book_rounded,
        accent: AppTheme.accent,
        onTap: () => Navigator.pushNamed(context, StudentMaterialsScreen.routeName),
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
                child: _ActionCard(data: card),
              )),
        ],
      ),
    );
  }
}

class StudentExamScreen extends StatefulWidget {
  const StudentExamScreen({super.key});

  static const routeName = '/student/exam';

  @override
  State<StudentExamScreen> createState() => _StudentExamScreenState();
}

class _StudentExamScreenState extends State<StudentExamScreen> {
  final List<int?> _answers = List<int?>.filled(mockQuestions.length, null);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.examTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockQuestions.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t(AppText.examSubtitle),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_rounded, color: colorScheme.tertiary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.t(AppText.examLockedHint),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          if (index == mockQuestions.length + 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 32),
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, StudentFeedbackScreen.routeName),
                child: Text(context.t(AppText.resumeExam)),
              ),
            );
          }
          final question = mockQuestions[index - 1];
          final answer = _answers[index - 1];
          final isLocked = answer != null;
          final isCorrect = answer == question.correctIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q$index — ${question.prompt}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(question.options.length, (optionIndex) {
                      return RadioListTile<int>(
                        value: optionIndex,
                        groupValue: answer,
                        onChanged: isLocked
                            ? null
                            : (value) => setState(() {
                                  _answers[index - 1] = value;
                                }),
                        title: Text(question.options[optionIndex]),
                      );
                    }),
                    const SizedBox(height: 8),
                    if (isLocked)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isCorrect ? colorScheme.secondary : colorScheme.tertiary).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.verified_rounded : Icons.tips_and_updates_rounded,
                                  color: isCorrect ? colorScheme.secondary : colorScheme.tertiary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.t(AppText.responseLocked),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isCorrect
                                  ? context.t(AppText.responseCorrect)
                                  : context.t(AppText.responseIncorrect),
                            ),
                            const SizedBox(height: 4),
                            Text(question.tip,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontStyle: FontStyle.italic)),
                          ],
                        ),
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
}

class StudentFeedbackScreen extends StatelessWidget {
  const StudentFeedbackScreen({super.key});

  static const routeName = '/student/feedback';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.feedbackTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.t(AppText.feedbackSnack)))),
        icon: const Icon(Icons.share_rounded),
        label: Text(context.t(AppText.viewMaterials)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockFeedback.length,
        itemBuilder: (context, index) {
          final item = mockFeedback[index];
          final colorScheme = Theme.of(context).colorScheme;
          final icon = item.isCorrect ? Icons.check_circle : Icons.error_outline;
          final color = item.isCorrect ? colorScheme.secondary : colorScheme.tertiary;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(item.detail),
                trailing: Text(item.status, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StudentMaterialsScreen extends StatelessWidget {
  const StudentMaterialsScreen({super.key});

  static const routeName = '/student/materials';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.materialsTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: pastMaterials.length,
        itemBuilder: (context, index) {
          final material = pastMaterials[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
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
}

class _DashboardCardData {
  const _DashboardCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.data});

  final _DashboardCardData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [data.accent.withOpacity(0.14), Theme.of(context).cardColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: data.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(data.icon, color: data.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(data.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceSpotlight extends StatelessWidget {
  const _ResourceSpotlight();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t(AppText.resourcesSubtitle),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, LecturerResourcesScreen.routeName),
                    child: Text(context.t(AppText.addResource)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.auto_awesome, size: 48),
          ],
        ),
      ),
    );
  }
}

class StudentScore {
  const StudentScore({required this.name, required this.score, required this.sent});

  final String name;
  final int score;
  final bool sent;
}

const mockScores = [
  StudentScore(name: 'Aminata Diallo', score: 92, sent: true),
  StudentScore(name: 'Lionel Wamba', score: 78, sent: false),
  StudentScore(name: 'Béatrice Nguema', score: 84, sent: true),
  StudentScore(name: 'Eric Tanyi', score: 68, sent: false),
];

class MockQuestion {
  const MockQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.tip,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String tip;
}

const mockQuestions = [
  MockQuestion(
    prompt: 'Bloom taxonomy identifies which level for “justify your answer”?',
    options: [
      'Remembering',
      'Understanding',
      'Evaluating',
      'Applying',
    ],
    correctIndex: 2,
    tip: 'Evaluating prompts learners to critique evidence and defend a choice.',
  ),
  MockQuestion(
    prompt: 'Which metric signals exam reliability when repeated?',
    options: [
      'Cronbach’s alpha',
      'Face validity',
      'Item difficulty',
      'Distractor efficiency',
    ],
    correctIndex: 0,
    tip: 'Alpha measures internal consistency, ensuring stable scoring.',
  ),
  MockQuestion(
    prompt: 'Best channel to release remediation capsules to cohorts?',
    options: [
      'SMS broadcast',
      'Learning vault inside Evalis',
      'Paper notice board',
      'One-to-one emails',
    ],
    correctIndex: 1,
    tip: 'Centralizing materials gives equal access and analytics for lecturers.',
  ),
];

class FeedbackEntry {
  const FeedbackEntry({
    required this.title,
    required this.status,
    required this.detail,
    required this.isCorrect,
  });

  final String title;
  final String status;
  final String detail;
  final bool isCorrect;
}

const mockFeedback = [
  FeedbackEntry(
    title: 'Adaptive pedagogy fundamentals',
    status: '+12 pts',
    detail: 'Great conceptual grounding. Explore case-based nuance next.',
    isCorrect: true,
  ),
  FeedbackEntry(
    title: 'Assessment analytics',
    status: 'Review',
    detail: 'Remember to tie metrics back to teaching decisions.',
    isCorrect: false,
  ),
  FeedbackEntry(
    title: 'Ethics & fairness',
    status: '+8 pts',
    detail: 'Balanced commentary. Cite additional policies to excel.',
    isCorrect: true,
  ),
];

class LearningResource {
  const LearningResource({
    required this.title,
    required this.description,
    required this.format,
    required this.eta,
  });

  final String title;
  final String description;
  final String format;
  final String eta;
}

const mockResources = [
  LearningResource(
    title: 'MCQ writing canvas',
    description: 'Template to balance STEM difficulty across Bloom levels.',
    format: 'Google Slides',
    eta: '15 min read',
  ),
  LearningResource(
    title: 'Exam analytics walkthrough',
    description: 'Video explainer to interpret cohort performance quickly.',
    format: 'Video',
    eta: '8 min watch',
  ),
  LearningResource(
    title: 'Remediation prompt pack',
    description: 'Plug-and-play nudges for revision weeks.',
    format: 'PDF handout',
    eta: '10 min prep',
  ),
];

class PastMaterial {
  const PastMaterial({
    required this.title,
    required this.topic,
    required this.duration,
    required this.difficulty,
  });

  final String title;
  final String topic;
  final String duration;
  final String difficulty;
}

const pastMaterials = [
  PastMaterial(
    title: 'MCQ strategy drill',
    topic: 'Higher-order questioning',
    duration: '25 min',
    difficulty: 'Intermediate',
  ),
  PastMaterial(
    title: 'Analytics crash course',
    topic: 'Interpreting dashboards',
    duration: '18 min',
    difficulty: 'Beginner',
  ),
  PastMaterial(
    title: 'Assessment ethics set',
    topic: 'Fairness scenarios',
    duration: '30 min',
    difficulty: 'Advanced',
  ),
];
