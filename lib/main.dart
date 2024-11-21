import 'package:exercise_roadmap/theme/app_theme.dart';
import 'package:exercise_roadmap/ui/widgets/screens/quiz/quiz.dart';
import 'package:exercise_roadmap/ui/widgets/screens/roadmap_screenn.dart';
import 'package:flutter/material.dart';
// import 'ui/screens/roadmap_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Using the global theme
      home: RoadmapScreen(),
    );
  }
}
