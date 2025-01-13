import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_language_picker.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class PageLeaderboard extends FunPage {
  const PageLeaderboard({super.key});

  @override
  String get title => 'LEADERBOARD';

  @override
  String get navPath => '/leaderboard';

  @override
  IconData? get footerIcon => Icons.leaderboard;

  @override
  String get tileAssetPath => 'assets/background_1.png';

  @override
  double get tileSize => 200;

  @override
  Color get color => Colors.yellow;

  @override
  State<PageLeaderboard> createState() => _PageLeaderboardState();
}

class _PageLeaderboardState extends FunPageState<PageLeaderboard>
    implements ServerObjectSubscriber {
  late User user;

  @override
  void initState() {
    super.initState();
    //SubscriptionManager.subscribe<User>(this, Backend.userId!);
  }

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
  Widget buildPage(BuildContext context) {
    return Column(
      children: [],
    );
  }
}
