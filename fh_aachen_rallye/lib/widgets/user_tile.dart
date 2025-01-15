import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/data/user.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:flutter/material.dart';

class UserTile extends StatefulWidget {
  final String userId;

  const UserTile(
    this.userId, {
    super.key,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends TranslatedState<UserTile>
    implements ServerObjectSubscriber {
  late User user;

  @override
  void initState() {
    super.initState();

    SubscriptionManager.subscribe<User>(this, widget.userId);
  }

  @override
  void dispose() {
    SubscriptionManager.unsubscribe(this);
    super.dispose();
  }

  @override
  void onUpdate(ServerObject object) {
    setState(() {
      user = object as User;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FunContainer(
      height: Sizes.extraLarge + Sizes.small,
      padding: EdgeInsets.zero,
      child: ListTile(
        title: Text(user.name, style: Styles.h2),
        subtitle: user.name != user.username
            ? Text(
                user.username,
                style: Styles.subtitle.copyWith(
                  color: Colors.grey,
                ),
              )
            : null,
        trailing: Text(
          user.points.toString(),
          style: Styles.subtitle,
        ),
      ),
    );
  }
}
