import 'dart:convert';

import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:flutter/material.dart';

class Challenge extends ServerObject {
  final String challengeId;
  final String title;
  final Language language;
  final ChallengeDifficulty difficulty;
  final List<String> tags;
  final ChallengeDuration duration;
  final int points;
  final ChallengeCategory category;
  final String descriptionStart;
  final String descriptionEnd;
  final List<ChallengeStep> steps;

  ChallengeState? get state {
    if (Backend.state.user == null) {
      return null;
    }

    return Backend.state.user!.challengeStates[challengeId];
  }

  ChallengeUserStatus get userStatus {
    if (state == null) {
      return ChallengeUserStatus.new_;
    }

    return state!.userStatus;
  }

  double get progress {
    if (state == null) {
      return 0;
    }

    if (state!.step == -1) {
      return 0;
    } else if (state!.step == -2) {
      return 1;
    }

    List<int> stepValues = steps
        .map((element) => (element.next == null || element.next! >= 0) ? 1 : 0)
        .toList();

    for (int i = 0; i < steps.length; i++) {
      ChallengeStep cStep = steps[i];
      if (cStep.alternativesInt.isNotEmpty && !cStep.shuffleAlternatives) {
        for (int alternative in cStep.alternativesInt) {
          stepValues[alternative + i] = 0;
        }
      }
    }

    int totalSteps = stepValues.sum();

    if (state!.shuffleSource != null) {
      ChallengeStep cStep = steps[state!.shuffleSource!];
      int completedStepsBeforeShuffle =
          stepValues.take(state!.shuffleSource!).sum();

      int completedStepsAfterShuffle =
          stepValues.take(cStep.shuffleExit!).sum();

      double shuffleProgress = 1 -
          (state!.shuffleTargets.length / (cStep.alternativesInt.length + 1));

      return (completedStepsBeforeShuffle +
              (completedStepsAfterShuffle - completedStepsBeforeShuffle) *
                  shuffleProgress) /
          totalSteps;
    }

    int completedSteps = stepValues.take(state!.step + 1).sum();

    return completedSteps / totalSteps;
  }

  final String? image;

  const Challenge(
    super.id, {
    required this.challengeId,
    required this.title,
    required this.language,
    required this.difficulty,
    required this.tags,
    required this.duration,
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
      difficulty: ChallengeDifficulty.none,
      tags: [],
      duration: ChallengeDuration.none,
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
      'tags': tags.join(','),
      'duration': duration.index,
      'category': category.categoryName(),
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
      difficulty: ChallengeDifficulty.values[json['difficulty'] as int],
      tags: json['tags'] == null
          ? []
          : (json['tags'] as String).split(',').toList(),
      duration: ChallengeDuration.values[json['duration'] as int],
      category: ChallengeCategory.fromString(json['category'] as String),
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

class ChallengeUserStatus {
  final String badgeMessage;
  final int value;

  factory ChallengeUserStatus.fromInt(int status) {
    return switch (status) {
      -1 => ChallengeUserStatus.none,
      0 => ChallengeUserStatus.new_,
      1 => ChallengeUserStatus.unlocked,
      _ => throw Exception('Invalid status: $status'),
    };
  }

  const ChallengeUserStatus(this.value, this.badgeMessage);

  static const ChallengeUserStatus none = ChallengeUserStatus(
    -1,
    'STATUS_NONE',
  );

  static const ChallengeUserStatus new_ = ChallengeUserStatus(
    0,
    'STATUS_NEW',
  );

  static const ChallengeUserStatus unlocked = ChallengeUserStatus(
    1,
    'STATUS_UNLOCKED',
  );

  @override
  bool operator ==(Object other) {
    return other is ChallengeUserStatus && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class ChallengeCategory {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const ChallengeCategory(this.name, this.description, this.icon,
      {this.color = Colors.orange});

  static ChallengeCategory fromString(String name) {
    return switch (name) {
      'tutorial' => ChallengeCategory.tutorial,
      'general' => ChallengeCategory.general,
      'electricalEngineering' => ChallengeCategory.electricalEngineering,
      'maths' => ChallengeCategory.maths,
      _ => ChallengeCategory.loading,
    };
  }

  String categoryName() {
    return switch (name) {
      'CATEGORY_TUTORIAL' => 'tutorial',
      'CATEGORY_GENERAL' => 'general',
      'CATEGORY_ELECTRICAL_ENGINEERING' => 'electricalEngineering',
      'CATEGORY_MATHS' => 'maths',
      _ => 'loading',
    };
  }

  static const double _saturation = 0.9;

  static const ChallengeCategory loading = ChallengeCategory(
    "LOADING",
    "LOADING",
    Icons.hourglass_empty,
    color: Colors.grey,
  );

  static ChallengeCategory tutorial = ChallengeCategory(
    "CATEGORY_TUTORIAL",
    "CATEGORY_TUTORIAL_DESCRIPTION",
    Icons.school,
    color: Colors.blue.withSaturation(_saturation),
  );

  static ChallengeCategory general = ChallengeCategory(
    "CATEGORY_GENERAL",
    "CATEGORY_GENERAL_DESCRIPTION",
    Icons.lightbulb,
    color: Colors.yellow.withSaturation(_saturation),
  );

  static ChallengeCategory electricalEngineering = ChallengeCategory(
    "CATEGORY_ELECTRICAL_ENGINEERING",
    "CATEGORY_ELECTRICAL_ENGINEERING_DESCRIPTION",
    Icons.bolt,
    color: Colors.orange.withSaturation(_saturation),
  );

  static ChallengeCategory maths = ChallengeCategory(
    "CATEGORY_MATHS",
    "CATEGORY_MATHS_DESCRIPTION",
    Icons.calculate,
    color: Colors.red.withSaturation(_saturation),
  );
}

abstract class ChallengeStep {
  final String text;
  final int? next;
  final String? alternatives;
  final bool isLast;

  final bool hasNextButton;

  List<int> get alternativesInt {
    if (alternatives == null) {
      return [];
    }

    String alternativesWithoutShuffle = alternatives!.contains("s")
        ? alternatives!.substring(0, alternatives!.indexOf("s"))
        : alternatives!;

    return alternativesWithoutShuffle.split(',').map(int.parse).toList();
  }

  bool get shuffleAlternatives {
    return alternatives != null && alternatives!.contains("s");
  }

  int? get shuffleExit {
    if (alternatives == null) {
      return null;
    }

    if (alternatives!.contains("s")) {
      return int.parse(alternatives!.substring(alternatives!.indexOf("s") + 1));
    } else {
      return null;
    }
  }

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

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'say',
      'text': text,
      'next': next,
      'alternatives': alternatives,
      'isLast': isLast,
    };
  }

  factory ChallengeStepSay.fromJson(Map<String, dynamic> json) {
    return ChallengeStepSay(
      json['text'] as String,
      next: json['next'] as int?,
      isLast: json['isLast'] as int == 1,
      alternatives: (json['alternatives'] as String?),
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'options',
      'text': text,
      'options': jsonEncode(options),
      'next': next,
      'alternatives': alternatives,
      'isLast': isLast,
    };
  }

  factory ChallengeStepOptions.fromJson(Map<String, dynamic> json) {
    return ChallengeStepOptions(
      json['text'] as String,
      (jsonDecode(json['options'] as String) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value)),
      next: json['next'] as int?,
      alternatives: (json['alternatives'] as String?),
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'stringInput',
      'text': text,
      'correctAnswer': correctAnswer,
      'indexOnIncorrect': indexOnIncorrect,
      'next': next,
      'alternatives': alternatives,
      'isLast': isLast,
    };
  }

  factory ChallengeStepStringInput.fromJson(Map<String, dynamic> json) {
    return ChallengeStepStringInput(
      json['text'] as String,
      json['correctAnswer'] as String,
      json['indexOnIncorrect'] as int,
      next: json['next'] as int?,
      alternatives: (json['alternatives'] as String?),
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'scan',
      'text': text,
      'correctAnswer': correctAnswer,
      'next': next,
      'alternatives': alternatives,
      'isLast': isLast,
    };
  }

  factory ChallengeStepScan.fromJson(Map<String, dynamic> json) {
    return ChallengeStepScan(
      json['text'] as String,
      json['correctAnswer'] as String,
      next: json['next'] as int?,
      alternatives: (json['alternatives'] as String?),
      isLast: json['isLast'] as int == 1,
    );
  }
}
