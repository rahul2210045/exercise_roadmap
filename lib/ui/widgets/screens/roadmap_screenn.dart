import 'dart:math';
import 'package:exercise_roadmap/data/roadmap_data.dart';
import 'package:exercise_roadmap/ui/widgets/screens/bottom_exercie.dart';
import 'package:exercise_roadmap/ui/widgets/screens/quiz/quiz.dart';
import 'package:flutter/material.dart';

class RoadmapScreen extends StatefulWidget {
  @override
  _RoadmapScreenState createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final int totalDays = 7; // Total number of days in the roadmap
  int unlockedDay = 1; // Keeps track of the unlocked day
  final List<Offset> nodePositions = [];

  @override
  void initState() {
    super.initState();
    generateNodePositions();
  }

  // Generate random horizontal positions for nodes while maintaining vertical spacing
  void generateNodePositions() {
    final random = Random();
    const screenWidth = 360.0; // Placeholder width for random horizontal positions
    const spacing = 150.0; // Vertical spacing between nodes
    for (int i = 0; i < totalDays; i++) {
      final x = random.nextDouble() * (screenWidth - 80) + 40; // Ensure padding
      final y = spacing * i + 50;
      nodePositions.add(Offset(x, y));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Hey Mahesh", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: SizedBox(
                height: (nodePositions.length + 1) * 150.0,
                child: CustomPaint(
                  painter: PathPainter(nodePositions, unlockedDay),
                ),
              ),
            ),
          ),
          ...nodePositions.map((position) {
            int index = nodePositions.indexOf(position) + 1;
            return Positioned(
              top: position.dy,
              left: position.dx,
              child: GestureDetector(
                onTap: () {
                  if (index <= unlockedDay) {
                    _showExerciseBottomSheet(context, 'Day $index');
                  }
                },
                child: NodeWidget(
                  index: index,
                  isUnlocked: index <= unlockedDay,
                  isCompleted: index < unlockedDay,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Show the exercise bottom sheet for the selected day
  void _showExerciseBottomSheet(BuildContext context, String day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return ExerciseBottomSheet(
          day: day, // Pass the selected day as a string
          onStartQuiz: (selectedDay, exerciseName, questions) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return GrammarPracticeScreen(
                    day: selectedDay,
                    exerciseName: exerciseName,
                    questions: questions,
                  );
                },
              ),
            );
            print("Navigation to GrammarPracticeScreen triggered");
          },
        );
      },
    );
  }
}

// A widget to represent each node in the roadmap
class NodeWidget extends StatelessWidget {
  final int index;
  final bool isUnlocked;
  final bool isCompleted;

  const NodeWidget({
    required this.index,
    required this.isUnlocked,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isUnlocked
                ? (isCompleted ? Colors.green : Colors.blue)
                : Colors.grey,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Text(
            "Day $index",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isCompleted ? "✔" : "",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

// Custom painter to draw the animated path
class PathPainter extends CustomPainter {
  final List<Offset> positions;
  final int unlockedDay;

  PathPainter(this.positions, this.unlockedDay);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final completedPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < positions.length - 1; i++) {
      final start = positions[i];
      final end = positions[i + 1];
      canvas.drawLine(
        start,
        end,
        i + 1 < unlockedDay ? completedPaint : paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Bottom Sheet for displaying exercises
