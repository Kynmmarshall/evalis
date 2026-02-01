import 'package:flutter/material.dart';

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

extension LocaleX on Locale {
  AppLanguage get asAppLanguage => languageCode == 'fr' ? AppLanguage.french : AppLanguage.english;
}
