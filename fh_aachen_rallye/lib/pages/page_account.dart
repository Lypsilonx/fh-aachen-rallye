import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
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

class _PageAccountState extends FunPageState<PageAccount>
    implements ServerObjectSubscriber {
  late User user;

  @override
  void initState() {
    super.initState();
    SubscriptionManager.subscribe<User>(this, Backend.userId!);
  }

  @override
  void onUpdate(ServerObject object) {
    if (object is User) {
      setState(() {
        user = object;
      });
    }
  }

  @override
  Widget title(BuildContext context) => Text('Account', style: Styles.h1);

  @override
  Widget buildPage(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Sizes.medium),
        Text('User ID: ${user.id}', style: Styles.h2),
        const SizedBox(height: Sizes.medium),
        Text('Points: ${user.points}', style: Styles.h2),
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
