import 'package:fh_aachen_rallye/fun_ui/fun_app_bar.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translation/translated_string.dart';
import 'package:fh_aachen_rallye/translation/translator.dart';
import 'package:flutter/material.dart';

abstract class FunPage extends StatefulWidget {
  const FunPage({
    super.key,
  });
  String get tileAssetPath;
  double get tileSize;
  Color get color;

  @override
  State<FunPage> createState();
}

abstract class FunPageState<T extends FunPage> extends State<T> {
  Widget title(BuildContext context);
  Widget? trailing(BuildContext context) => null;
  Widget buildPage(BuildContext context);

  List<Translateable> translateables = [];

  @override
  void dispose() {
    for (var translateable in translateables) {
      Translator.unsubscribe(translateable);
    }
    super.dispose();
  }

  void registerTranslateable(Translateable translateable) {
    if (!translateables.contains(translateable)) {
      translateables.add(translateable);
    }
  }

  String translate(String key) {
    return TranslatedString(setState, key).register(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FunAppBar(
        widget.color,
        title: title(context),
        trailing: trailing(context),
      ),
      body: Helpers.tiledBackground(
        widget.tileAssetPath,
        widget.tileSize,
        widget.color,
        stackChildren: [
          Helpers.intelligentPadding(
            context,
            buildPage(context),
          ),
        ],
      ),
    );
  }
}
