import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class FunButton extends StatefulWidget {
  final dynamic content;
  final Color color;
  final double? width;
  final double? height;
  final double sizeFactor;
  final bool expand;

  final void Function()? onPressed;
  final bool Function()? isEnabled;

  const FunButton(
    this.content,
    this.color, {
    this.width,
    this.height,
    this.sizeFactor = -1,
    this.expand = true,
    this.onPressed,
    this.isEnabled,
    super.key,
  });

  @override
  FunButtonState createState() => FunButtonState();
}

class FunButtonState extends State<FunButton> with TickerProviderStateMixin {
  ButtonState _buttonState = ButtonState.idle;

  double _sizeX = 0;
  double _sizeY = 0;
  double _angle = 0;
  late bool _direction;
  late AnimationController clickController;
  late AnimationController hoverController;

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

    clickController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    hoverController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    clickController.addListener(() {
      _updateButtonState();
    });

    hoverController.addListener(() {
      _updateButtonState();
    });
  }

  void _updateButtonState() {
    setState(() {
      var clickValue =
          CurveTween(curve: Curves.easeInOut).transform(clickController.value);
      var hoverValue =
          CurveTween(curve: Curves.easeInOut).transform(hoverController.value) *
              0.5;
      _sizeX = hoverValue;
      _sizeY = widget.sizeFactor * clickValue + hoverValue;

      _angle = clickValue *
          0.02 *
          (_direction ? 1 : -1) *
          (widget.expand ? 0.3 : 1) *
          3.14159265359;
    });
  }

  @override
  void dispose() {
    clickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isEnabled()) {
      _buttonState = ButtonState.disabled;
    }

    return SizedBox(
      width: widget.expand ? double.infinity : null,
      child: Transform(
        transformHitTests: false,
        alignment: Alignment.center,
        transform: Matrix4.rotationZ(_angle)
          ..scale(Vector3(1 + _sizeX * 0.12, 1 + _sizeY * 0.12, 1)),
        child: MouseRegion(
          onEnter: (_) {
            if (!isEnabled()) {
              return;
            }

            hoverController.forward();
            setState(() {
              _buttonState = ButtonState.hovered;
            });
          },
          onExit: (_) {
            if (!isEnabled()) {
              return;
            }

            hoverController.reverse();
            setState(() {
              _buttonState = ButtonState.idle;
            });
          },
          child: GestureDetector(
            onTapDown: (_) {
              if (!isEnabled()) {
                return;
              }

              clickController.forward();
              setState(() {
                _buttonState = ButtonState.pressed;
                _direction = !_direction;
              });
            },
            onTapUp: (_) {
              clickController.reverse().then((value) {
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
              clickController.reverse();
              setState(() {
                _buttonState = ButtonState.idle;
              });
            },
            child: FunContainer(
              padding: EdgeInsets.zero,
              expand: widget.expand,
              width: widget.width,
              height: widget.height,
              color: switch (_buttonState) {
                ButtonState.idle => widget.color.modifySaturation(0.9),
                ButtonState.pressed => widget.color.modifySaturation(0.7),
                ButtonState.loading => widget.color.modifySaturation(0.2),
                ButtonState.disabled => widget.color.modifySaturation(0.2),
                ButtonState.hovered => widget.color.modifySaturation(0.8),
              },
              child: widget.content is String
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Sizes.small,
                        horizontal: Sizes.medium,
                      ),
                      child: MdText(
                        widget.content,
                        style: Styles.bodyLarge.copyWith(
                          color: (_buttonState == ButtonState.disabled ||
                                  _buttonState == ButtonState.loading)
                              ? Colors.grey
                              : widget.color.isLight
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      ),
                    )
                  : widget.content,
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
