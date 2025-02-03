import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/cache.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/settings.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:fh_aachen_rallye/widgets/challenge_tile.dart';
import 'package:fh_aachen_rallye/widgets/scan_qr_code_view.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class PageChallengeList extends FunPage {
  const PageChallengeList({super.key});

  @override
  String get title => 'CHALLENGES';

  @override
  String get navPath => '/challenges';

  @override
  IconData? get footerIcon => Icons.home;

  @override
  String get tileAssetPath => 'assets/background_1.png';

  @override
  double get tileSize => 200;

  @override
  Color get color => Colors.blue;

  @override
  State<PageChallengeList> createState() => _PageChallengeListState();
}

class _PageChallengeListState extends FunPageState<PageChallengeList>
    implements ServerObjectSubscriber {
  List<String> challengeIds = [];
  ChallengeCategory? get selectedCategory =>
      Backend.prefs.getString('PAGE_CHALLENGE_LIST_SELECTED_CATEGORY') != null
          ? ChallengeCategory.fromString(
              Backend.prefs.getString('PAGE_CHALLENGE_LIST_SELECTED_CATEGORY')!)
          : null;
  set selectedCategory(ChallengeCategory? value) {
    if (value == null) {
      Backend.prefs.remove('PAGE_CHALLENGE_LIST_SELECTED_CATEGORY');
    } else {
      Backend.prefs.setString(
          'PAGE_CHALLENGE_LIST_SELECTED_CATEGORY', value.categoryName());
    }
  }

  @override
  void initState() {
    super.initState();
    SubscriptionManager.subscribeAll<Challenge>(this);
    SubscriptionManager.subscribe<User>(this, Backend.userId!);
  }

  @override
  void dispose() {
    SubscriptionManager.unsubscribe(this);
    super.dispose();
  }

  @override
  void onUpdate(ServerObject object) {
    var hiddenTags = ['wip', 'empty', 'needs translation'];
    var challengeChache = Cache.fetchAll<Challenge>();
    challengeIds = challengeChache
        .where((e) =>
            e.language == Translator.language &&
            (Settings.showWipChallenges ||
                !hiddenTags.any((tag) => e.tags.contains(tag))))
        .map((e) => e.id)
        .toList();

    challengeIds.sort((a, b) {
      var challengeA = challengeChache.firstWhere((e) => e.id == a);
      var challengeB = challengeChache.firstWhere((e) => e.id == b);

      // sort by progress, then difficulty, then title (progress 1 last and ChallengeUserStatus.unlocked first)
      if (challengeA.userStatus == ChallengeUserStatus.unlocked &&
          challengeB.userStatus != ChallengeUserStatus.unlocked) {
        return -1;
      } else if (challengeB.userStatus == ChallengeUserStatus.unlocked &&
          challengeA.userStatus != ChallengeUserStatus.unlocked) {
        return 1;
      } else if (challengeA.progress == 1 && challengeB.progress != 1) {
        return 1;
      } else if (challengeB.progress == 1 && challengeA.progress != 1) {
        return -1;
      } else if (challengeA.progress != challengeB.progress) {
        return challengeA.progress - challengeB.progress > 0 ? -1 : 1;
      } else if (challengeA.difficulty.index != challengeB.difficulty.index) {
        return challengeA.difficulty.index - challengeB.difficulty.index;
      } else {
        return challengeA.title.compareTo(challengeB.title);
      }
    });

    setState(() {});
  }

  @override
  Function? get customBackAction => selectedCategory != null
      ? () {
          selectedCategory = null;
          setState(() {});
        }
      : null;

  @override
  Widget buildPage(BuildContext context) {
    if (selectedCategory == null) {
      var categories = ChallengeCategory.all;

      categories.sort((a, b) {
        // sort by progress (asc), then title
        var aProgress = challengeIds
                .map((id) => Cache.fetch<Challenge>(id)!)
                .where((e) => e.category == a && e.progress == 1)
                .length /
            challengeIds
                .map((id) => Cache.fetch<Challenge>(id)!)
                .where((e) => e.category == a)
                .length;
        var bProgress = challengeIds
                .map((id) => Cache.fetch<Challenge>(id)!)
                .where((e) => e.category == b && e.progress == 1)
                .length /
            challengeIds
                .map((id) => Cache.fetch<Challenge>(id)!)
                .where((e) => e.category == b)
                .length;

        if (aProgress != bProgress) {
          return aProgress - bProgress > 0 ? 1 : -1;
        } else {
          return translate(a.name).compareTo(translate(b.name));
        }
      });

      return Column(
        children: [
          Expanded(
            child: Helpers.blendList(
              GridView.count(
                padding: const EdgeInsets.symmetric(vertical: Sizes.medium),
                mainAxisSpacing: Sizes.medium,
                crossAxisSpacing: Sizes.medium,
                crossAxisCount: isSmall ? 2 : 3,
                children: categories
                    .map<Widget>(
                      (e) => FunButton(
                        LayoutBuilder(builder: (context, constraints) {
                          int newChallenges = challengeIds
                              .map((id) => Cache.fetch<Challenge>(id)!)
                              .where((challenge) =>
                                  challenge.category == e &&
                                  (challenge.state?.userStatus ??
                                          ChallengeUserStatus.new_) !=
                                      ChallengeUserStatus.none)
                              .length;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(Sizes.borderRadius),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Sizes.borderRadius),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()
                                          ..translate(
                                            Vector3(
                                              -constraints.maxWidth * 0.9,
                                              -constraints.maxHeight * 0.1,
                                              0,
                                            ),
                                          )
                                          ..rotateZ(-1.2)
                                          ..scale(1.5),
                                        child: Container(
                                          height: double.infinity,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: e.color.withSaturation(0.8),
                                          ),
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                    width:
                                                        constraints.maxHeight *
                                                            0.3),
                                                Text(
                                                  translate(e.name),
                                                  style: Styles.body.copyWith(
                                                      color: Colors.white,
                                                      fontSize: constraints
                                                              .maxHeight *
                                                          (translate(e.name)
                                                                      .length >
                                                                  14
                                                              ? 0.06
                                                              : 0.09)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: constraints.maxWidth * 0.1,
                                        child: Icon(
                                          e.icon,
                                          size: constraints.maxHeight * 0.4,
                                          color: e.color,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: Sizes.extraSmall,
                                        right: Sizes.small,
                                        child: Text(
                                          translate(
                                            'CHALLENGES_COMPLETED',
                                            args: [
                                              challengeIds
                                                  .where((id) {
                                                    var challenge =
                                                        Cache.fetch<Challenge>(
                                                            id)!;
                                                    return challenge.category ==
                                                            e &&
                                                        challenge.progress == 1;
                                                  })
                                                  .length
                                                  .toString(),
                                              challengeIds
                                                  .where((id) =>
                                                      Cache.fetch<Challenge>(
                                                              id)!
                                                          .category ==
                                                      e)
                                                  .length
                                                  .toString(),
                                            ],
                                          ),
                                          style: Styles.body
                                              .copyWith(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (newChallenges > 0)
                                Positioned(
                                  top: -Sizes.small,
                                  right: -Sizes.small,
                                  child: Container(
                                    width: Sizes.medium * 1.5,
                                    height: Sizes.medium * 1.5,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: e.color.withSaturation(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      newChallenges.toString(),
                                      style: Styles.body.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                        Colors.white,
                        onPressed: () {
                          selectedCategory = e;
                          setState(() {});
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: Sizes.medium),
          FunButton(
            translate('UNLOCK_CHALLENGE'),
            Colors.blue,
            onPressed: () async {
              var value = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanQRCodeView(
                    acceptRegex: r'^FHAR-[0-9A-Z]{8}$',
                    manualInput: translate('UNLOCK_CHALLENGE'),
                  ),
                ),
              );
              if (value != null) {
                var (success, message) = await Backend.unlockChallenge(value);
                if (RegExp(r'^\d+/\d+$').hasMatch(message)) {
                  var unlockedChallenges = int.parse(message.split('/')[0]);
                  var totalChallenges = int.parse(message.split('/')[1]);

                  if (totalChallenges == 0) {
                    message = translate('NO_CHALLENGES_FOUND');
                  } else if (unlockedChallenges == 0) {
                    message = translate('CHALLENGES_ALREADY_UNLOCKED');
                  } else if (unlockedChallenges < totalChallenges) {
                    message = translate('CHALLENGES_UNLOCKED', args: [
                      unlockedChallenges.toString(),
                      totalChallenges.toString()
                    ]);
                  } else if (unlockedChallenges == totalChallenges) {
                    message = (totalChallenges == 1
                        ? translate('CHALLENGE_UNLOCKED')
                        : translate('CHALLENGES_UNLOCKED_ALL',
                            args: [totalChallenges.toString()]));
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      );
    }

    var categoryChallengeIds = challengeIds
        .where((id) => Cache.fetch<Challenge>(id)!.category == selectedCategory)
        .toList();

    return Helpers.blendList(
      ListView.builder(
        clipBehavior: Clip.none,
        itemCount: categoryChallengeIds.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: Sizes.medium,
              top: index == 0 ? Sizes.medium : 0,
            ),
            child: ChallengeTile(
              categoryChallengeIds[index],
              key: UniqueKey(),
            ),
          );
        },
      ),
    );
  }
}
