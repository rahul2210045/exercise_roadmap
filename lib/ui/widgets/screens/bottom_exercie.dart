import 'package:exercise_roadmap/data/roadmap_data.dart';
import 'package:exercise_roadmap/ui/widgets/screens/quiz/quiz.dart';
import 'package:flutter/material.dart';

class ExerciseBottomSheet extends StatefulWidget {
  final String day;
  final Function(String, String, List<dynamic>) onStartQuiz;

  const ExerciseBottomSheet({
    required this.day,
    required this.onStartQuiz,
  });

  @override
  _ExerciseBottomSheetState createState() => _ExerciseBottomSheetState();
}

class _ExerciseBottomSheetState extends State<ExerciseBottomSheet> {
  int? selectedExerciseIndex;
  late List<Map<String, dynamic>> exercises;

  @override
  void initState() {
    super.initState();

    // Initialize exercises for the given day
    exercises =
        (roadmapData[widget.day] as Map<String, dynamic>).entries.map((entry) {
      return {
        'name': entry.key,
        'questions': entry.value, // Ensure this is correct.
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
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
              const SizedBox(height: 16),
              const Text(
                "Choose Exercise",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ExerciseCard(
                        name: exercise['name'],
                        score:
                            '', // Replace with relevant logic if scores are tracked
                        isCompleted:
                            false, // Adjust logic to track completed exercises
                        isSelected: selectedExerciseIndex == index,
                        onTap: () {
                          setState(() {
                            selectedExerciseIndex = index;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedExerciseIndex != null
                        ? Colors.purple
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // onPressed: selectedExerciseIndex != null
                  //     ? () {
                  //         print("Start Practice clicked");

                  //         final selectedExercise =
                  //             exercises[selectedExerciseIndex!];
                  //         final exerciseName = selectedExercise['name'];

                  //         // Ensure 'questions' is properly initialized and valid
                  //         List<dynamic> questions = [];

                  //         if (selectedExercise['questions'] != null) {
                  //           questions =
                  //               List.from(selectedExercise['questions']);
                  //         }

                  //         if (questions.isEmpty) {
                  //           print("No questions available for this exercise.");
                  //         } else {
                  //           print(
                  //               "Day: ${widget.day}, Exercise: $exerciseName, Questions: $questions");
                  //         }

                  //         widget.onStartQuiz(
                  //             widget.day, exerciseName, questions);

                  //         // Navigate after ensuring the questions are properly initialized
                  //         Future.delayed(Duration(milliseconds: 300), () {
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (context) {
                  //                 return GrammarPracticeScreen(
                  //                   day: widget.day,
                  //                   exerciseName: exerciseName,
                  //                   questions: questions,
                  //                 );
                  //               },
                  //             ),
                  //           );
                  //         });

                  //         Navigator.pop(context); // Close bottom sheet
                  //       }
                  //     : null,
                 onPressed: selectedExerciseIndex != null
    ? () {
        final selectedExercise = exercises[selectedExerciseIndex!];
        final exerciseName = selectedExercise['name'];

        // Fetch questions from the database or map
        final List<dynamic> selectedQuestions = List.from(selectedExercise['questions'] ?? []);

        if (selectedQuestions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No questions available for this exercise."),
            ),
          );
          return; // Stop execution if no questions are found
        }

        // Pass questions correctly to GrammarPracticeScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrammarPracticeScreen(
              day: widget.day,
              exerciseName: exerciseName,
              questions: selectedQuestions, // Ensure questions are passed
            ),
          ),
        ).then((_) => Navigator.pop(context)); // Close bottom sheet after navigation
      }
    : null,

                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
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
  final bool isSelected;
  final VoidCallback onTap;

  const ExerciseCard({
    required this.name,
    required this.score,
    required this.isCompleted,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isCompleted
                ? Colors.green
                : (isSelected ? Colors.purple : Colors.grey),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/avatar.png'), // Placeholder
              radius: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            Text(
              score,
              style: const TextStyle(
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
