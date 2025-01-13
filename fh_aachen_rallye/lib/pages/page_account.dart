import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/widgets/editable_field.dart';
import 'package:flutter/material.dart';

class PageAccount extends FunPage {
  const PageAccount({super.key});

  @override
  String get title => 'ACCOUNT';

  @override
  String get navPath => '/account';

  @override
  IconData? get footerIcon => Icons.person;

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
  void dispose() {
    SubscriptionManager.unsubscribe(this);
    super.dispose();
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
  Widget buildPage(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Helpers.blendList(
            ListView(
              children: [
                const SizedBox(height: Sizes.medium),
                Text('User ID: ${user.id}', style: Styles.h2),
                const SizedBox(height: Sizes.medium),
                Text('${translate('POINTS')}: ${user.points}',
                    style: Styles.h2),
                const SizedBox(height: Sizes.extraLarge),
                EditableField(
                  translate('USERNAME'),
                  user.username,
                  (value) {
                    Backend.patch(user, {'username': value});
                  },
                ),
                const SizedBox(height: Sizes.medium),
                EditableField(
                  translate('DISPLAY_NAME'),
                  user.displayName ?? '',
                  (value) {
                    Backend.patch(
                        user, {'displayName': value.isEmpty ? null : value});
                  },
                ),
                const SizedBox(height: Sizes.medium),
                EditableField(
                  translate('PASSWORD'),
                  '',
                  (value) {
                    Backend.changePassword(value);
                  },
                  isPassword: true,
                ),
                const SizedBox(height: Sizes.extraLarge),
                FunButton(
                  translate('LOGOUT'),
                  Colors.red,
                  onPressed: () {
                    Backend.logout(context);
                  },
                ),
                const SizedBox(height: Sizes.extraLarge),
              ],
            ),
          ),
        ),
        const SizedBox(height: Sizes.medium),
      ],
    );
  }
}
