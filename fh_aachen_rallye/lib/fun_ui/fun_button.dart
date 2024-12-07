import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class FunButton extends StatefulWidget {
  final String text;
  final Color color;
  final double sizeFactor;
  final bool expand;

  final void Function()? onPressed;
  final bool Function()? isEnabled;

  const FunButton(this.text, this.color,
      {this.sizeFactor = -1,
      this.expand = true,
      this.onPressed,
      this.isEnabled,
      super.key});

  @override
  FunButtonState createState() => FunButtonState();
}

class FunButtonState extends State<FunButton>
    with SingleTickerProviderStateMixin {
  ButtonState _buttonState = ButtonState.idle;

  double _size = 0;
  double _angle = 0;
  late bool _direction;
  late AnimationController controller;

  bool isEnabled() {
    if (widget.isEnabled == null) {
      return true;
    }

    return widget.isEnabled!();
  }

  @override
  void initState() {
    super.initState();

    _direction = DateTime.now().millisecond % 2 == 0;

    controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    controller.addListener(() {
      setState(() {
        _size = widget.sizeFactor *
            CurveTween(curve: Curves.easeInOut).transform(controller.value);

        _angle =
            CurveTween(curve: Curves.easeInOut).transform(controller.value) *
                0.02 *
                (_direction ? 1 : -1) *
                (widget.expand ? 0.3 : 1) *
                3.14159265359;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isEnabled()) {
      _buttonState = ButtonState.disabled;
    }

    return Container(
      padding: EdgeInsets.only(
        top:
            (widget.sizeFactor > 0 ? widget.sizeFactor * Sizes.extraSmall : 0) -
                _size * Sizes.extraSmall,
        bottom:
            (widget.sizeFactor > 0 ? widget.sizeFactor * Sizes.extraSmall : 0) -
                _size * Sizes.extraSmall,
      ),
      width: widget.expand ? double.infinity : null,
      child: Transform(
        transformHitTests: false,
        alignment: Alignment.center,
        transform: Matrix4.rotationZ(_angle),
        child: MouseRegion(
          onEnter: (_) {
            if (!isEnabled()) {
              return;
            }

            setState(() {
              _buttonState = ButtonState.hovered;
            });
          },
          onExit: (_) {
            if (!isEnabled()) {
              return;
            }

            setState(() {
              _buttonState = ButtonState.idle;
            });
          },
          child: GestureDetector(
            onTapDown: (_) {
              if (!isEnabled()) {
                return;
              }

              controller.forward();
              setState(() {
                _buttonState = ButtonState.pressed;
                _direction = !_direction;
              });
            },
            onTapUp: (_) {
              controller.reverse().then((value) {
                if (!isEnabled()) {
                  return;
                }

                widget.onPressed?.call();
                setState(() {
                  _buttonState = ButtonState.idle;
                });
              });
            },
            onTapCancel: () {
              controller.reverse();
              setState(() {
                _buttonState = ButtonState.idle;
              });
            },
            child: Container(
              width: widget.expand ? double.infinity : null,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: switch (_buttonState) {
                  ButtonState.idle => widget.color.modifySaturation(0.9),
                  ButtonState.pressed => widget.color.modifySaturation(0.7),
                  ButtonState.loading => Colors.grey,
                  ButtonState.disabled => Colors.grey,
                  ButtonState.hovered => widget.color.modifySaturation(0.8),
                },
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
                boxShadow: Helpers.boxShadow(widget.color),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: Sizes.small + _size * Sizes.extraSmall,
                  bottom: Sizes.small + _size * Sizes.extraSmall,
                  left: Sizes.medium + _size * Sizes.small,
                  right: Sizes.medium + _size * Sizes.small,
                ),
                child: Text(
                  widget.text,
                  style: Styles.bodyLarge.copyWith(
                    color: widget.color.isLight ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ButtonState {
  idle,
  pressed,
  hovered,
  disabled,
  loading,
}
