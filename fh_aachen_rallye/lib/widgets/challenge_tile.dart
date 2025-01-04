import 'dart:math';

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
        currentStep = object.challengeStates[challenge.challengeId]?.step ?? -1;
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

    return Stack(
      children: [
        FunContainer(
          height: Sizes.extraLarge + Sizes.small,
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
            leading: LayoutBuilder(
              builder: (context, constraints) {
                double circleSize = constraints.maxHeight * 0.9;
                double iconSize = Sizes.small * 0.8;
                double center = (constraints.maxHeight - iconSize) / 2;
                return SizedBox(
                  width: constraints.maxHeight,
                  height: constraints.maxHeight - circleSize / 4,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: circleSize / 4,
                        ),
                        child: Center(
                          child: Icon(challenge.category.icon,
                              color: challenge.category.color),
                        ),
                      ),
                      // place stars in a radial pattern around the icon depending on the duration
                      ...List.generate(
                        challenge.duration.index,
                        (index) {
                          double iconAngle = 30;
                          double radialOffset =
                              max(challenge.duration.index - 1, 0) /
                                  2 *
                                  iconAngle;
                          double angle = index * iconAngle - radialOffset;
                          return Positioned(
                            left: (circleSize / 2) * sin(angle * pi / 180) +
                                center,
                            top: (circleSize / 2) * cos(angle * pi / 180) +
                                center -
                                circleSize / 4,
                            child: Icon(
                              Icons.circle,
                              color: challenge.category.color,
                              size: iconSize,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                );
              },
            ),
            trailing: statusIcon,
            title: Text(challenge.title,
                style: Styles.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Row(
              children: [
                Helpers.displayDifficulty(challenge.difficulty),
                Helpers.displayTags(challenge),
              ],
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: Sizes.extraLarge + Sizes.small,
              width: constraints.maxWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: constraints.maxWidth * challenge.progress,
                      height: Sizes.extraSmall,
                      color: challenge.progress == 1
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
