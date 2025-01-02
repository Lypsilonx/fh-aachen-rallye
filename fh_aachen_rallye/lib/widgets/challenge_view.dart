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

  List<String> options = [];

  int? shuffleSource;
  int? shuffleExit;
  List<int> shuffleTargets = [];

  final ScrollController scrollController = ScrollController();

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
      ChallengeState? challengeState =
          object.challengeStates[challenge.challengeId];
      setState(() {
        currentStep = challengeState?.step ?? -1;
        shuffleSource = challengeState?.shuffleSource;
        if (shuffleSource != null) {
          shuffleExit = challenge.steps[shuffleSource!].shuffleExit;
        }
        shuffleTargets = challengeState?.shuffleTargets ?? [];
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

  void gotoStep(int step, {bool shuffle = false}) {
    if (!(step < 0 || step >= challenge.steps.length)) {
      ChallengeStep challengeStep = challenge.steps[step];

      if (challengeStep.alternatives != null &&
          challengeStep.alternatives!.isNotEmpty) {
        if (challengeStep.shuffleAlternatives) {
          if (shuffleExit == null) {
            shuffleSource = step;
            shuffleExit = challengeStep.shuffleExit;
            shuffleTargets =
                ([0, ...challengeStep.alternativesInt]).toSet().toList();
            shuffle = true;
          }
        } else {
          // Randomly select one of the alternatives or the original step
          var possibleSteps =
              ([0, ...challengeStep.alternativesInt]).toSet().toList();
          step = possibleSteps[Random().nextInt(possibleSteps.length)] + step;
        }
      }

      if (shuffle && shuffleExit != null) {
        if (shuffleTargets.isEmpty) {
          step = shuffleExit!;
          shuffleSource = null;
          shuffleExit = null;
        } else {
          step = shuffleTargets[Random().nextInt(shuffleTargets.length)] +
              shuffleSource!;
          shuffleTargets.remove(step - shuffleSource!);
        }
      }
    }

    setState(() {
      options = [];
      scrollController.jumpTo(0);
      currentStep = step;
      Backend.setChallengeState(challenge.challengeId,
          ChallengeState(currentStep, shuffleSource, shuffleTargets));
    });
  }

  void proceedStep(int step) {
    gotoStep(currentStep + step, shuffle: step == 0);
  }

  @override
  Widget build(BuildContext context) {
    final step = currentStep < 0 || currentStep >= challenge.steps.length
        ? const ChallengeStepSay("Current step is out of bounds.")
        : challenge.steps[currentStep];

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: constraints.maxWidth * challenge.progress,
                      height: Sizes.small,
                      color: challenge.progress == 1
                          ? Colors.green
                          : challenge.category.color.inverted(),
                    ),
                  ],
                ),
              ),
              Helpers.tiledBackground(
                "assets/background_1.png",
                200,
                challenge.category.color,
                stackChildren: [
                  Helpers.intelligentPadding(
                    context,
                    SizedBox(
                      width: double.infinity,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          EdgeInsetsGeometry tableEdgeInsets =
                              const EdgeInsets.all(
                            Sizes.small,
                          );

                          return SingleChildScrollView(
                            controller: scrollController,
                            scrollDirection: Axis.vertical,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: isNew || isCompleted
                                    ? [
                                        FunContainer(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                    Sizes.small),
                                                width: double.infinity,
                                                child: MdText(
                                                  isNew
                                                      ? challenge
                                                          .descriptionStart
                                                      : challenge
                                                          .descriptionEnd,
                                                  //style: Styles.body,
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      isNew ? Sizes.large : 0),
                                              if (isNew)
                                                Table(
                                                  border: const TableBorder(
                                                    verticalInside: BorderSide(
                                                      color: Colors.grey,
                                                      width: 0.2,
                                                    ),
                                                    horizontalInside:
                                                        BorderSide(
                                                      color: Colors.grey,
                                                      width: 0.2,
                                                    ),
                                                  ),
                                                  children: [
                                                    TableRow(
                                                      children: [
                                                        Tooltip(
                                                          message: translate(
                                                              challenge.category
                                                                  .description),
                                                          child: Padding(
                                                            padding:
                                                                tableEdgeInsets,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  translate(
                                                                      'CATEGORY'),
                                                                  style: Styles
                                                                      .subtitle,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      challenge
                                                                          .category
                                                                          .icon,
                                                                      color: challenge
                                                                          .category
                                                                          .color,
                                                                    ),
                                                                    const SizedBox(
                                                                        width: Sizes
                                                                            .small),
                                                                    Text(
                                                                      translate(challenge
                                                                          .category
                                                                          .name),
                                                                      style: Styles
                                                                          .body,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              tableEdgeInsets,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                translate(
                                                                    'DURATION'),
                                                                style: Styles
                                                                    .subtitle,
                                                              ),
                                                              Text(
                                                                translate(
                                                                    'DURATION_${challenge.duration.name.toUpperCase()}'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      children: [
                                                        Tooltip(
                                                          message: translate(
                                                              'DIFFICULTY_${challenge.difficulty.name.toUpperCase()}'),
                                                          child: Padding(
                                                            padding:
                                                                tableEdgeInsets,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  translate(
                                                                      'DIFFICULTY'),
                                                                  style: Styles
                                                                      .subtitle,
                                                                ),
                                                                Helpers.displayDifficulty(
                                                                    challenge
                                                                        .difficulty),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              tableEdgeInsets,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                translate(
                                                                    'POINTS'),
                                                                style: Styles
                                                                    .subtitle,
                                                              ),
                                                              Text(
                                                                  '${challenge.points}'),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(
                                                  height: Sizes.small),
                                              Helpers.displayTags(challenge),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            const SizedBox(
                                              height: Sizes.small,
                                            ),
                                            FunButton(
                                              isNew
                                                  ? translate('START')
                                                  : translate('RESTART'),
                                              Colors.green,
                                              onPressed: () => proceedStep(1),
                                            ),
                                            const SizedBox(
                                              height: Sizes.extraSmall,
                                            ),
                                          ],
                                        ),
                                      ]
                                    : [
                                        generateChatBubbles(step.text),
                                        const SizedBox(
                                          height: Sizes.large,
                                        ),
                                        Column(
                                          children: [
                                            if (step is ChallengeStepOptions)
                                              Column(
                                                children: options
                                                    .map((option) => Column(
                                                          children: [
                                                            const SizedBox(
                                                                height: Sizes
                                                                    .small),
                                                            FunButton(
                                                              option,
                                                              Colors.blue,
                                                              onPressed: () =>
                                                                  proceedStep(step
                                                                          .options[
                                                                      option]!),
                                                            ),
                                                          ],
                                                        ))
                                                    .toList(),
                                              ),
                                            if (step
                                                is ChallengeStepStringInput)
                                              Column(
                                                children: [
                                                  FunTextInput(
                                                    submitButton:
                                                        translate('SUBMIT'),
                                                    onSubmitted: (value) {
                                                      if (step.correctAnswer
                                                          .split(',')
                                                          .map((e) =>
                                                              e.toLowerCase())
                                                          .contains(value
                                                              .toLowerCase())) {
                                                        nextStep(step);
                                                      } else {
                                                        proceedStep(step
                                                            .indexOnIncorrect);
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
                                                  var value =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ScanQRCodeView(
                                                        acceptRegex: step
                                                            .correctAnswer
                                                            .replaceAll(
                                                                ',', '|'),
                                                        manualInput: translate(
                                                            'ENTER_CODE'),
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
                                                  step.isLast
                                                      ? Colors.green
                                                      : Colors.orange,
                                                  sizeFactor:
                                                      step.isLast ? 1.5 : -1,
                                                  onPressed: () =>
                                                      nextStep(step)),
                                            const SizedBox(
                                              height: Sizes.extraSmall,
                                            ),
                                          ],
                                        ),
                                      ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget generateChatBubbles(String text) {
    var chatBubbles = <Widget>[];

    var segments = text.split('\n\n\n');
    for (var i = 0; i < segments.length; i++) {
      var segment = segments[i];
      var bubble = generateChatBubble(segment);
      chatBubbles.add(bubble);
      if (i < segments.length - 1) {
        chatBubbles.add(const SizedBox(height: Sizes.medium));
      }
    }

    return Column(
      children: chatBubbles,
    );
  }

  Widget generateChatBubble(String text) {
    text = text.replaceAllMapped(RegExp(r'!\[([^\]]*)\]\(([^)]*)\)'), (match) {
      return '![${match.group(1)}](${Backend.url}/api/resources/data/images/${match.group(2)})';
    });

    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: FunContainer(
        expand: false,
        padding: const EdgeInsets.all(
          Sizes.medium,
        ),
        rounded: const RoundedSides(
          bottomLeft: false,
        ),
        child: MdText(text, style: Styles.body),
      ),
    );
  }
}
