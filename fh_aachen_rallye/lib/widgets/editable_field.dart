import 'package:fh_aachen_rallye/fun_ui/fun_text_input.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:flutter/material.dart';

class EditableField extends StatefulWidget {
  final String label;
  final String value;
  final bool isPassword;
  final void Function(String) onChanged;

  const EditableField(
    this.label,
    this.value,
    this.onChanged, {
    this.isPassword = false,
    super.key,
  });

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends TranslatedState<EditableField> {
  late TextEditingController controller;
  late TextEditingController passwordController;

  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
    passwordController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Styles.h2),
        const SizedBox(height: Sizes.small),
        if (widget.isPassword)
          FunTextInput(
            autofocus: false,
            obscureText: true,
            controller: passwordController,
            onSubmitted: (value) {
              focusNode.requestFocus();
            },
          ),
        if (widget.isPassword) const SizedBox(height: Sizes.small),
        FunTextInput(
          autofocus: false,
          obscureText: widget.isPassword,
          controller: controller,
          focusNode: focusNode,
          onSubmitted: (value) {
            if (widget.isPassword && controller.text != value) {
              Helpers.showSnackBar(context, translate('PASSWORD_MISSMATCH'));
              return;
            }
            widget.onChanged(value);
            Helpers.showSnackBar(
              context,
              translate('FIELD_UPDATED', args: [
                widget.label,
              ]),
            );
            if (widget.isPassword) {
              controller.clear();
              passwordController.clear();
            }
          },
          submitButtonStyle: SubmitButtonStyle.right,
        ),
      ],
    );
  }
}
