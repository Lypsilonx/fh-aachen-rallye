import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
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

class _ChallengeTileState extends State<ChallengeTile>
    implements ServerObjectSubscriber {
  late Challenge challenge;
  late int currentStep;

  @override
  void initState() {
    super.initState();

    SubscriptionManager.subscribe<Challenge>(this, widget.challengeId);
    SubscriptionManager.subscribe<User>(this, Backend.userId!);
  }

  @override
  void dispose() {
    SubscriptionManager.unsubscribe(this);
    super.dispose();
  }

  @override
  void onUpdate(ServerObject object) {
    if (object is Challenge) {
      setState(() {
        challenge = object;
      });
    } else if (object is User) {
      setState(() {
        currentStep = object.challengeStates[challenge.challengeId] ?? -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var statusIcon = Icon(
      currentStep == -2
          ? Icons.check
          : currentStep == -1
              ? Icons.play_arrow
              : Icons.play_arrow,
      color: currentStep == -2
          ? Colors.green
          : currentStep == -1
              ? Colors.grey
              : Colors.orange,
    );

    return FunContainer(
      onTap: () {
        if (widget.challengeId == '') {
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeView(widget.challengeId),
          ),
        );
      },
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(challenge.category.icon, color: challenge.category.color),
        trailing: statusIcon,
        title: Text(challenge.title, style: Styles.h2),
        subtitle: Helpers.displayDifficulty(challenge.difficulty),
      ),
    );
  }
}
