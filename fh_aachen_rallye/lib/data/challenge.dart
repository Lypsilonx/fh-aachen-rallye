import 'dart:convert';

import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:flutter/material.dart';

class Challenge extends ServerObject {
  final String challengeId;
  final String title;
  final Language language;
  final Difficulty difficulty;
  final int points;
  final ChallengeCategory category;
  final String descriptionStart;
  final String descriptionEnd;
  final List<ChallengeStep> steps;

  final String? image;

  const Challenge(
    super.id, {
    required this.challengeId,
    required this.title,
    required this.language,
    required this.difficulty,
    required this.category,
    required this.points,
    required this.descriptionStart,
    required this.descriptionEnd,
    required this.steps,
    this.image,
  });

  static Challenge empty(String id) {
    return Challenge(
      id,
      challengeId: 'LOADING',
      title: 'LOADING',
      language: Language.en,
      difficulty: Difficulty.none,
      category: ChallengeCategory.loading,
      points: 0,
      descriptionStart: 'LOADING',
      descriptionEnd: 'LOADING',
      steps: [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengeId': challengeId,
      'title': title,
      'language': language.name,
      'difficulty': difficulty.index,
      'category': switch (category) {
        ChallengeCategory.general => 'general',
        _ => 'loading',
      },
      'points': points,
      'descriptionStart': descriptionStart,
      'descriptionEnd': descriptionEnd,
      'steps': steps.map((e) {
        var json = e.toJson();
        json['index'] = steps.indexOf(e);
        return json;
      }).toList(),
      'image': image,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      json['id'] as String,
      challengeId: json['challenge_id'] as String,
      title: json['title'] as String,
      language: Language.values
          .firstWhere((element) => element.name == json['language'] as String),
      difficulty: Difficulty.values[json['difficulty'] as int],
      category: switch (json['category']) {
        'general' => ChallengeCategory.general,
        _ => ChallengeCategory.loading,
      },
      points: json['points'] as int,
      descriptionStart: json['descriptionStart'] as String,
      descriptionEnd: json['descriptionEnd'] as String,
      steps: (json['steps'] as List)
          .map((e) => ChallengeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      image: json['image'] as String?,
    );
  }
}

class ChallengeCategory {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const ChallengeCategory(this.name, this.description, this.icon,
      {this.color = Colors.orange});

  static const ChallengeCategory loading = ChallengeCategory(
    "LOADING",
    "LOADING",
    Icons.hourglass_empty,
    color: Colors.grey,
  );

  static const ChallengeCategory general = ChallengeCategory(
    "CATEGORY_GENERAL",
    "CATEGORY_GENERAL_DESCRIPTION",
    Icons.lightbulb,
    color: Colors.yellow,
  );
}

abstract class ChallengeStep {
  final String text;
  final int? next;
  final List<int>? alternatives;
  final bool isLast;

  final bool hasNextButton;

  const ChallengeStep(this.text,
      {this.next,
      this.alternatives,
      this.isLast = false,
      this.hasNextButton = true});

  Map<String, dynamic> toJson() {
    if (runtimeType.toString() == (ChallengeStepSay).toString()) {
      return (this as ChallengeStepSay).toJson();
    } else if (runtimeType.toString() == (ChallengeStepOptions).toString()) {
      return (this as ChallengeStepOptions).toJson();
    } else if (runtimeType.toString() ==
        (ChallengeStepStringInput).toString()) {
      return (this as ChallengeStepStringInput).toJson();
    } else if (runtimeType.toString() == (ChallengeStepScan).toString()) {
      return (this as ChallengeStepScan).toJson();
    } else {
      throw Exception('Unknown type');
    }
  }

  factory ChallengeStep.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'say':
        return ChallengeStepSay.fromJson(json);
      case 'options':
        return ChallengeStepOptions.fromJson(json);
      case 'stringInput':
        return ChallengeStepStringInput.fromJson(json);
      case 'scan':
        return ChallengeStepScan.fromJson(json);
      default:
        throw Exception('Unknown type');
    }
  }
}

class ChallengeStepSay extends ChallengeStep {
  const ChallengeStepSay(
    super.text, {
    super.next,
    super.alternatives,
    super.isLast = false,
  }) : super(hasNextButton: true);

  Map<String, dynamic> toJson() {
    return {
      'type': 'say',
      'text': text,
      'next': next,
      'alternatives': alternatives?.map((e) => e.toString()).join(','),
      'isLast': isLast,
    };
  }

  factory ChallengeStepSay.fromJson(Map<String, dynamic> json) {
    return ChallengeStepSay(
      json['text'] as String,
      next: json['next'] as int?,
      isLast: json['isLast'] as int == 1,
      alternatives:
          (json['alternatives'] as String?)?.split(',').map(int.parse).toList(),
    );
  }
}

class ChallengeStepOptions extends ChallengeStep {
  final Map<String, int> options;

  const ChallengeStepOptions(
    super.text,
    this.options, {
    super.next,
    super.alternatives,
    super.isLast = false,
  }) : super(hasNextButton: false);

  Map<String, dynamic> toJson() {
    return {
      'type': 'options',
      'text': text,
      'options': jsonEncode(options),
      'next': next,
      'alternatives': alternatives?.map((e) => e.toString()).join(','),
      'isLast': isLast,
    };
  }

  factory ChallengeStepOptions.fromJson(Map<String, dynamic> json) {
    return ChallengeStepOptions(
      json['text'] as String,
      (jsonDecode(json['options'] as String) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value)),
      next: json['next'] as int?,
      alternatives:
          (json['alternatives'] as String?)?.split(',').map(int.parse).toList(),
      isLast: json['isLast'] as int == 1,
    );
  }
}

class ChallengeStepStringInput extends ChallengeStep {
  final String correctAnswer;
  final int indexOnIncorrect;

  const ChallengeStepStringInput(
    super.text,
    this.correctAnswer,
    this.indexOnIncorrect, {
    super.next,
    super.alternatives,
    super.isLast = false,
  }) : super(hasNextButton: false);

  Map<String, dynamic> toJson() {
    return {
      'type': 'stringInput',
      'text': text,
      'correctAnswer': correctAnswer,
      'indexOnIncorrect': indexOnIncorrect,
      'next': next,
      'alternatives': alternatives?.map((e) => e.toString()).join(','),
      'isLast': isLast,
    };
  }

  factory ChallengeStepStringInput.fromJson(Map<String, dynamic> json) {
    return ChallengeStepStringInput(
      json['text'] as String,
      json['correctAnswer'] as String,
      json['indexOnIncorrect'] as int,
      next: json['next'] as int?,
      alternatives:
          (json['alternatives'] as String?)?.split(',').map(int.parse).toList(),
      isLast: json['isLast'] as int == 1,
    );
  }
}

class ChallengeStepScan extends ChallengeStep {
  final String correctAnswer;

  const ChallengeStepScan(
    super.text,
    this.correctAnswer, {
    super.next,
    super.alternatives,
    super.isLast = false,
  }) : super(hasNextButton: false);

  Map<String, dynamic> toJson() {
    return {
      'type': 'scan',
      'text': text,
      'correctAnswer': correctAnswer,
      'next': next,
      'alternatives': alternatives?.map((e) => e.toString()).join(','),
      'isLast': isLast,
    };
  }

  factory ChallengeStepScan.fromJson(Map<String, dynamic> json) {
    return ChallengeStepScan(
      json['text'] as String,
      json['correctAnswer'] as String,
      next: json['next'] as int?,
      alternatives:
          (json['alternatives'] as String?)?.split(',').map(int.parse).toList(),
      isLast: json['isLast'] as int == 1,
    );
  }
}
