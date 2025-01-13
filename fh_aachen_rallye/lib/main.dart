import 'dart:async';

import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/pages/page_account.dart';
import 'package:fh_aachen_rallye/pages/page_challenge_list.dart';
import 'package:fh_aachen_rallye/pages/page_leaderboard.dart';
import 'package:fh_aachen_rallye/pages/page_login_register.dart';
import 'package:fh_aachen_rallye/pages/page_settings.dart';
import 'package:fh_aachen_rallye/widgets/scan_qr_code_view.dart';
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

  static const List<FunPage> pages = [
    PageLeaderboard(),
    PageChallengeList(),
    PageSettings(),
    PageAccount(),
    //Util
    PageLoginRegister(),
    ScanQRCodeView(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      initialRoute: Backend.userId == null
          ? const PageLoginRegister().navPath
          : const PageChallengeList().navPath,
      routes: Map.fromEntries(
        pages.map<MapEntry<String, WidgetBuilder>>(
          (page) => MapEntry(page.navPath, (context) => page),
        ),
      ),
    );
  }
}
