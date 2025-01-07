import 'dart:math';

import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/challenge.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:fh_aachen_rallye/widgets/challenge_view.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class ChallengeTile extends StatefulWidget {
  final String challengeId;

  const ChallengeTile(this.challengeId, {super.key});

  @override
  State<ChallengeTile> createState() => _ChallengeTileState();
}

class _ChallengeTileState extends TranslatedState<ChallengeTile>
    implements ServerObjectSubscriber {
  late Challenge challenge;
  late int currentStep;

  @override
  void initState() {
    super.initState();

    SubscriptionManager.subscribe<Challenge>(this, widget.challengeId);
  }

  @override
  void dispose() {
    SubscriptionManager.unsubscribe(this);
    super.dispose();
  }

  @override
  void onUpdate(ServerObject object) {
    setState(() {
      challenge = object as Challenge;
      currentStep = challenge.state?.step ?? -1;
    });
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
      clipBehavior: Clip.none,
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
          onLongPress: () {
            if (widget.challengeId == '') {
              return;
            }

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Reset Challenge \"${challenge.title}\"?"),
                  content: const Text(
                      "This will reset the challenge to the beginning. Are you sure?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(translate('CLOSE')),
                    ),
                    TextButton(
                      onPressed: () {
                        Backend.setChallengeState(
                          challenge,
                          ChallengeState(
                              -1, null, [], ChallengeUserStatus.new_),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(translate('RESET')),
                    ),
                  ],
                );
              },
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
            subtitle: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Helpers.displayDifficulty(challenge.difficulty),
                    Helpers.displayTags(
                      challenge,
                      constraints.maxWidth - Sizes.extraLarge * 2,
                    ),
                  ],
                );
              },
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
        if (challenge.userStatus != ChallengeUserStatus.none)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.translation(Vector3(
              -Sizes.small,
              -Sizes.small,
              0,
            ))
              ..rotateZ(-pi / 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: Sizes.extraSmall,
                    horizontal: Sizes.small,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.all(Radius.circular(Sizes.borderRadius)),
                  ),
                  child: Center(
                    child: Text(
                      translate(challenge.userStatus.badgeMessage),
                      style: Styles.bodySmall.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }
}
