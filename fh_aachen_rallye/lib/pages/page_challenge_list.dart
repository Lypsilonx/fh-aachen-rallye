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
  Widget buildPage(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Helpers.blendList(
            ListView.builder(
              clipBehavior: Clip.none,
              itemCount: challengeIds.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: Sizes.medium,
                    top: index == 0 ? Sizes.medium : 0,
                  ),
                  child: ChallengeTile(
                    challengeIds[index],
                    key: UniqueKey(),
                  ),
                );
              },
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
}
