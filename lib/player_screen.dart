import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:quiz_app/question_model.dart';
import 'package:quiz_app/score_page.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  List<Question> questions = [];

  Future<void> fetchQuestions() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api.php?amount=10&category=18&difficulty=easy&type=multiple'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        questions = List<Question>.from(data['results'].map((question) => Question.fromJson(question)));
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void checkAnswer(String selectedAnswer) {
    if (questions[currentQuestionIndex].correctAnswer == selectedAnswer) {
      score++;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ScoreScreen(score: score)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Question')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Question')),
      body: ListView(
        children: <Widget>[
          ListTile(title: Text(question.question)),
          ...question.answers.map((answer) => ListTile(
            title: Text(answer),
            onTap: () => checkAnswer(answer),
          )).toList(),
        ],
      ),
    );
  }
}