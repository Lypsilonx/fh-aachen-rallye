import 'dart:async';
import 'dart:io';

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
  runApp(const FHAachenRallye());
}

class FHAachenRallye extends StatefulWidget {
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
  State<FHAachenRallye> createState() => FHAachenRallyeState();
}

class FHAachenRallyeState extends State<FHAachenRallye> {
  static bool hasInternet = false;
  static bool validToken = false;

  @override
  void initState() {
    super.initState();

    // look for internet every few seconds
    update();
    Timer.periodic(
      const Duration(seconds: 10),
      (timer) => update(),
    );
  }

  void update() async {
    try {
      await InternetAddress.lookup('example.com');
      if (!hasInternet) {
        setState(() {
          hasInternet = true;
        });
      }
      if (!Backend.initialized) {
        await Backend.init();
      } else {
        SubscriptionManager.pollCache();
      }
      if (await Backend.checkToken()) {
        if (!validToken) {
          setState(() {
            validToken = true;
          });
        }
      } else {
        if (Backend.userId != null) {
          Backend.logout(context);
        }
      }
    } on SocketException catch (_) {
      if (hasInternet) {
        setState(() {
          hasInternet = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: UniqueKey(),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      routes: Map.fromEntries(
        FHAachenRallye.pages.map<MapEntry<String, WidgetBuilder>>(
          (page) => MapEntry(page.navPath, (context) {
            return page;
          }),
        ),
      ),
      initialRoute: hasInternet
          ? !validToken
              ? const PageLoginRegister().navPath
              : const PageChallengeList().navPath
          : null,
      home: hasInternet
          ? null
          : const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off),
                    Text('No internet connection'),
                  ],
                ),
              ),
            ),
    );
  }
}
