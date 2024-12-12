import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class FunTextInput extends StatefulWidget {
  const FunTextInput({
    this.label,
    this.obscureText = false,
    this.autofocus = true,
    this.submitButton,
    this.onSubmitted,
    this.controller,
    super.key,
  });

  final String? label;
  final bool obscureText;
  final bool autofocus;
  final String? submitButton;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;

  @override
  State<FunTextInput> createState() => _FunTextInputState();
}

class _FunTextInputState extends State<FunTextInput> {
  late TextEditingController controller =
      widget.controller ?? TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
              obscureText: widget.obscureText,
              cursorHeight: Sizes.fontSizeLarge,
              style: Styles.bodyLarge,
              controller: controller,
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
        if (widget.submitButton != null) const SizedBox(height: Sizes.small),
        if (widget.submitButton != null)
          FunButton(
            widget.submitButton!,
            Colors.orange,
            onPressed: () {
              widget.onSubmitted?.call(controller.text);
            },
          ),
      ],
    );
  }
}
