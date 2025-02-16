import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class FunMedal extends StatelessWidget {
  const FunMedal({
    super.key,
    this.placement,
    this.color = Colors.transparent,
    this.icon,
  });

  factory FunMedal.placement(int placement) => FunMedal(
        placement: placement,
      );

  factory FunMedal.color(
    Color color,
    IconData icon,
  ) =>
      FunMedal(
        color: color,
        icon: icon,
      );

  final int? placement;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    Color medalColor = switch (placement) {
      1 => Colors.yellow,
      2 => Colors.white,
      3 => const Color.fromARGB(255, 184, 110, 83),
      _ => color,
    };

    double brightSaturation = 0.9;
    double normalSaturation = 0.8;
    double darkSaturation = 0.4;

    return Transform.translate(
      offset: const Offset(0, -Sizes.extraSmall / 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (placement == null || placement! < 4)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.skewY(0.75)
                ..translate(Vector3(0, Sizes.small * 1.5, 0)),
              child: Container(
                width: Sizes.borderRadiusLarge * 2 - Sizes.small * 1.5,
                height: Sizes.medium,
                decoration: BoxDecoration(
                    color: medalColor.withSaturation(brightSaturation)),
              ),
            ),
          if (placement == null || placement! < 4)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.skewY(-0.75)
                ..translate(Vector3(0, Sizes.small * 1.5, 0)),
              child: Container(
                width: Sizes.borderRadiusLarge * 2 - Sizes.small * 1.5,
                height: Sizes.medium,
                decoration: BoxDecoration(
                  color: medalColor.withSaturation(normalSaturation),
                ),
              ),
            ),
          if (placement == null || placement! < 4)
            Container(
              width: Sizes.borderRadiusLarge * 2,
              height: Sizes.borderRadiusLarge * 2,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: medalColor.withSaturation(darkSaturation),
                    offset: const Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
                color: medalColor.withSaturation(normalSaturation),
                borderRadius: BorderRadius.circular(Sizes.borderRadiusLarge),
              ),
            ),
          if (placement == null || placement! < 4)
            Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.identity()
                ..translate(Vector3(Sizes.small * 0.75, 0, 0))
                ..rotateZ(-2.4),
              child: Container(
                width: Sizes.borderRadiusLarge - Sizes.extraSmall,
                height: Sizes.borderRadiusLarge * 2 - Sizes.small,
                decoration: BoxDecoration(
                  color: medalColor.withSaturation(brightSaturation),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(
                        Sizes.borderRadiusLarge - Sizes.extraSmall),
                    bottomRight: Radius.circular(
                        Sizes.borderRadiusLarge - Sizes.extraSmall),
                  ),
                ),
              ),
            ),
          if (placement != null)
            Text(
              '$placement${placement! < 4 ? '' : '.'}',
              style: Styles.h1.copyWith(
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(0, 0),
                    blurRadius: 4,
                  ),
                ],
                color: Colors.white,
              ),
            ),
          if (icon != null)
            Icon(
              icon,
              color: Colors.white,
              size: Sizes.medium,
            ),
        ],
      ),
    );
  }
}
