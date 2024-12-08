import 'dart:math';

import 'package:flutter/material.dart';

class Helpers {
  static Widget displayDifficulty(Difficulty difficulty) {
    int stars = switch (difficulty) {
      Difficulty.none => 0,
      Difficulty.easy => 1,
      Difficulty.medium => 2,
      Difficulty.hard => 3,
      Difficulty.varyEasy => 4,
      Difficulty.varyHard => 5,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: Colors.orange,
        ),
      ),
    );
  }

  static List<BoxShadow> boxShadow(Color color) {
    return [
      BoxShadow(
        color: color.modifySaturation(0.5),
        blurRadius: 0,
        offset: const Offset(0, Sizes.extraSmall),
      ),
    ];
  }

  static Widget tiledBackground(String imagePath, double tileSize, Color color,
      {List<Widget> stackChildren = const []}) {
    Image image = Image.asset(
      color: color.withSaturation(0.8).withOpacity(0.3),
      imagePath,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columnCount = (constraints.maxWidth / tileSize).ceil();
        final int rowCount = (constraints.maxHeight / tileSize).ceil();

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: color.withSaturation(0.8).withOpacity(0.3),
              ),
            ),
            Stack(
              children: [
                ...List.generate(
                  rowCount * columnCount,
                  (int index) {
                    final int row = index ~/ columnCount;
                    final int col = index % columnCount;

                    return Positioned(
                      left: col * tileSize,
                      top: row * tileSize,
                      width: tileSize,
                      height: tileSize,
                      child: image,
                    );
                  },
                ),
              ],
            ),
            ...stackChildren,
          ],
        );
      },
    );
  }

  static double extraPadding(BuildContext context) {
    return max((MediaQuery.of(context).size.width - 600) / 2, 0);
  }

  static Widget intelligentPadding(BuildContext context, Widget child,
      {bool vertical = true}) {
    double extraPadding = Helpers.extraPadding(context);
    return Padding(
      padding: EdgeInsets.only(
        left: extraPadding + Sizes.large,
        right: extraPadding + Sizes.large,
        top: vertical ? Sizes.large : 0,
        bottom: vertical ? Sizes.large : 0,
      ),
      child: child,
    );
  }
}

enum Difficulty { none, varyEasy, easy, medium, hard, varyHard }

extension AdvancedColor on Color {
  bool get isLight => computeLuminance() > 0.5;

  Color withSaturation(double saturation) {
    HSLColor hsl = HSLColor.fromColor(this);
    if (blue == green && green == red) {
      int value = (255 * saturation).toInt();
      return Color.fromARGB(alpha, value, value, value);
    }

    return hsl.withSaturation(saturation).toColor();
  }

  Color modifySaturation(double saturation) {
    HSLColor hsl = HSLColor.fromColor(this);
    if (blue == green && green == red) {
      int value = (255 * saturation).toInt();
      return Color.fromARGB(alpha, value, value, value);
    }

    return hsl.withSaturation(hsl.saturation * saturation).toColor();
  }
}

class Sizes {
  static const double extraSmall = Sizes.small / 2;
  static const double small = 8;
  static const double medium = Sizes.small * 2;
  static const double large = Sizes.medium * 2;
  static const double extraLarge = Sizes.large * 2;

  static const double borderRadiusSmall = Sizes.borderRadius / 2;
  static const double borderRadius = Sizes.small;
  static const double borderRadiusLarge = Sizes.borderRadius * 2;

  static const double fontSizeSmall = Sizes.fontSizeMedium / 1.2;
  static const double fontSizeMedium = 16;
  static const double fontSizeLarge = Sizes.fontSizeMedium * 1.2;
}

class Styles {
  static const TextStyle body = TextStyle(
    fontSize: Sizes.fontSizeSmall,
    fontFamily: 'Josefin Sans',
  );

  static TextStyle bodyLarge = Styles.body.copyWith(
    fontSize: Sizes.fontSizeLarge,
  );

  static TextStyle subtitle = Styles.body.copyWith(
    fontWeight: FontWeight.bold,
  );

  static TextStyle h2 = Styles.body.copyWith(
    fontWeight: FontWeight.bold,
    fontFamily: 'Futura',
    fontSize: Sizes.fontSizeMedium,
  );
  static TextStyle h1 = Styles.h2.copyWith(
    fontSize: Sizes.fontSizeLarge,
  );
}
