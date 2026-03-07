import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/lecturer/lecturer_approvals_screen.dart';
import '../screens/lecturer/lecturer_create_mcq_screen.dart';
import '../screens/lecturer/lecturer_dashboard_screen.dart';
import '../screens/lecturer/lecturer_courses_screen.dart';
import '../screens/lecturer/lecturer_exam_manager_screen.dart';
import '../screens/lecturer/lecturer_exam_results_screen.dart';
import '../screens/lecturer/lecturer_profile_screen.dart';
import '../screens/lecturer/lecturer_results_screen.dart';
import '../screens/startup/splash_screen.dart';
import '../screens/student/student_courses_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/student_exam_screen.dart';
import '../screens/student/student_feedback_screen.dart';
import '../screens/student/student_profile_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case SplashScreen.routeName:
        page = const SplashScreen();
        break;
      case LoginScreen.routeName:
        page = const LoginScreen();
        break;
      case RegistrationScreen.routeName:
        page = const RegistrationScreen();
        break;
      case LandingScreen.routeName:
        page = const LandingScreen();
        break;
      case LecturerDashboardScreen.routeName:
        page = const LecturerDashboardScreen();
        break;
      case LecturerCoursesScreen.routeName:
        page = const LecturerCoursesScreen();
        break;
      case LecturerExamManagerScreen.routeName:
        page = const LecturerExamManagerScreen();
        break;
      case LecturerCreateMcqScreen.routeName:
        page = const LecturerCreateMcqScreen();
        break;
      case LecturerResultsScreen.routeName:
        page = const LecturerResultsScreen();
        break;
      case LecturerExamResultsScreen.routeName:
        final args = settings.arguments;
        if (args is LecturerExamResultsArgs) {
          page = LecturerExamResultsScreen(
            examId: args.examId,
            initialScorebook: args.initialScorebook,
          );
        } else {
          page = const LecturerResultsScreen();
        }
        break;
      case LecturerProfileScreen.routeName:
        page = const LecturerProfileScreen();
        break;
      case LecturerApprovalsScreen.routeName:
        page = LecturerApprovalsScreen();
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
      case StudentCoursesScreen.routeName:
        page = StudentCoursesScreen();
        break;
      case StudentProfileScreen.routeName:
        page = const StudentProfileScreen();
        break;
      default:
        page = const SplashScreen();
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
