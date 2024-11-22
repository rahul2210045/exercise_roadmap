import 'package:flutter/material.dart';
import 'package:exercise_roadmap/data/roadmap_data.dart';

class GrammarPracticeScreen extends StatefulWidget {
   final String day;
  final String exerciseName;
  final List<dynamic> questions;

  const GrammarPracticeScreen({
    Key? key,
    required this.day,
    required this.exerciseName,
    required this.questions,
  }) : super(key: key);
  @override
  _GrammarPracticeScreenState createState() => _GrammarPracticeScreenState();
}

class _GrammarPracticeScreenState extends State<GrammarPracticeScreen> {
  late List<Map<String, dynamic>> questions = [];
 @override
void initState() {
  super.initState();
  print("GrammarPracticeScreen initialized");
  print("Day: ${widget.day}");
  print("Exercise Name: ${widget.exerciseName}");
  print("Questions: ${widget.questions}");
}


  // Transform the imported roadmapData into a usable format
  List<Map<String, dynamic>> transformExerciseData(Map<String, dynamic> exerciseData) {
    List<Map<String, dynamic>> questions = [];
    
    // If the roadmap data is empty, log an error and return an empty list
    if (exerciseData.isEmpty) {
      print("Error: roadmapData is empty.");
      return questions;
    }

    exerciseData.forEach((day, topics) {
      // Iterate through each category (Adjectives, Adverbs, etc.)
      (topics as Map<String, dynamic>).forEach((topic, questionSets) {
        // Ensure questionSets is treated as a List
        (questionSets as List).forEach((questionSet) {
          questions.add({
            "topic": topic,
            "days": [
              {
                "day": int.parse(day.replaceAll(RegExp(r'[^0-9]'), '')), // Extract numeric day
                "questions": questionSet['questions'].map((question) {
                  return {
                    "question": question['question'],
                    "options": question['options'],
                    "answer": question['options'].indexOf(question['answer']),
                  };
                }).toList(),
              }
            ],
          });
        });
      });
    });

    return questions;
  }

  int currentQuestionIndex = 0;
  int currentDayIndex = 0;
  int? selectedOption;
  bool showAnswer = false;
  bool isCorrect = false;

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
       print("No questions available for this exercise.");
      // Display a loading or error message if questions are empty
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text("Grammar Practice"),
        ),
        body: const Center(
          child: Text(
            "No questions available.",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    // Extract current day and question
    final currentDay = questions[currentDayIndex]['days'][0];
    final currentQuestion = currentDay['questions'][currentQuestionIndex] as Map<String, dynamic>;

    // Calculate progress
    final totalQuestions = currentDay['questions'].length;
    final progress = (currentQuestionIndex + 1) / totalQuestions;

    final List<String> options = List<String>.from(currentQuestion['options']);
    final int correctAnswerIndex = currentQuestion['answer'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Grammar Practice"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            // Question
            Text(
              "Q${currentQuestionIndex + 1}. Fill in the blanks",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currentQuestion['question'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedOption == index;
                  final isCorrectOption = index == correctAnswerIndex;

                  return GestureDetector(
                    onTap: () {
                      if (!showAnswer) {
                        setState(() {
                          selectedOption = index;
                          isCorrect = selectedOption == correctAnswerIndex;
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: showAnswer
                            ? (isCorrectOption
                                ? Colors.green
                                : (isSelected ? Colors.red : Colors.black))
                            : (isSelected ? Colors.blue : Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[800]!,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${String.fromCharCode(65 + index)}. ",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            options[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Check Answer Button
            if (!showAnswer)
              Center(
                child: ElevatedButton(
                  onPressed: selectedOption == null
                      ? null
                      : () {
                          setState(() {
                            showAnswer = true;
                          });
                        },
                  child: const Text("Check Answer"),
                ),
              ),
            if (showAnswer)
              Center(
                child: Column(
                  children: [
                    Text(
                      isCorrect ? "Great Work!" : "Incorrect Answer",
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isCorrect)
                      Text(
                        "Correct answer: ${options[correctAnswerIndex]}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (currentQuestionIndex < totalQuestions - 1) {
                            currentQuestionIndex++;
                          } else if (currentDayIndex < questions.length - 1) {
                            currentDayIndex++;
                            currentQuestionIndex = 0;
                          } else {
                            currentDayIndex = 0;
                            currentQuestionIndex = 0;
                          }
                          selectedOption = null;
                          showAnswer = false;
                        });
                      },
                      child: const Text("Next Question"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
