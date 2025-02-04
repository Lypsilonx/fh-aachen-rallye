import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class FunContainer extends StatefulWidget {
  const FunContainer({
    this.child,
    this.builder,
    this.onTap,
    this.onLongPress,
    this.hoverStrength = 0.05,
    this.color = Colors.white,
    this.modifyColor = true,
    this.expand = true,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(Sizes.small),
    this.rounded = const RoundedSides(),
    super.key,
  });

  final Widget? child;
  final Widget? Function(bool hovered)? builder;
  final Function()? onTap;
  final Function()? onLongPress;
  final Color color;
  final bool modifyColor;
  final double hoverStrength;
  final bool expand;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final RoundedSides rounded;

  @override
  State<FunContainer> createState() => _FunContainerState();
}

class _FunContainerState extends State<FunContainer> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    var finalColor = widget.modifyColor
        ? widget.color
            .modifySaturation(1 - (hovered ? widget.hoverStrength : 0))
        : widget.color;
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            if (widget.onTap == null) {
              return;
            }

            hovered = true;
          });
        },
        onExit: (_) {
          if (widget.onTap == null) {
            return;
          }

          setState(() {
            hovered = false;
          });
        },
        child: Container(
          width: widget.expand ? double.infinity : widget.width,
          height: widget.height,
          alignment: widget.expand ? Alignment.center : null,
          decoration: BoxDecoration(
            color: finalColor,
            borderRadius: BorderRadius.only(
              topLeft: widget.rounded.topLeft
                  ? const Radius.circular(Sizes.borderRadius)
                  : Radius.zero,
              topRight: widget.rounded.topRight
                  ? const Radius.circular(Sizes.borderRadius)
                  : Radius.zero,
              bottomLeft: widget.rounded.bottomLeft
                  ? const Radius.circular(Sizes.borderRadius)
                  : Radius.zero,
              bottomRight: widget.rounded.bottomRight
                  ? const Radius.circular(Sizes.borderRadius)
                  : Radius.zero,
            ),
            boxShadow: Helpers.boxShadow(widget.color),
          ),
          padding: widget.padding,
          child:
              widget.builder != null ? widget.builder!(hovered) : widget.child,
        ),
      ),
    );
  }
}

class RoundedSides {
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  const RoundedSides({
    this.topLeft = true,
    this.topRight = true,
    this.bottomLeft = true,
    this.bottomRight = true,
  });
}
