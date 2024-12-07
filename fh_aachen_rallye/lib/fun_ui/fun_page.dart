import 'package:fh_aachen_rallye/fun_ui/fun_app_bar.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

abstract class FunPage extends StatefulWidget {
  const FunPage({
    super.key,
  });

  Widget title(BuildContext context);
  Widget? trailing(BuildContext context) => null;
  Widget buildPage(
      BuildContext context, void Function(void Function()) setState);
  String get tileAssetPath;
  double get tileSize;
  Color get color;

  @override
  State<FunPage> createState() => _FunPageState();
}

class _FunPageState extends State<FunPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FunAppBar(
        widget.color,
        title: widget.title(context),
        trailing: widget.trailing(context),
      ),
      body: Helpers.tiledBackground(
        widget.tileAssetPath,
        widget.tileSize,
        widget.color,
        stackChildren: [
          Helpers.intelligentPadding(
            context,
            widget.buildPage(context, setState),
          ),
        ],
      ),
    );
  }
}
