import 'package:fh_aachen_rallye/backend.dart';
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
  IconData? get footerIcon => Icons.star;

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
  Map<int, int> pointsToPlacement = {};

  @override
  void initState() {
    super.initState();
    SubscriptionManager.subscribeAny<User>(this);
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

    int lastPlacement = 0;
    int lastPoints = -10000;
    for (var i = 0; i < userIds.length; i++) {
      var user = userChache.firstWhere((e) => e.id == userIds[i]);
      if (user.points != lastPoints) {
        lastPlacement++;
        lastPoints = user.points;
      }
      pointsToPlacement[user.points] = lastPlacement;
    }

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
                var placement = pointsToPlacement[
                    Cache.fetch<User>(userIds[index])?.points ?? 0]!;
                return Stack(
                  children: [
                    if (userIds[index] == Backend.userId)
                      Transform.translate(
                        offset: const Offset(-Sizes.medium, Sizes.extraSmall),
                        child: Container(
                          width: double.infinity,
                          height: Sizes.tileHeight * 0.75 +
                              Sizes.extraSmall +
                              Sizes.small,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color.fromARGB(128, 255, 0, 0),
                                Color.fromARGB(0, 255, 0, 0),
                                Color.fromARGB(0, 255, 0, 0),
                              ],
                              stops: [0, 0.2, 1],
                            ),
                            borderRadius:
                                BorderRadius.circular(Sizes.borderRadius),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Sizes.small,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, Sizes.extraSmall / 2),
                            child: Container(
                              width: Sizes.borderRadiusLarge * 2,
                              height: Sizes.borderRadiusLarge * 2,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: switch (placement) {
                                  1 => const Color.fromARGB(255, 147, 132, 50),
                                  2 => Colors.grey,
                                  3 => const Color.fromARGB(255, 156, 78, 50),
                                  _ => Colors.transparent
                                },
                                borderRadius: BorderRadius.circular(
                                    Sizes.borderRadiusLarge),
                              ),
                              child: Text(
                                '$placement${placement < 4 ? '' : '.'}',
                                style: Styles.h1.copyWith(
                                  color: placement < 4
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: Sizes.medium),
                          Expanded(
                            child: UserTile(
                              userIds[index],
                              key: UniqueKey(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
