import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_app_bar.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_text_input.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChallengeView extends StatefulWidget {
  final ChallengeViewController controller;
  final Function? onChallengeComplete;

  const ChallengeView(this.controller, {this.onChallengeComplete, super.key});

  @override
  ChallengeViewState createState() => ChallengeViewState();
}

class ChallengeViewState extends State<ChallengeView> {
  @override
  void initState() {
    super.initState();
    widget.controller.setup(this, setState);
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.controller.currentStep < 0 ||
            widget.controller.currentStep >=
                widget.controller.challenge.steps.length
        ? const ChallengeStepSay("Current step is out of bounds.")
        : widget.controller.challenge.steps[widget.controller.currentStep];

    EdgeInsetsGeometry tableEdgeInsets = const EdgeInsets.only(
      left: Sizes.small,
      top: Sizes.extraSmall,
      bottom: Sizes.extraSmall,
      right: Sizes.small,
    );

    return Scaffold(
      appBar: FunAppBar(
        widget.controller.challenge.category.color,
        title: Text(widget.controller.challenge.title, style: Styles.h1),
      ),
      body: Helpers.tiledBackground(
        "assets/background_1.png",
        200,
        widget.controller.challenge.category.color,
        stackChildren: [
          Helpers.intelligentPadding(
            context,
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: widget.controller.isNew ||
                        widget.controller.isCompleted
                    ? [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(Sizes.borderRadius),
                            ),
                            boxShadow: Helpers.boxShadow(Colors.white),
                          ),
                          padding: const EdgeInsets.all(Sizes.small),
                          child: Column(
                            children: [
                              Text(
                                widget.controller.isNew
                                    ? widget
                                        .controller.challenge.descriptionStart
                                    : widget
                                        .controller.challenge.descriptionEnd,
                                style: Styles.body,
                              ),
                              if (widget.controller.isNew)
                                const SizedBox(height: Sizes.large),
                              if (widget.controller.isNew)
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
                                                widget.controller.challenge
                                                    .category.icon,
                                                color: widget.controller
                                                    .challenge.category.color,
                                              ),
                                              const SizedBox(
                                                  width: Sizes.small),
                                              Text(
                                                widget.controller.challenge
                                                    .category.name,
                                                style: Styles.body,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: tableEdgeInsets,
                                          child: Helpers.displayDifficulty(
                                              widget.controller.challenge
                                                  .difficulty),
                                        ),
                                        Padding(
                                          padding: tableEdgeInsets,
                                          child: Text(
                                              '${widget.controller.challenge.points}'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        FunButton('Start', Colors.green,
                            onPressed: () => widget.controller.proceedStep(1)),
                      ]
                    : [
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.all(Sizes.small),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(Sizes.borderRadius),
                                topRight: Radius.circular(Sizes.borderRadius),
                                bottomLeft: Radius.circular(Sizes.borderRadius),
                              ),
                              boxShadow: Helpers.boxShadow(Colors.white),
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
                                          onPressed: () => widget.controller
                                              .proceedStep(
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
                                    widget.controller.nextStep(step);
                                  } else {
                                    widget.controller
                                        .proceedStep(step.indexOnIncorrect);
                                  }
                                },
                              ),
                            ],
                          ),
                        if (step.hasNextButton)
                          FunButton(
                              step.isLast
                                  ? 'Complete (+${widget.controller.challenge.points} Points)'
                                  : 'Next',
                              step.isLast ? Colors.green : Colors.orange,
                              sizeFactor: step.isLast ? 1.5 : -1,
                              onPressed: () =>
                                  widget.controller.nextStep(step)),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeViewController {
  int currentStep = 0;

  final Challenge challenge;
  final Function? onUpdate;

  late ChallengeViewState state;
  late Function setState;
  late SharedPreferences prefs;

  bool get isCompleted => currentStep == -2;
  bool get isNew => currentStep == -1;

  ChallengeViewController(this.challenge, {this.onUpdate}) {
    currentStep = Backend.getChallengeState(challenge);
  }

  void setup(ChallengeViewState state, Function setState) {
    this.state = state;
    this.setState = (args) {
      setState(args);
      if (onUpdate != null) {
        onUpdate!(() {});
      }
    };
  }

  void nextStep(ChallengeStep? step) {
    if (step == null) {
      return;
    }

    if (step.isLast) {
      gotoStep(-2);
      state.widget.onChallengeComplete?.call();
    } else {
      proceedStep(step.next ?? 1);
    }
  }

  void gotoStep(int step) {
    setState(() {
      currentStep = step;
      Backend.setChallengeState(challenge, currentStep);
    });
  }

  void proceedStep(int step) {
    gotoStep(currentStep + step);
  }
}
