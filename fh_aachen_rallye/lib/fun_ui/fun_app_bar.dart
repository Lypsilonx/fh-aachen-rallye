import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class FunAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FunAppBar(
    this.backgroundColor, {
    required this.title,
    this.trailing,
    super.key,
  });

  final Color backgroundColor;
  final Widget title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor.withSaturation(0.8).withOpacity(0.3),
      child: Helpers.intelligentPadding(
        context,
        vertical: false,
        Container(
          alignment: Alignment.center,
          height: Sizes.extraLarge + Sizes.medium,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(Sizes.borderRadiusLarge),
              bottomRight: Radius.circular(Sizes.borderRadiusLarge),
            ),
            boxShadow: Helpers.boxShadow(Colors.white),
          ),
          padding: const EdgeInsets.all(Sizes.small),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: Sizes.large,
                alignment: Alignment.center,
                child: Navigator.of(context).canPop()
                    ? GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
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
