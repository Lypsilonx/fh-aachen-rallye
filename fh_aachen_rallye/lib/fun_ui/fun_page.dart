import 'package:fh_aachen_rallye/fun_ui/fun_app_bar.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/main.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:flutter/material.dart';

abstract class FunPage extends StatefulWidget {
  const FunPage({
    super.key,
  });

  String get title;
  String get navPath;
  IconData? get footerIcon;
  String get tileAssetPath;
  double get tileSize;
  Color get color;

  bool get showFooter => footerIcon != null;

  @override
  State<FunPage> createState();
}

abstract class FunPageState<T extends FunPage> extends TranslatedState<T>
    with TickerProviderStateMixin {
  String get title => widget.title;
  Widget? trailing(BuildContext context) => null;
  Widget buildPage(BuildContext context);

  bool get hideFooter =>
      ModalRoute.of(context)!.settings.name != widget.navPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FunAppBar(
        widget.color,
        title: Text(translate(title), style: Styles.h1),
        trailing: trailing(context),
      ),
      body: Helpers.tiledBackground(
        widget.tileAssetPath,
        widget.tileSize,
        widget.color,
        stackChildren: [
          Helpers.intelligentPadding(
            context,
            bottom: !widget.showFooter,
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: buildPage(context),
                ),
                if (widget.showFooter)
                  const SizedBox(
                    height: Sizes.medium,
                  ),
                if (widget.showFooter)
                  Opacity(
                    opacity: hideFooter ? 0 : 1,
                    child: Hero(
                      tag: 'footer',
                      child: FunContainer(
                        rounded: const RoundedSides(
                          bottomLeft: false,
                          bottomRight: false,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: FHAachenRallye.pages
                              .where(
                                (page) => page.showFooter,
                              )
                              .map<Widget>(
                                (page) {
                                  bool isCurrentPage =
                                      ModalRoute.of(context)!.settings.name ==
                                          page.navPath;
                                  return ElevatedButton(
                                    style: ButtonStyle(
                                      padding: WidgetStateProperty.all(
                                        EdgeInsets.zero,
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            Sizes.borderRadius,
                                          ),
                                        ),
                                      ),
                                      elevation: WidgetStateProperty.all(0),
                                      backgroundColor: isCurrentPage
                                          ? WidgetStateColor.resolveWith(
                                              (_) => Colors.grey.withAlpha(
                                                  (0.2 * 255).floor()),
                                            )
                                          : WidgetStateColor.transparent,
                                      fixedSize: WidgetStateProperty.all(
                                        const Size(
                                          Sizes.extraLarge * 1.5,
                                          Sizes.large * 1.5,
                                        ),
                                      ),
                                    ),
                                    onPressed: isCurrentPage
                                        ? null
                                        : () {
                                            int fromIndex = FHAachenRallye.pages
                                                .indexWhere((p) =>
                                                    p.navPath ==
                                                    widget.navPath);
                                            int toIndex = FHAachenRallye.pages
                                                .indexWhere((p) =>
                                                    p.navPath == page.navPath);

                                            Offset begin = Offset(
                                                toIndex >= fromIndex
                                                    ? -1.0
                                                    : 1.0,
                                                0.0);
                                            const curve = Curves.ease;

                                            var tween = Tween(
                                                    begin: Offset.zero,
                                                    end: begin)
                                                .chain(
                                              CurveTween(curve: curve),
                                            );
                                            var secondaryTween = Tween(
                                                    begin: -begin,
                                                    end: Offset.zero)
                                                .chain(
                                              CurveTween(curve: curve),
                                            );

                                            Navigator.of(context)
                                                .pushReplacement(
                                              PageRouteBuilder(
                                                settings: RouteSettings(
                                                    name: page.navPath),
                                                pageBuilder:
                                                    (context, animation, _) =>
                                                        page,
                                                transitionsBuilder: (context,
                                                    animation, _, child) {
                                                  return Stack(
                                                    children: <Widget>[
                                                      SlideTransition(
                                                          position:
                                                              tween.animate(
                                                                  animation),
                                                          child: widget),
                                                      SlideTransition(
                                                          position:
                                                              secondaryTween
                                                                  .animate(
                                                                      animation),
                                                          child: child)
                                                    ],
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          page.footerIcon,
                                          color: isCurrentPage
                                              ? Colors.grey
                                              : page.color,
                                          size: Sizes.medium * 1.5,
                                        ),
                                        Text(translate(page.title),
                                            style: Styles.body),
                                      ],
                                    ),
                                  );
                                },
                              )
                              .intersperse(
                                const SizedBox(width: Sizes.medium),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
