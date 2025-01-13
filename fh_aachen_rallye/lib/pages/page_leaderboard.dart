import 'package:fh_aachen_rallye/data/cache.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/widgets/user_tile.dart';
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
  List<String> userIds = [];

  @override
  void initState() {
    super.initState();
    SubscriptionManager.subscribeAll<User>(this);
  }

  @override
  void dispose() {
    SubscriptionManager.unsubscribe(this);
    super.dispose();
  }

  @override
  void onUpdate(ServerObject object) {
    var userChache = Cache.fetchAll<User>();
    userIds = userChache.map((e) => e.id).toList();

    userIds.sort((a, b) {
      var userA = userChache.firstWhere((e) => e.id == a);
      var userB = userChache.firstWhere((e) => e.id == b);

      return userB.points.compareTo(userA.points);
    });

    setState(() {});
  }

  @override
  Widget buildPage(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Helpers.blendList(
            ListView.builder(
              clipBehavior: Clip.none,
              itemCount: userIds.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: Sizes.medium,
                    top: index == 0 ? Sizes.medium : 0,
                  ),
                  child: UserTile(
                    userIds[index],
                    key: UniqueKey(),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: Sizes.medium),
      ],
    );
  }
}
