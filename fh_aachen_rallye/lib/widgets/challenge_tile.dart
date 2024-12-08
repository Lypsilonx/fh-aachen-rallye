import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/widgets/challenge_view.dart';
import 'package:flutter/material.dart';

class ChallengeTile extends StatefulWidget {
  final String challengeId;

  const ChallengeTile(this.challengeId, {super.key});

  @override
  State<ChallengeTile> createState() => _ChallengeTileState();
}

class _ChallengeTileState extends State<ChallengeTile> {
  @override
  Widget build(BuildContext context) {
    Challenge challenge = Backend.getChallenge(widget.challengeId);
    ChallengeViewController challengeController =
        ChallengeViewController(challenge, onUpdate: setState);

    var statusIcon = Icon(
      challengeController.isCompleted
          ? Icons.check
          : challengeController.isNew
              ? Icons.play_arrow
              : Icons.play_arrow,
      color: challengeController.isCompleted
          ? Colors.green
          : challengeController.isNew
              ? Colors.grey
              : Colors.orange,
    );

    return FunContainer(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(challenge.category.icon, color: challenge.category.color),
        trailing: statusIcon,
        title: Text(challenge.title, style: Styles.h2),
        subtitle: Helpers.displayDifficulty(challenge.difficulty),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChallengeView(
                challengeController,
                onChallengeComplete: () {
                  challengeController.gotoStep(-1);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
