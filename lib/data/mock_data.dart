import '../models/course_enrollment.dart';
import '../models/course_info.dart';
import '../models/enrollment_request.dart';
import '../models/exam_brief.dart';
import '../models/learning_resource.dart';
import '../models/mock_question.dart';
import '../models/past_material.dart';
import '../models/student_score.dart';
import '../models/user_profile.dart';

const mockScores = [
  StudentScore(name: 'Aminata Diallo', score: 92, sent: true),
  StudentScore(name: 'Lionel Wamba', score: 78, sent: false),
  StudentScore(name: 'Beatrice Nguema', score: 84, sent: true),
  StudentScore(name: 'Eric Tanyi', score: 68, sent: false),
];

const analyticsCourse = CourseInfo(
  code: 'EDU402',
  title: 'Learning Analytics Studio',
  lecturer: 'Dr. Clarisse Ngono',
  schedule: 'Mon & Wed · 10:00',
);

const assessmentCourse = CourseInfo(
  code: 'EDU356',
  title: 'Inclusive Assessment Design',
  lecturer: 'Dr. Clarisse Ngono',
  schedule: 'Tue · 14:00',
);

const strategyCourse = CourseInfo(
  code: 'EDU268',
  title: 'MCQ Strategy Lab',
  lecturer: 'Prof. Lionel Tamo',
  schedule: 'Thu · 09:00',
);

const remediationCourse = CourseInfo(
  code: 'EDU481',
  title: 'Remediation Playbook',
  lecturer: 'Prof. Lionel Tamo',
  schedule: 'Fri · 11:00',
);

const List<CourseInfo> lecturerCourses = [analyticsCourse, assessmentCourse, remediationCourse];

const List<CourseInfo> availableCourses = [analyticsCourse, assessmentCourse, strategyCourse, remediationCourse];

const List<CourseEnrollment> studentEnrollments = [
  CourseEnrollment(course: analyticsCourse, status: EnrollmentStatus.approved),
  CourseEnrollment(course: assessmentCourse, status: EnrollmentStatus.pending),
];

const List<EnrollmentRequest> pendingApprovals = [
  EnrollmentRequest(studentName: 'Nadia Fong', course: assessmentCourse, submittedOn: 'Jan 28, 2026'),
  EnrollmentRequest(studentName: 'Samuel Bekolo', course: strategyCourse, submittedOn: 'Jan 30, 2026'),
];

const UserProfile lecturerProfile = UserProfile(
  name: 'Dr. Clarisse Ngono',
  email: 'clarisse.ngono@evalis.edu',
  roleLabel: 'Lead Lecturer',
  headline: 'Driving equitable assessments across science programs.',
  courses: lecturerCourses,
);

const UserProfile studentProfile = UserProfile(
  name: 'Irène Maku',
  email: 'irene.maku@student.evalis.edu',
  roleLabel: 'Instructional Sciences Major',
  headline: 'Exploring data-informed teaching practices.',
  courses: [analyticsCourse, assessmentCourse],
);

const mockExams = [
  ExamBrief(id: 'ex-001', title: 'Midterm · Learning Analytics', courseCode: 'EDU402', window: 'Opens 12 Mar'),
  ExamBrief(id: 'ex-002', title: 'Diagnostic · Inclusive Design', courseCode: 'EDU356', window: 'Opens 18 Mar'),
  ExamBrief(id: 'ex-003', title: 'Sprint · MCQ Strategy Lab', courseCode: 'EDU268', window: 'Opens 25 Mar'),
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
