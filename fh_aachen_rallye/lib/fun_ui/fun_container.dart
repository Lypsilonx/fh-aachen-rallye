import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class FunContainer extends StatelessWidget {
  const FunContainer({
    required this.child,
    this.color = Colors.white,
    this.expand = true,
    this.padding = const EdgeInsets.all(Sizes.small),
    this.rounded = const RoundedSides(),
    super.key,
  });

  final Widget child;
  final Color color;
  final bool expand;
  final EdgeInsets padding;
  final RoundedSides rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expand ? double.infinity : null,
      alignment: expand ? Alignment.center : null,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: rounded.topLeft
              ? const Radius.circular(Sizes.medium)
              : Radius.zero,
          topRight: rounded.topRight
              ? const Radius.circular(Sizes.medium)
              : Radius.zero,
          bottomLeft: rounded.bottomLeft
              ? const Radius.circular(Sizes.medium)
              : Radius.zero,
          bottomRight: rounded.bottomRight
              ? const Radius.circular(Sizes.medium)
              : Radius.zero,
        ),
        boxShadow: Helpers.boxShadow(color),
      ),
      padding: padding,
      child: child,
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
