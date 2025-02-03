import 'dart:math';

import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_feedback.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_text_input.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/widgets/scan_qr_code_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageChallengeView extends FunPage {
  final String challengeId;
  const PageChallengeView({
    this.challengeId = '',
    super.key,
  });

  @override
  String get title => 'CHALLENGE';

  @override
  String get navPath => '/challenge';

  @override
  IconData? get footerIcon => null;

  @override
  String get tileAssetPath => 'assets/background_1.png';

  @override
  double get tileSize => 200;

  @override
  Color get color => Colors.red;

  @override
  State<PageChallengeView> createState() => _PageChallengeViewState();
}

class _PageChallengeViewState extends FunPageState<PageChallengeView>
    implements ServerObjectSubscriber {
  int currentStep = 0;

  late Challenge challenge;
  late SharedPreferences prefs;

  bool get isCompleted => currentStep == -2;
  bool get isNew => currentStep == -1;

  List<String> options = [];

  bool locked = false;

  int? shuffleSource;
  int? shuffleExit;
  List<int> shuffleTargets = [];
  List<int> otherShuffleTargets = [];
  String stringInputHint = "";
  String get stringInputHintText =>
      stringInputHint.contains('|') ? stringInputHint.split('|')[1] : "";
  int get stringInputHintStepIndex => stringInputHint.split('|')[0] == ""
      ? -1
      : int.parse(stringInputHint.split('|')[0]);

  final ScrollController scrollController = ScrollController();
  final TextEditingController stringInputController = TextEditingController();
  late FocusNode stringInputFocusNode;

  final FunFeedbackController feedbackController = FunFeedbackController();
  final List<FunFeedbackController> buttonFeedbacks = [];

  @override
  String get finishedTitle => challenge.title;

  @override
  Color get color => challenge.category.color;

  @override
  void initState() {
    super.initState();
    SubscriptionManager.subscribe<Challenge>(this, widget.challengeId);
    SubscriptionManager.subscribe<User>(this, Backend.userId!);
    stringInputFocusNode = FocusNode();

    if (challenge.userStatus != ChallengeUserStatus.none) {
      Backend.setChallengeStatus(
          challenge.challengeId, ChallengeUserStatus.none);
    }
  }

  @override
  void dispose() {
    SubscriptionManager.unsubscribe(this);
    stringInputFocusNode.dispose();
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
        otherShuffleTargets = challengeState?.otherShuffleTargets ?? [];
        stringInputHint = challengeState?.stringInputHint ?? "";
      });
    }
  }

  // TEMP
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

  void proceedStep(int step) {
    gotoStep(currentStep + step, shuffle: step == 0);
  }

  void gotoStep(int step, {bool shuffle = false}) {
    if (!(step < 0 || step >= challenge.steps.length)) {
      bool repeat = true;
      while (repeat) {
        repeat = false;
        ChallengeStep challengeStep = challenge.steps[step];
        if (challengeStep.alternatives != null &&
            challengeStep.alternatives!.isNotEmpty) {
          if (shuffleExit == null) {
            shuffleSource = step;
            shuffleExit = challengeStep.shuffleExit;
            shuffleTargets =
                ([0, ...challengeStep.alternativesInt]).toSet().toList();
            shuffleTargets.shuffle();
            shuffleTargets =
                shuffleTargets.take(challengeStep.shuffleAmount!).toList();
            otherShuffleTargets = challengeStep.alternativesInt
                .where((element) => !shuffleTargets.contains(element))
                .toList();

            shuffle = true;
          }
        }

        if (shuffle && shuffleExit != null) {
          if (shuffleTargets.isEmpty) {
            step = shuffleSource! + shuffleExit!;
            shuffleSource = null;
            shuffleExit = null;
            repeat = true;
          } else {
            step = shuffleTargets[Random().nextInt(shuffleTargets.length)] +
                shuffleSource!;
            shuffleTargets.remove(step - shuffleSource!);
          }
        }
      }
    }

    setState(() {
      options = [];
      scrollController.jumpTo(0);
      stringInputController.clear();
      currentStep = step;
      if (currentStep >= 0 &&
          challenge.steps[currentStep] is ChallengeStepStringInput &&
          stringInputHintStepIndex != currentStep) {
        stringInputHint = "";
      }
      // if (currentStep >= 0 &&
      //     challenge.steps[currentStep] is ChallengeStepStringInput) {
      //   stringInputFocusNode.requestFocus();
      // }
      saveState();
    });
  }

  void saveState() {
    Backend.setChallengeState(
      challenge,
      ChallengeState(
        currentStep,
        shuffleSource,
        shuffleTargets,
        otherShuffleTargets,
        stringInputHint,
        ChallengeUserStatus.none,
      ),
    );
  }

  bool canBuyHint() {
    if (challenge.steps[currentStep] is! ChallengeStepStringInput) {
      return false;
    }
    var challengeStep =
        challenge.steps[currentStep] as ChallengeStepStringInput;
    var correctAnswers = challengeStep.correctAnswer.split(',');
    var correctAnswer = correctAnswers[0];

    if (stringInputHintText == correctAnswer) {
      return false;
    }

    return true;
  }

  void buyHint() async {
    if (!canBuyHint()) {
      return;
    }

    var challengeStep =
        challenge.steps[currentStep] as ChallengeStepStringInput;
    var correctAnswers = challengeStep.correctAnswer.split(',');
    var correctAnswer = correctAnswers[0];

    var (success, message) = await Backend.payPoints(challengeStep.hintCost);
    if (!success) {
      Helpers.showSnackBar(context, message);
      return;
    }

    if (stringInputHintText.isEmpty) {
      stringInputHint =
          "$currentStep|${correctAnswer.replaceAll(RegExp(r'[^ ]'), '_')}";
    }

    // reveal one more character
    var possibleIndices = <int>[];
    for (var i = 0; i < stringInputHintText.length; i++) {
      if (stringInputHintText[i] == '_') {
        possibleIndices.add(i);
      }
    }

    var index = possibleIndices[Random().nextInt(possibleIndices.length)];
    stringInputHint =
        "$currentStep|${stringInputHintText.substring(0, index) + correctAnswer[index] + stringInputHintText.substring(index + 1)}";

    saveState();
    setState(() {});
  }

  @override
  List<Widget> buildOverlay(BuildContext context) {
    return [
      LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
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
          );
        },
      ),
    ];
  }

  @override
  Widget buildPage(BuildContext context) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        EdgeInsetsGeometry tableEdgeInsets = const EdgeInsets.all(
          Sizes.small,
        );

        return SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: isNew || isCompleted
                  ? [
                      FunContainer(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(Sizes.small),
                              width: double.infinity,
                              child: MdText(
                                isNew
                                    ? challenge.descriptionStart
                                    : challenge.descriptionEnd,
                                //style: Styles.body,
                              ),
                            ),
                            SizedBox(height: isNew ? Sizes.large : 0),
                            if (isNew)
                              Table(
                                border: const TableBorder(
                                  verticalInside: BorderSide(
                                    color: Colors.grey,
                                    width: 0.2,
                                  ),
                                  horizontalInside: BorderSide(
                                    color: Colors.grey,
                                    width: 0.2,
                                  ),
                                ),
                                children: [
                                  TableRow(
                                    children: [
                                      Tooltip(
                                        message: translate(
                                            challenge.category.description),
                                        child: Padding(
                                          padding: tableEdgeInsets,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                translate('CATEGORY'),
                                                style: Styles.subtitle,
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    challenge.category.icon,
                                                    color: challenge
                                                        .category.color,
                                                  ),
                                                  const SizedBox(
                                                      width: Sizes.small),
                                                  Text(
                                                    translate(challenge
                                                        .category.name),
                                                    style: Styles.body,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: tableEdgeInsets,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              translate('DURATION'),
                                              style: Styles.subtitle,
                                            ),
                                            Text(
                                              translate(
                                                  'DURATION_${challenge.duration.description}',
                                                  args:
                                                      challenge.duration.args),
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
                                          padding: tableEdgeInsets,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                translate('DIFFICULTY'),
                                                style: Styles.subtitle,
                                              ),
                                              Helpers.displayDifficulty(
                                                  challenge.difficulty),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: tableEdgeInsets,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              translate('POINTS'),
                                              style: Styles.subtitle,
                                            ),
                                            Text('${challenge.points}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            if (isNew) const SizedBox(height: Sizes.small),
                            if (isNew)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return Helpers.displayTags(
                                    challenge,
                                    constraints.maxWidth,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: Sizes.small,
                          ),
                          FunButton(
                            isNew ? translate('START') : translate('RESTART'),
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
                              children: options.indexed.map((item) {
                                var index = item.$1;
                                var option = item.$2;
                                while (buttonFeedbacks.length <= index) {
                                  buttonFeedbacks.add(FunFeedbackController());
                                }
                                var buttonFeedback = buttonFeedbacks[index];
                                return Column(
                                  children: [
                                    const SizedBox(height: Sizes.small),
                                    FunFeedback(
                                      controller: buttonFeedback,
                                      child: FunButton(
                                        option,
                                        Colors.blue,
                                        onPressed: () {
                                          if (locked) {
                                            return;
                                          }

                                          var nextStep = step.options[option]!;
                                          locked = true;
                                          if (challenge.steps[nextStep].next
                                                  ?.isNegative ??
                                              false) {
                                            buttonFeedback
                                                .triggerError()
                                                .then((_) {
                                              locked = false;
                                              proceedStep(nextStep);
                                            });
                                          } else {
                                            buttonFeedback
                                                .triggerSuccess()
                                                .then((_) {
                                              locked = false;
                                              proceedStep(nextStep);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          if (step is ChallengeStepStringInput)
                            Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      stringInputHintText,
                                      style: Styles.h1.copyWith(
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    FunButton(
                                      translate('BUY_HINT',
                                          args: [step.hintCost.toString()]),
                                      Colors.green,
                                      expand: false,
                                      isEnabled: canBuyHint,
                                      onPressed: buyHint,
                                    )
                                  ],
                                ),
                                const SizedBox(height: Sizes.medium),
                                FunFeedback(
                                  controller: feedbackController,
                                  child: FunTextInput(
                                    autofocus: false,
                                    controller: stringInputController,
                                    focusNode: stringInputFocusNode,
                                    submitButtonStyle: SubmitButtonStyle.right,
                                    submitButtonText: translate('SUBMIT'),
                                    onSubmitted: (value) {
                                      if (locked) {
                                        return;
                                      }

                                      if (step.correctAnswer
                                          .split(',')
                                          .map(
                                            (e) => e.trim().toLowerCase(),
                                          )
                                          .contains(
                                            value.trim().toLowerCase(),
                                          )) {
                                        locked = true;
                                        feedbackController
                                            .triggerSuccess()
                                            .then(
                                          (_) {
                                            locked = false;
                                            nextStep(step);
                                          },
                                        );
                                      } else {
                                        locked = true;
                                        feedbackController.triggerError().then(
                                          (_) {
                                            locked = false;
                                            proceedStep(step.indexOnIncorrect);
                                          },
                                        );
                                      }
                                    },
                                  ),
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
                                      acceptRegex: step.correctAnswer
                                          .replaceAll(',', '|'),
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
                                    : (step.next ?? 0) < 0
                                        ? translate('BACK')
                                        : translate('NEXT'),
                                step.isLast ? Colors.green : Colors.orange,
                                sizeFactor: step.isLast ? 1.5 : -1,
                                onPressed: () => nextStep(step)),
                          if (otherShuffleTargets.isNotEmpty)
                            const SizedBox(
                              height: Sizes.medium,
                            ),
                          if (otherShuffleTargets.isNotEmpty &&
                              step is ChallengeStepStringInput)
                            FunButton(
                              translate('BUY_OTHER_QUESTION', args: ["10"]),
                              Colors.red,
                              onPressed: () async {
                                var (success, message) =
                                    await Backend.payPoints(10);
                                if (!success) {
                                  Helpers.showSnackBar(context, message);
                                  return;
                                }
                                var newTarget = otherShuffleTargets.removeAt(0);
                                gotoStep(newTarget);
                                saveState();
                              },
                            ),
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
