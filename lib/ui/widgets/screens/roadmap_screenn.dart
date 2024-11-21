import 'dart:math';
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
    final screenWidth = 360.0; // Placeholder width for random horizontal positions
    final spacing = 150.0; // Vertical spacing between nodes
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
        title: Text("Hey Mahesh", style: TextStyle(color: Colors.white)),
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
                    _showExerciseBottomSheet(context, index);
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
  void _showExerciseBottomSheet(BuildContext context, int day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return ExerciseBottomSheet(
          day: day,
          onCompleteExercise: (completedDay) {
            if (completedDay == unlockedDay) {
              setState(() {
                unlockedDay++;
              });
            }
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
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          isCompleted ? "✔" : "",
          style: TextStyle(color: Colors.white),
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
class ExerciseBottomSheet extends StatelessWidget {
  final int day;
  final Function(int) onCompleteExercise;

  ExerciseBottomSheet({required this.day, required this.onCompleteExercise});

  @override
  Widget build(BuildContext context) {
    final exercises = [
      {"name": "Pronouns", "score": "4/5", "completed": true},
      {"name": "Adjectives", "score": "3/5", "completed": false},
    ];

    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Choose Exercise",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ExerciseCard(
                        name: exercise["name"]! as String,
                        score: exercise["score"]! as String,
                        isCompleted: exercise["completed"]! as bool,
                        onTap: () {
                          if (!(exercise["completed"] as bool)) {
                            onCompleteExercise(day);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 10.0),
                    child: Text(
                      "Start Practice",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final String name;
  final String score;
  final bool isCompleted;
  final VoidCallback onTap;

  const ExerciseCard({
    required this.name,
    required this.score,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green : Colors.purple,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isCompleted ? Colors.greenAccent : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/avatar.png'), // Placeholder
              radius: 20,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            Text(
              score,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
