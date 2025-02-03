import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class FunAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FunAppBar(
    this.backgroundColor, {
    required this.title,
    this.trailing,
    this.customBackAction,
    super.key,
  });

  final Color backgroundColor;
  final Widget title;
  final Widget? trailing;
  final Function? customBackAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor.withSaturation(0.8).withAlpha((255 * 0.3).round()),
      child: Helpers.intelligentPadding(
        context,
        vertical: false,
        FunContainer(
          rounded: const RoundedSides(
            topLeft: false,
            topRight: false,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: Sizes.large,
                alignment: Alignment.center,
                child: (customBackAction != null ||
                        (ModalRoute.of(context)?.canPop ?? false))
                    ? GestureDetector(
                        onTap: () {
                          if (customBackAction != null) {
                            customBackAction!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
              title,
              Container(
                width: Sizes.large,
                height: Sizes.large,
                alignment: Alignment.center,
                child: trailing,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(200, Sizes.large + Sizes.medium);
}
