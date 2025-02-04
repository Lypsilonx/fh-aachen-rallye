import 'dart:async';
import 'dart:io';

import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/data/server_object.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/pages/page_account.dart';
import 'package:fh_aachen_rallye/pages/page_achievements.dart';
import 'package:fh_aachen_rallye/pages/page_challenge_list.dart';
import 'package:fh_aachen_rallye/pages/page_challenge_view.dart';
import 'package:fh_aachen_rallye/pages/page_leaderboard.dart';
import 'package:fh_aachen_rallye/pages/page_login_register.dart';
import 'package:fh_aachen_rallye/pages/page_settings.dart';
import 'package:fh_aachen_rallye/widgets/scan_qr_code_view.dart';
import 'package:flutter/material.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

// build with: flutter build web --release --wasm --base-href="/fh-aachen-rallye/" -o ..

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    print("Error :  ${details.exception}");
    print(Trace.from(details.stack!).terse);
  };
  Chain.capture(() async {
    runApp(const FHAachenRallye());
  }, onError: (error, stackTrace) {
    print("Async Error :  $error");
    print(stackTrace.terse);
  });
}

class FHAachenRallye extends StatefulWidget {
  const FHAachenRallye({super.key});

  static const List<FunPage> pages = [
    PageLeaderboard(),
    PageChallengeList(),
    PageAchievements(),
    PageSettings(),
    //Util
    PageAccount(),
    PageLoginRegister(),
    PageChallengeView(),
    ScanQRCodeView(),
  ];

  @override
  State<FHAachenRallye> createState() => FHAachenRallyeState();
}

enum AppSate { loading, loggedIn, loggedOut, noInternet }

class FHAachenRallyeState extends State<FHAachenRallye> {
  static AppSate appState = AppSate.loading;

  static Timer? updateTimer;

  void update() async {
    try {
      if (kIsWeb) {
        await http.get(Uri.parse('www.example.com'));
      } else {
        await InternetAddress.lookup('www.example.com');
      }
      if (!Backend.initialized) {
        await Backend.init();
      } else {
        SubscriptionManager.pollCache();
      }
      if (await Backend.checkToken()) {
        if (appState != AppSate.loggedIn) {
          setState(() {
            appState = AppSate.loggedIn;
          });
        }
      } else {
        if (Backend.userId != null) {
          Backend.logout(context);
          setState(() {});
        }
        if (appState != AppSate.loggedOut) {
          setState(() {
            appState = AppSate.loggedOut;
          });
        }
      }
    } on SocketException catch (_) {
      if (appState != AppSate.noInternet) {
        setState(() {
          appState = AppSate.noInternet;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (updateTimer == null) {
      update();
      updateTimer = Timer.periodic(
        const Duration(seconds: 10),
        (timer) => update(),
      );
    }
    return MaterialApp(
      title: 'FH Aachen Rallye',
      color: Colors.blue,
      key: UniqueKey(),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      routes: Map.fromEntries(
        FHAachenRallye.pages.map<MapEntry<String, WidgetBuilder>>(
          (page) => MapEntry(page.navPath, (context) {
            if (page is PageChallengeView) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
              return PageChallengeView(
                challengeId: args['challengeId'] as String,
              );
            }
            return page;
          }),
        ),
      ),
      initialRoute:
          appState == AppSate.loading || appState == AppSate.noInternet
              ? null
              : appState == AppSate.loggedOut
                  ? const PageLoginRegister().navPath
                  : const PageChallengeList().navPath,
      home: appState == AppSate.loading || appState == AppSate.noInternet
          ? Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: appState == AppSate.noInternet
                      ? const [
                          Icon(Icons.wifi_off),
                          SizedBox(height: Sizes.medium),
                          Text('No internet connection'),
                        ]
                      : const [
                          CircularProgressIndicator(),
                          SizedBox(height: Sizes.medium),
                          Text('Loading...'),
                        ],
                ),
              ),
            )
          : null,
    );
  }
}
