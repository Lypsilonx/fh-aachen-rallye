import 'dart:math';

import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_app_bar.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_text_input.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:fh_aachen_rallye/widgets/scan_qr_code_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChallengeView extends StatefulWidget {
  const ChallengeView(this.challengeId, {super.key});

  final String challengeId;

  @override
  ChallengeViewState createState() => ChallengeViewState();
}

class ChallengeViewState extends TranslatedState<ChallengeView>
    implements ServerObjectSubscriber {
  int currentStep = 0;

  late Challenge challenge;
  late SharedPreferences prefs;

  bool get isCompleted => currentStep == -2;
  bool get isNew => currentStep == -1;

  var options = [];

  @override
  void initState() {
    super.initState();
    SubscriptionManager.subscribe<Challenge>(this, widget.challengeId);
    SubscriptionManager.subscribe<User>(this, Backend.userId!);
  }

  @override
  void dispose() {
    SubscriptionManager.unsubscribe(this);
    super.dispose();
  }

  @override
  void onUpdate(ServerObject object) {
    if (object is Challenge) {
      setState(() {
        challenge = object;
      });
    } else if (object is User) {
      setState(() {
        currentStep = object.challengeStates[challenge.challengeId] ?? -1;
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
    if (!(step < 0 || step >= challenge.steps.length)) {
      ChallengeStep challengeStep = challenge.steps[step];
      if (challengeStep.alternatives != null &&
          challengeStep.alternatives!.isNotEmpty) {
        // Randomly select one of the alternatives or the original step
        var possibleSteps =
            ([step, ...challengeStep.alternatives!]).toSet().toList();
        step = possibleSteps[Random().nextInt(possibleSteps.length)];
      }
    }

    setState(() {
      currentStep = step;
      Backend.setChallengeState(challenge.challengeId, currentStep);
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

    if (step is ChallengeStepOptions) {
      if (options.isEmpty) {
        options = step.options.keys.toList();
        options.shuffle();
      }
    } else {
      options = [];
    }

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
                                            translate('CATEGORY'),
                                            style: Styles.subtitle,
                                          ),
                                        ),
                                        Padding(
                                          padding: tableEdgeInsets,
                                          child: Text(
                                            translate('DIFFICULTY'),
                                            style: Styles.subtitle,
                                          ),
                                        ),
                                        Padding(
                                          padding: tableEdgeInsets,
                                          child: Text(
                                            translate('POINTS'),
                                            style: Styles.subtitle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Tooltip(
                                          message: translate(
                                              challenge.category.description),
                                          child: Padding(
                                            padding: tableEdgeInsets,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  challenge.category.icon,
                                                  color:
                                                      challenge.category.color,
                                                ),
                                                const SizedBox(
                                                    width: Sizes.small),
                                                Text(
                                                  translate(
                                                      challenge.category.name),
                                                  style: Styles.body,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: translate(
                                              'DIFFICULTY_${challenge.difficulty.name.toUpperCase()}'),
                                          child: Padding(
                                            padding: tableEdgeInsets,
                                            child: Helpers.displayDifficulty(
                                                challenge.difficulty),
                                          ),
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
                          isNew ? translate('START') : translate('RESTART'),
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
                            children: options
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
                                submitButton: translate('SUBMIT'),
                                onSubmitted: (value) {
                                  if (step.correctAnswer
                                      .split(',')
                                      .contains(value)) {
                                    nextStep(step);
                                  } else {
                                    proceedStep(step.indexOnIncorrect);
                                  }
                                },
                              ),
                            ],
                          ),
                        if (step is ChallengeStepScan)
                          FunButton(
                            translate('SCAN'),
                            Colors.blue,
                            onPressed: () async {
                              var value = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScanQRCodeView(
                                    acceptRegex:
                                        step.correctAnswer.replaceAll(',', '|'),
                                    manualInput: translate('ENTER_CODE'),
                                  ),
                                ),
                              );
                              if (value != null) {
                                if (step.correctAnswer
                                    .split(',')
                                    .contains(value)) {
                                  nextStep(step);
                                }
                              }
                            },
                          ),
                        if (step.hasNextButton)
                          FunButton(
                              step.isLast
                                  ? "${translate('COMPLETE')} (+${challenge.points} ${translate('POINTS')})"
                                  : translate('NEXT'),
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
