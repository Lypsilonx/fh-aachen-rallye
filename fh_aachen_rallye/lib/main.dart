import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/pages/page_account.dart';
import 'package:fh_aachen_rallye/pages/page_challenge_list.dart';
import 'package:fh_aachen_rallye/pages/page_login_register.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Backend.init().then((value) => runApp(const FHAachenRallye()));
}

class FHAachenRallye extends StatelessWidget {
  const FHAachenRallye({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Backend.userId == null ? '/login' : '/challenges',
      routes: {
        '/login': (context) => const PageLoginRegister(),
        '/challenges': (context) => const PageChallengeList(),
        '/account': (context) => const PageAccount(),
      },
    );
  }
}
