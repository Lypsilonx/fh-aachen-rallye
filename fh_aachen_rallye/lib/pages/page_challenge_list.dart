import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/cache.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/widgets/challenge_tile.dart';
import 'package:fh_aachen_rallye/widgets/scan_qr_code_view.dart';
import 'package:flutter/material.dart';

class PageChallengeList extends FunPage {
  const PageChallengeList({super.key});

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
  @override
  Widget title(BuildContext context) =>
      Text(translate('CHALLENGES'), style: Styles.h1);

  @override
  Widget? trailing(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/account');
      },
      child: const Icon(
        Icons.account_circle,
        color: Colors.grey,
      ),
    );
  }

  List<String> challengeIds = [];

  @override
  void initState() {
    super.initState();
    SubscriptionManager.subscribeAll<Challenge>(this);
  }

  @override
  void dispose() {
    SubscriptionManager.unsubscribe(this);
    super.dispose();
  }

  @override
  void onUpdate(ServerObject object) {
    var challengeChache = Cache.fetchAll<Challenge>();
    challengeIds = challengeChache.map((e) => e.id).toList();
    setState(() {});
  }

  @override
  Widget buildPage(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: challengeIds.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: Sizes.medium),
                child: ChallengeTile(challengeIds[index]),
              );
            },
          ),
        ),
        FunButton(
          translate('UNLOCK_CHALLENGE'),
          Colors.blue,
          onPressed: () async {
            var value = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanQRCodeView(
                  acceptRegex: r'^FHAR-\d{4}$',
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
