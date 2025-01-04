import 'dart:async';

import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/pages/page_account.dart';
import 'package:fh_aachen_rallye/pages/page_challenge_list.dart';
import 'package:fh_aachen_rallye/pages/page_login_register.dart';
import 'package:flutter/material.dart';

// build with: flutter build web --release --wasm --base-href="/fh-aachen-rallye/" -o ..

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Backend.init().then((value) => runApp(const FHAachenRallye()));
  // Poll cache every 10 seconds
  Timer.periodic(
    const Duration(seconds: 10),
    (_) => SubscriptionManager.pollCache(),
  );
}

class FHAachenRallye extends StatelessWidget {
  const FHAachenRallye({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      initialRoute: Backend.userId == null ? '/login' : '/challenges',
      routes: {
        '/login': (context) => const PageLoginRegister(),
        '/challenges': (context) => const PageChallengeList(),
        '/account': (context) => const PageAccount(),
      },
    );
  }
}
