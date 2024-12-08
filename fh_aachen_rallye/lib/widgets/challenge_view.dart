import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_app_bar.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_text_input.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChallengeView extends StatefulWidget {
  const ChallengeView(this.challengeId, {super.key});

  final String challengeId;

  @override
  ChallengeViewState createState() => ChallengeViewState();
}

class ChallengeViewState extends State<ChallengeView>
    implements ServerObjectSubscriber {
  int currentStep = 0;

  late Challenge challenge;
  late SharedPreferences prefs;

  bool get isCompleted => currentStep == -2;
  bool get isNew => currentStep == -1;

  @override
  void initState() {
    super.initState();
    SubscriptionManager.subscribe<Challenge>(this, widget.challengeId);
    SubscriptionManager.subscribe<User>(this, Backend.userId!);
  }

  @override
  void onUpdate(ServerObject object) {
    if (object is Challenge) {
      setState(() {
        challenge = object;
      });
    } else if (object is User) {
      setState(() {
        currentStep = object.challengeStates[widget.challengeId] ?? -1;
      });
    }
  }

  void nextStep(ChallengeStep? step) {
    if (step == null) {
      return;
    }

    if (step.isLast) {
      gotoStep(-2);
    } else {
      proceedStep(step.next ?? 1);
    }
  }

  void gotoStep(int step) {
    setState(() {
      currentStep = step;
      Backend.setChallengeState(challenge.id, currentStep);
    });
  }

  void proceedStep(int step) {
    gotoStep(currentStep + step);
  }

  @override
  Widget build(BuildContext context) {
    final step = currentStep < 0 || currentStep >= challenge.steps.length
        ? const ChallengeStepSay("Current step is out of bounds.")
        : challenge.steps[currentStep];

    EdgeInsetsGeometry tableEdgeInsets = const EdgeInsets.only(
      left: Sizes.small,
      top: Sizes.extraSmall,
      bottom: Sizes.extraSmall,
      right: Sizes.small,
    );

    return Scaffold(
      appBar: FunAppBar(
        challenge.category.color,
        title: Text(challenge.title, style: Styles.h1),
      ),
      body: Helpers.tiledBackground(
        "assets/background_1.png",
        200,
        challenge.category.color,
        stackChildren: [
          Helpers.intelligentPadding(
            context,
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: isNew || isCompleted
                    ? [
                        FunContainer(
                          child: Column(
                            children: [
                              Text(
                                isNew
                                    ? challenge.descriptionStart
                                    : challenge.descriptionEnd,
                                style: Styles.body,
                              ),
                              if (isNew) const SizedBox(height: Sizes.large),
                              if (isNew)
                                Table(
                                  border: const TableBorder(
                                    verticalInside:
                                        BorderSide(color: Colors.grey),
                                  ),
                                  children: [
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: tableEdgeInsets,
                                          child: Text(
                                            'Category',
                                            style: Styles.subtitle,
                                          ),
                                        ),
                                        Padding(
                                          padding: tableEdgeInsets,
                                          child: Text(
                                            'Difficulty',
                                            style: Styles.subtitle,
                                          ),
                                        ),
                                        Padding(
                                          padding: tableEdgeInsets,
                                          child: Text(
                                            'Points',
                                            style: Styles.subtitle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: tableEdgeInsets,
                                          child: Row(
                                            children: [
                                              Icon(
                                                challenge.category.icon,
                                                color: challenge.category.color,
                                              ),
                                              const SizedBox(
                                                  width: Sizes.small),
                                              Text(
                                                challenge.category.name,
                                                style: Styles.body,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: tableEdgeInsets,
                                          child: Helpers.displayDifficulty(
                                              challenge.difficulty),
                                        ),
                                        Padding(
                                          padding: tableEdgeInsets,
                                          child: Text('${challenge.points}'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        FunButton(
                          isNew ? 'Start' : 'Restart',
                          Colors.green,
                          onPressed: () => proceedStep(1),
                        ),
                      ]
                    : [
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: FunContainer(
                            expand: false,
                            padding: const EdgeInsets.all(Sizes.medium),
                            rounded: const RoundedSides(
                              bottomRight: false,
                            ),
                            child: Text(step.text),
                          ),
                        ),
                        if (step is ChallengeStepOptions)
                          Column(
                            children: step.options.keys
                                .map((option) => Column(
                                      children: [
                                        const SizedBox(height: Sizes.small),
                                        FunButton(
                                          option,
                                          Colors.blue,
                                          onPressed: () => proceedStep(
                                              step.options[option]!),
                                        ),
                                      ],
                                    ))
                                .toList(),
                          ),
                        if (step is ChallengeStepStringInput)
                          Column(
                            children: [
                              FunTextInput(
                                submitButton: 'Submit',
                                onSubmitted: (value) {
                                  if (value == step.correctAnswer) {
                                    nextStep(step);
                                  } else {
                                    proceedStep(step.indexOnIncorrect);
                                  }
                                },
                              ),
                            ],
                          ),
                        if (step.hasNextButton)
                          FunButton(
                              step.isLast
                                  ? 'Complete (+${challenge.points} Points)'
                                  : 'Next',
                              step.isLast ? Colors.green : Colors.orange,
                              sizeFactor: step.isLast ? 1.5 : -1,
                              onPressed: () => nextStep(step)),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
