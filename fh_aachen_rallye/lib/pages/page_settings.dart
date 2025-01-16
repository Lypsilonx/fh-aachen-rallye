import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_language_picker.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/settings.dart';
import 'package:flutter/material.dart';

class PageSettings extends FunPage {
  const PageSettings({super.key});

  @override
  String get title => 'SETTINGS';

  @override
  String get navPath => '/settings';

  @override
  IconData? get footerIcon => Icons.settings;

  @override
  String get tileAssetPath => 'assets/background_1.png';

  @override
  double get tileSize => 200;

  @override
  Color get color => Colors.grey;

  @override
  State<PageSettings> createState() => _PageSettingsState();
}

class _PageSettingsState extends FunPageState<PageSettings>
    implements ServerObjectSubscriber {
  late User user;

  @override
  void dispose() {
    //SubscriptionManager.unsubscribe(this);
    super.dispose();
  }

  @override
  void onUpdate(ServerObject object) {
    // if (object is User) {
    //   setState(() {
    //     user = object;
    //   });
    // }
  }

  @override
  Widget trailing(BuildContext context) {
    return const FunLanguagePicker();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Column(
      children: [
        Settings.showWipChallengesWidget,
      ],
    );
  }
}
