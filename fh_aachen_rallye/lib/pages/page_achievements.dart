import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/cache.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_medal.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class PageAchievements extends FunPage {
  const PageAchievements({super.key});

  @override
  String get title => 'ACHIEVEMENTS';

  @override
  String get navPath => '/achievements';

  @override
  IconData? get footerIcon => Icons.star;

  @override
  String get tileAssetPath => 'assets/background_1.png';

  @override
  double get tileSize => 200;

  @override
  Color get color => Colors.purple;

  @override
  State<PageAchievements> createState() => _PageAchievementsState();
}

class _PageAchievementsState extends FunPageState<PageAchievements>
    implements ServerObjectSubscriber {
  bool proceduralAddition = true;

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

  List<FHARAchievement> achivements = [
    FHARAchievement(
      title: 'ACHIEVEMENT_FIRST_STEPS',
      icon: Icons.face_2,
      color: Colors.blue,
      isCompleted: () => Cache.fetchAll<Challenge>().any((challenge) {
        return challenge.progress == 1;
      }),
    ),
    FHARAchievement(
      title: 'ACHIEVEMENT_TOUCH_GRASS',
      icon: Icons.grass,
      color: Colors.green,
      isCompleted: () => Cache.fetchAll<Challenge>().any((challenge) {
        return challenge.progress == 1 &&
            challenge.category == ChallengeCategory.outdoor;
      }),
    ),
    FHARAchievement(
      title: "ACHIEVEMENT_SO_EXTRA",
      icon: Icons.star,
      color: Colors.yellow,
      isCompleted: () => Backend.state.user?.displayName != null,
    ),
    FHARAchievement(
      title: "ACHIEVEMENT_LONG_TERM_COMMITMENT",
      icon: Icons.calendar_today,
      color: Colors.red,
      isCompleted: () => Cache.fetchAll<Challenge>().any((challenge) {
        return challenge.progress == 1 && challenge.duration.minutes >= 480;
      }),
    ),
    FHARAchievement(
      title: "ACHIEVEMENT_TRICKY_TRICKY",
      icon: Icons.priority_high,
      color: Colors.orange,
      isCompleted: () => Cache.fetchAll<Challenge>().any((challenge) {
        return challenge.progress == 1 &&
            challenge.difficulty == ChallengeDifficulty.veryHard;
      }),
    ),
  ];

  @override
  void onUpdate(ServerObject object) {}

  @override
  Widget buildPage(BuildContext context) {
    if (proceduralAddition) {
      achivements += ChallengeCategory.all
          .where((category) => Cache.fetchAll<Challenge>().where((challenge) {
                return challenge.category == category && !challenge.hidden;
              }).isNotEmpty)
          .map((category) {
        return FHARAchievement(
          title: 'ACHIEVEMENT_COMPLETE_CATEGORY',
          args: [translate(category.name)],
          icon: category.icon,
          color: category.color,
          isCompleted: () => Cache.fetchAll<Challenge>().where((challenge) {
            return challenge.category == category && !challenge.hidden;
          }).every((challenge) {
            return challenge.progress == 1;
          }),
        );
      }).toList();
      proceduralAddition = false;
    }

    achivements.sort((a, b) {
      if (a.isCompleted!() && !b.isCompleted!()) {
        return -1;
      } else if (!a.isCompleted!() && b.isCompleted!()) {
        return 1;
      } else {
        return 0;
      }
    });

    return Column(
      children: [
        Expanded(
          child: Helpers.blendList(
            GridView.builder(
              padding: const EdgeInsets.all(Sizes.medium),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmall ? 1 : 3,
                childAspectRatio: isSmall ? 4 : 0.8,
                crossAxisSpacing: Sizes.medium,
                mainAxisSpacing: Sizes.medium,
              ),
              itemCount: achivements.length,
              itemBuilder: (context, index) {
                bool isCompleted = achivements[index].isCompleted!();

                var items = [
                  Padding(
                    padding: isSmall
                        ? const EdgeInsets.all(0)
                        : const EdgeInsets.all(Sizes.medium),
                    child: Transform.scale(
                      scale: isSmall ? 1 : 1.5,
                      child: FunMedal.color(
                        isCompleted ? achivements[index].color : Colors.grey,
                        isCompleted ? achivements[index].icon : Icons.lock,
                      ),
                    ),
                  ),
                  Text(
                    translate(achivements[index].title,
                        args: achivements[index].args),
                    style: isSmall ? Styles.body : Styles.h2,
                    textAlign: TextAlign.center,
                  ),
                ];

                return Tooltip(
                  verticalOffset: isSmall ? 50 : 100,
                  message: translate('${achivements[index].title}_DESCRIPTION',
                      args: achivements[index].args),
                  child: FunContainer(
                    color: isCompleted ? Colors.white : Colors.grey,
                    modifyColor: false,
                    padding: const EdgeInsets.all(Sizes.medium),
                    child: Flex(
                      direction: isSmall ? Axis.horizontal : Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: isSmall
                          ? items.reversed.toList(growable: false)
                          : items,
                    ),
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

class FHARAchievement {
  final String title;
  final IconData icon;
  final Color color;
  final bool Function()? isCompleted;

  final List<String>? args;

  FHARAchievement({
    required this.title,
    required this.icon,
    required this.color,
    required this.isCompleted,
    this.args,
  });
}
