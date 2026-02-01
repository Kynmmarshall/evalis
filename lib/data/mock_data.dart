import '../models/feedback_entry.dart';
import '../models/learning_resource.dart';
import '../models/mock_question.dart';
import '../models/past_material.dart';
import '../models/student_score.dart';

const mockScores = [
  StudentScore(name: 'Aminata Diallo', score: 92, sent: true),
  StudentScore(name: 'Lionel Wamba', score: 78, sent: false),
  StudentScore(name: 'Beatrice Nguema', score: 84, sent: true),
  StudentScore(name: 'Eric Tanyi', score: 68, sent: false),
];

const mockQuestions = [
  MockQuestion(
    prompt: 'Bloom taxonomy identifies which level for “justify your answer”?',
    options: ['Remembering', 'Understanding', 'Evaluating', 'Applying'],
    correctIndex: 2,
    tip: 'Evaluating prompts learners to critique evidence and defend a choice.',
  ),
  MockQuestion(
    prompt: 'Which metric signals exam reliability when repeated?',
    options: ['Cronbach’s alpha', 'Face validity', 'Item difficulty', 'Distractor efficiency'],
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
