import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/helpers.dart';
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

class _PageChallengeListState extends FunPageState<PageChallengeList> {
  @override
  Widget title(BuildContext context) => Text('Challenges', style: Styles.h1);

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

  @override
  Widget buildPage(BuildContext context) {
    var challenges = Backend.getChallengeIds();

    return ListView.builder(
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return ChallengeTile(challenges[index]);
      },
    );
  }
}
