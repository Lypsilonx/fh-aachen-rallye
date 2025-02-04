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
      description: 'ACHIEVEMENT_FIRST_STEPS_DESCRIPTION',
      icon: Icons.face_2,
      color: Colors.blue,
      isCompleted: () => Cache.fetchAll<Challenge>().any((challenge) {
        return challenge.progress == 1;
      }),
    ),
    FHARAchievement(
      title: 'ACHIEVEMENT_TOUCH_GRASS',
      description: 'ACHIEVEMENT_TOUCH_GRASS_DESCRIPTION',
      icon: Icons.grass,
      color: Colors.green,
      isCompleted: () => Cache.fetchAll<Challenge>().any((challenge) {
        return challenge.progress == 1 &&
            challenge.category == ChallengeCategory.outdoor;
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
          description: 'ACHIEVEMENT_COMPLETE_CATEGORY_DESCRIPTION',
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: Sizes.medium,
                mainAxisSpacing: Sizes.medium,
              ),
              itemCount: achivements.length,
              itemBuilder: (context, index) {
                bool isCompleted = achivements[index].isCompleted!();
                return Tooltip(
                  message: isCompleted
                      ? translate(achivements[index].description,
                          args: achivements[index].args)
                      : '',
                  child: FunContainer(
                    color: isCompleted ? Colors.white : Colors.grey,
                    modifyColor: false,
                    padding: const EdgeInsets.all(Sizes.medium),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(Sizes.medium),
                          child: Transform.scale(
                            scale: 1.5,
                            child: FunMedal.color(
                              isCompleted
                                  ? achivements[index].color
                                  : Colors.grey,
                              isCompleted
                                  ? achivements[index].icon
                                  : Icons.lock,
                            ),
                          ),
                        ),
                        Text(
                          isCompleted
                              ? translate(achivements[index].title,
                                  args: achivements[index].args)
                              : '???',
                          style: Styles.h2,
                          textAlign: TextAlign.center,
                        ),
                      ],
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
  final String description;
  final IconData icon;
  final Color color;
  final bool Function()? isCompleted;

  final List<String>? args;

  FHARAchievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isCompleted,
    this.args,
  });
}
