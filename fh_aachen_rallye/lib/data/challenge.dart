import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class Challenge {
  final String id;
  final String title;
  final Difficulty difficulty;
  final int points;
  final ChallengeCategory category;
  final String descriptionStart;
  final String descriptionEnd;
  final List<ChallengeStep> steps;

  final String? image;

  const Challenge({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.category,
    required this.points,
    required this.descriptionStart,
    required this.descriptionEnd,
    required this.steps,
    this.image,
  });
}

class ChallengeCategory {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const ChallengeCategory(this.name, this.description, this.icon,
      {this.color = Colors.orange});

  static const ChallengeCategory general = ChallengeCategory(
    "General",
    "General knowledge and trivia.",
    Icons.lightbulb,
    color: Colors.yellow,
  );
}

abstract class ChallengeStep {
  final String text;
  final int? next;
  final bool isLast;

  final bool hasNextButton;

  const ChallengeStep(this.text,
      {this.next, this.isLast = false, this.hasNextButton = true});
}

class ChallengeStepSay extends ChallengeStep {
  const ChallengeStepSay(super.text, {super.next, super.isLast = false})
      : super(hasNextButton: true);
}

class ChallengeStepOptions extends ChallengeStep {
  final Map<String, int> options;

  const ChallengeStepOptions(super.text, this.options,
      {super.next, super.isLast = false})
      : super(hasNextButton: false);
}

class ChallengeStepStringInput extends ChallengeStep {
  final String correctAnswer;
  final int indexOnIncorrect;

  const ChallengeStepStringInput(
      super.text, this.correctAnswer, this.indexOnIncorrect,
      {super.next, super.isLast = false})
      : super(hasNextButton: false);
}
