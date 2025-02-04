import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class FunTextInput extends StatefulWidget {
  const FunTextInput({
    this.label,
    this.obscureText = false,
    this.autofocus = true,
    this.submitButtonStyle = SubmitButtonStyle.none,
    this.submitButtonText,
    this.submitButtonIcon,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    super.key,
  });

  final String? label;
  final bool obscureText;
  final bool autofocus;
  final SubmitButtonStyle submitButtonStyle;
  final String? submitButtonText;
  final IconData? submitButtonIcon;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  @override
  State<FunTextInput> createState() => _FunTextInputState();
}

class _FunTextInputState extends State<FunTextInput> {
  late TextEditingController controller =
      widget.controller ?? TextEditingController();
  late FocusNode focusNode = widget.focusNode ?? FocusNode();

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: widget.submitButtonStyle == SubmitButtonStyle.right
          ? Axis.horizontal
          : Axis.vertical,
      children: [
        Expanded(
          flex: widget.submitButtonStyle == SubmitButtonStyle.right ? 1 : 0,
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.all(
                Radius.circular(Sizes.borderRadius),
              ),
              boxShadow: Helpers.boxShadow(Colors.blue),
            ),
            padding: const EdgeInsets.all(Sizes.extraSmall),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(Sizes.borderRadius - Sizes.extraSmall),
                ),
              ),
              padding: const EdgeInsets.only(
                left: Sizes.small,
                right: Sizes.small,
              ),
              child: TextField(
                autocorrect: false,
                obscureText: widget.obscureText,
                cursorHeight: Sizes.fontSizeLarge,
                style: Styles.bodyLarge,
                controller: controller,
                focusNode: focusNode,
                autofocus: widget.autofocus,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Colors.white,
                  hintText: widget.label,
                ),
                onSubmitted: widget.onSubmitted,
              ),
            ),
          ),
        ),
        if (widget.submitButtonStyle == SubmitButtonStyle.below)
          const SizedBox(height: Sizes.small),
        if (widget.submitButtonStyle == SubmitButtonStyle.below)
          FunButton(
            widget.submitButtonText!,
            Colors.orange,
            onPressed: () {
              widget.onSubmitted?.call(controller.text);
            },
          ),
        if (widget.submitButtonStyle == SubmitButtonStyle.right)
          const SizedBox(width: Sizes.small),
        if (widget.submitButtonStyle == SubmitButtonStyle.right)
          FunButton(
            Icon(widget.submitButtonIcon ?? Icons.check, color: Colors.white),
            Colors.orange,
            expand: false,
            width: Sizes.textBoxHeight,
            height: Sizes.textBoxHeight,
            onPressed: () {
              widget.onSubmitted?.call(controller.text);
            },
          ),
      ],
    );
  }
}

enum SubmitButtonStyle {
  none,
  below,
  right,
}
