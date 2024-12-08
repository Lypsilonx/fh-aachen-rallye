import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class PageAccount extends FunPage {
  const PageAccount({super.key});

  @override
  String get tileAssetPath => 'assets/background_1.png';

  @override
  double get tileSize => 200;

  @override
  Color get color => Colors.red;

  @override
  State<PageAccount> createState() => _PageAccountState();
}

class _PageAccountState extends FunPageState<PageAccount> {
  @override
  Widget title(BuildContext context) => Text('Account', style: Styles.h1);

  @override
  Widget buildPage(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Sizes.medium),
        Text('User ID: ${Backend.userId}', style: Styles.h2),
        const SizedBox(height: Sizes.medium),
        Text('Points: ${Backend.getPoints()}', style: Styles.h2),
        const SizedBox(height: Sizes.extraLarge),
        FunButton(
          "Logout",
          Colors.red,
          onPressed: () {
            Backend.logout();
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }
}
