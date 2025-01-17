import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:flutter/material.dart';

class FunDialog extends StatefulWidget {
  final String title;
  final String message;
  final List<(String, void Function(BuildContext context))> actions;
  final bool hasCancelButton;

  const FunDialog({
    this.title = '',
    this.message = '',
    this.actions = const [],
    this.hasCancelButton = true,
    super.key,
  });

  List<(String, void Function(BuildContext context))> actionWidgets(
      BuildContext context) {
    List<(String, void Function(BuildContext context))> actionMap =
        List.from(actions);
    if (hasCancelButton) {
      actionMap.insert(
        0,
        (
          'CANCEL',
          (context) {
            Navigator.of(context).pop();
          }
        ),
      );
    }
    return actionMap;
  }

  @override
  State<FunDialog> createState() => _FunDialogState();
}

class _FunDialogState extends TranslatedState<FunDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withAlpha(128),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          FunContainer(
            height: Sizes.extraLarge * 4,
            padding: const EdgeInsets.symmetric(vertical: Sizes.medium),
            rounded: const RoundedSides(
              topLeft: false,
              topRight: false,
              bottomLeft: false,
              bottomRight: false,
            ),
            child: Helpers.intelligentPadding(
              context,
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(translate(widget.title), style: Styles.h1),
                  const SizedBox(height: Sizes.medium),
                  Text(
                    translate(widget.message),
                    style: Styles.h2,
                  ),
                  const SizedBox(height: Sizes.medium),
                  Wrap(
                    children: widget
                        .actionWidgets(context)
                        .map<Widget>(
                          (entry) => FunButton(
                            translate(entry.$1),
                            entry.$1 == 'CANCEL' ? Colors.red : Colors.blue,
                            expand: false,
                            onPressed: () => entry.$2(context),
                          ),
                        )
                        .intersperse(const SizedBox(width: Sizes.medium))
                        .toList(),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
