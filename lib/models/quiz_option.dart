import 'package:flutter/material.dart';

class QuizOption {
  final String text;
  final IconData icon;

  const QuizOption({required this.text, required this.icon});

  Map<String, dynamic> toMap() => {
        'text': text,
        'icon': icon,
      };
}
