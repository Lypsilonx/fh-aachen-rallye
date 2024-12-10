import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translation/translated_text.dart';
import 'package:fh_aachen_rallye/widgets/challenge_tile.dart';
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
      TranslatedText('CHALLENGES', style: Styles.h1);

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
    var challengeChache = Cache.serverObjects[Challenge];
    if (challengeChache != null) {
      challengeIds = challengeChache.keys.toList();
      setState(() {});
    }
  }

  @override
  Widget buildPage(BuildContext context) {
    return ListView.builder(
      itemCount: challengeIds.length,
      itemBuilder: (context, index) {
        return ChallengeTile(challengeIds[index]);
      },
    );
  }
}
