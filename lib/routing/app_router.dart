import 'package:flutter/material.dart';

import '../screens/landing/landing_screen.dart';
import '../screens/lecturer/lecturer_create_mcq_screen.dart';
import '../screens/lecturer/lecturer_dashboard_screen.dart';
import '../screens/lecturer/lecturer_resources_screen.dart';
import '../screens/lecturer/lecturer_results_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/student_exam_screen.dart';
import '../screens/student/student_feedback_screen.dart';
import '../screens/student/student_materials_screen.dart';

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
