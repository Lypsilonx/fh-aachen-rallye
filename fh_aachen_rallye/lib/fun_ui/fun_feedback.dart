import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:flutter/material.dart';

class FunFeedback extends StatefulWidget {
  const FunFeedback({
    required this.controller,
    required this.child,
    super.key,
  });

  final FunFeedbackController controller;
  final Widget child;

  @override
  FunFeedbackState createState() => FunFeedbackState();
}

class FunFeedbackState extends TranslatedState<FunFeedback>
    with TickerProviderStateMixin {
  late AnimationController errorController;
  late AnimationController successController;

  @override
  void initState() {
    super.initState();

    errorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    errorController.addListener(() {
      setState(() {});
    });

    successController.addListener(() {
      setState(() {});
    });

    widget.controller.init(this);
  }

  Future<void> triggerError() async {
    successController.reset();
    await errorController.forward();
    await errorController.reverse();
    return;
  }

  Future<bool> triggerSuccess() async {
    errorController.reset();
    await successController.forward();
    await successController.reverse();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double errorCurveValue = CurveTween(
      curve: Curves.easeInOut,
    ).transform(errorController.value);
    double successCurveValue = CurveTween(
      curve: Curves.easeInOut,
    ).transform(successController.value);

    int errorBackgroundValue = (errorCurveValue * 128).toInt();
    int successBackgroundValue = (successCurveValue * 128).toInt();

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(errorBackgroundValue),
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(successBackgroundValue),
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Transform.rotate(
                angle: (-0.2 + successCurveValue * 0.25) * 3.1415,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(Sizes.medium),
                  ),
                  child: Icon(
                    Icons.check,
                    size: successCurveValue * Sizes.large,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(Sizes.medium),
                ),
                child: Icon(
                  Icons.close,
                  size: errorCurveValue * Sizes.large,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FunFeedbackController {
  late FunFeedbackState feedbackState;

  void init(FunFeedbackState feedbackState) {
    this.feedbackState = feedbackState;
  }

  Future<void> triggerError() {
    return feedbackState.triggerError();
  }

  Future<void> triggerSuccess() {
    return feedbackState.triggerSuccess();
  }
}
