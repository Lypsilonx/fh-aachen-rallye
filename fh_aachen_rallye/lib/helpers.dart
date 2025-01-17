import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_dialog.dart';
import 'package:image/image.dart' as img;

import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:markdown/markdown.dart' as md;

class Helpers {
  static Widget displayDifficulty(ChallengeDifficulty difficulty) {
    int stars = switch (difficulty) {
      ChallengeDifficulty.none => 0,
      ChallengeDifficulty.veryEasy => 1,
      ChallengeDifficulty.easy => 2,
      ChallengeDifficulty.medium => 3,
      ChallengeDifficulty.hard => 4,
      ChallengeDifficulty.veryHard => 5,
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

  static Widget displayTags(Challenge challenge, double maxWidth) {
    double overflowSize = 1000;
    return SizedBox(
      width: maxWidth,
      height: Sizes.large - Sizes.small + 2,
      child: Stack(
        children: [
          Positioned(
            left: -overflowSize,
            child: SizedBox(
              width: maxWidth + overflowSize,
              child: ClipRect(
                child: Wrap(
                  spacing: Sizes.small,
                  children: [
                    SizedBox(width: overflowSize),
                    ...List.generate(
                      challenge.tags.length,
                      (index) => Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: challenge.category.color),
                          borderRadius:
                              BorderRadius.circular(Sizes.borderRadius),
                          color: challenge.category.color
                              .withSaturation(1)
                              .withAlpha((255 * 0.2).round()),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.small,
                          vertical: Sizes.extraSmall,
                        ),
                        child: Text(
                          challenge.tags[index],
                          style: Styles.bodySmall,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      color: color.withSaturation(0.8).withAlpha((0.3 * 255).round()),
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
                color: color.withSaturation(0.8).withAlpha((0.3 * 255).round()),
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
      {bool vertical = true, bool bottom = true}) {
    double extraPadding = Helpers.extraPadding(context);
    return Padding(
      padding: EdgeInsets.only(
        left: extraPadding + Sizes.large,
        right: extraPadding + Sizes.large,
        top: vertical ? Sizes.medium : 0,
        bottom: vertical && bottom ? Sizes.large : 0,
      ),
      child: child,
    );
  }

  static Widget blendList(Widget list) {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [
            0.0,
            0.02,
            0.98,
            1.0,
          ],
        ).createShader(
          Rect.fromLTRB(
            0,
            0,
            rect.width,
            rect.height,
          ),
        );
      },
      blendMode: BlendMode.dstIn,
      child: ClipPath(
        clipper: VerticalClipper(),
        child: list,
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  static void showFunDialog(BuildContext context, String title, String message,
      List<(String, void Function(BuildContext context))> actions,
      {bool hasCancelButton = true}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => FunDialog(
          title: title,
          message: message,
          actions: actions,
          hasCancelButton: hasCancelButton,
        ),
      ),
    );
  }
}

enum ChallengeDifficulty { none, veryEasy, easy, medium, hard, veryHard }

class ChallengeDuration {
  final int minutes;

  (String, int, int) get levelData {
    return levelNames.entries
        .firstWhere((element) => element.key >= minutes)
        .value;
  }

  int get level {
    return levelData.$2;
  }

  String get description {
    return levelData.$1;
  }

  List<String> get args {
    int factor = levelData.$3;
    return [
      (minutes / factor).ceil().toString(),
    ];
  }

  static const Map<int, (String, int, int)> levelNames = {
    0: ('NONE', 0, 1),
    1: ('MINUTES_SINGLE', 1, 1),
    10: ('MINUTES_LOW', 2, 1),
    45: ('MINUTES', 3, 1),
    90: ('HOURS_SINGLE', 4, 60),
    180: ('HOURS_LOW', 5, 60),
    480: ('HOURS', 6, 60),
    1000: ('DAYS_SINGLE', 7, 480),
    2000: ('DAYS_LOW', 8, 480),
    5000: ('DAYS', 9, 480),
    10000: ('MORE', 10, 480),
  };

  ChallengeDuration(this.minutes);
}

extension AdvancedColor on Color {
  bool get isLight => computeLuminance() > 0.5;

  Color withSaturation(double saturation) {
    HSLColor hsl = HSLColor.fromColor(this);
    if (b == g && g == r) {
      int value = (255 * saturation).toInt();
      return Color.fromARGB((a * 255).round(), value, value, value);
    }

    return hsl.withSaturation(saturation).toColor();
  }

  Color modifySaturation(double saturation) {
    HSLColor hsl = HSLColor.fromColor(this);
    if (b == g && g == r) {
      int value = (255 * saturation).toInt();
      return Color.fromARGB((a * 255).round(), value, value, value);
    }

    return hsl.withSaturation(hsl.saturation * saturation).toColor();
  }

  Color inverted() {
    HSLColor hsl = HSLColor.fromColor(this);
    double hue = (hsl.hue + 180) % 360;
    return HSLColor.fromAHSL(a, hue, hsl.saturation, hsl.lightness).toColor();
  }
}

class Sizes {
  static const double extraSmall = Sizes.small / 2;
  static const double small = 8;
  static const double medium = Sizes.small * 2;
  static const double large = Sizes.medium * 2;
  static const double extraLarge = Sizes.large * 2;

  static const double tileHeight = Sizes.extraLarge + Sizes.small;
  static const double textBoxHeight = Sizes.extraLarge - Sizes.small;

  static const double borderRadiusSmall = Sizes.borderRadius / 2;
  static const double borderRadius = Sizes.small;
  static const double borderRadiusLarge = Sizes.borderRadius * 2;

  static const double fontSizeExtraSmall = Sizes.fontSizeSmall / 1.2;
  static const double fontSizeSmall = Sizes.fontSizeMedium / 1.2;
  static const double fontSizeMedium = 16;
  static const double fontSizeLarge = Sizes.fontSizeMedium * 1.2;
}

class Styles {
  static const TextStyle body = TextStyle(
    fontSize: Sizes.fontSizeSmall,
    fontFamily: 'JosefinSans',
    fontWeight: FontWeight.normal,
    fontVariations: [
      FontVariation(
        'wght',
        400,
      ),
    ],
  );

  static TextStyle bodyLarge = Styles.body.copyWith(
    fontSize: Sizes.fontSizeLarge,
  );

  static TextStyle bodySmall = Styles.body.copyWith(
    fontSize: Sizes.fontSizeExtraSmall,
  );

  static TextStyle subtitle = Styles.body.copyWith(
    fontWeight: FontWeight.bold,
    fontVariations: [
      const FontVariation(
        'wght',
        900,
      ),
    ],
  );

  static TextStyle h2 = Styles.body.copyWith(
    fontWeight: FontWeight.bold,
    fontVariations: [
      const FontVariation(
        'wght',
        900,
      ),
    ],
    fontFamily: 'Futura',
    fontSize: Sizes.fontSizeMedium,
  );
  static TextStyle h1 = Styles.h2.copyWith(
    fontSize: Sizes.fontSizeLarge,
  );
}

class MdText extends StatelessWidget {
  final String data;
  final TextStyle style;

  const MdText(this.data, {this.style = Styles.body, super.key});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      imageBuilder: (Uri uri, String? title, String? alt) {
        String url =
            "${Backend.url}/api/resources/data/images/${uri.toString()}";
        return FutureBuilder(
            future: applyRotationFix(url),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              } else {
                return const CircularProgressIndicator();
              }
            });
      },
      data: data,
      styleSheet: MarkdownStyleSheet(
        p: style,
        h1: Styles.h1,
        h2: Styles.h2,
        strong: style.copyWith(
          fontWeight: FontWeight.bold,
          fontVariations: [
            const FontVariation(
              'wght',
              900,
            ),
          ],
        ),
      ),
      builders: {
        'latex': LatexElementBuilder(textStyle: style),
      },
      extensionSet: md.ExtensionSet(
        [LatexBlockSyntax()],
        [LatexInlineSyntax()],
      ),
    );
  }
}

Future<Widget> applyRotationFix(String url) async {
  try {
    Uint8List imageBytes =
        await HttpClient().getUrl(Uri.parse(url)).then((request) async {
      return await request.close().then((response) async {
        return Uint8List.fromList(
            await response.expand((element) => element).toList());
      });
    });
    Map<String, IfdTag> data = await readExifFromBytes(imageBytes);

    String orientation = data['Image Orientation']?.toString() ?? '';
    var rotation = 0;
    if (orientation.contains('Rotated 90 CW')) {
      rotation = 90;
    } else if (orientation.contains('Rotated 180 CW')) {
      rotation = 180;
    } else if (orientation.contains('Rotated 270 CW')) {
      rotation = 270;
    }

    if (rotation != 0) {
      var image = img.decodeImage(imageBytes);
      image = img.copyRotate(image!, angle: rotation);
      imageBytes = img.encodeJpg(image);
    }
    return Image.memory(imageBytes);
  } catch (e) {
    return Image.network(url);
  }
}

extension AdvancedListInt on Iterable<int> {
  int sum() {
    return fold(0, (a, b) => a + b);
  }
}

extension Intersperse<T> on Iterable<T> {
  Iterable<T> intersperse(T separator) sync* {
    var iterator = this.iterator;
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield separator;
        yield iterator.current;
      }
    }
  }
}

class VerticalClipper extends CustomClipper<Path> {
  final double margin;
  VerticalClipper({this.margin = 100});

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(-margin, 0);
    path.lineTo(size.width + margin, 0);
    path.lineTo(size.width + margin, size.height);
    path.lineTo(-margin, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
