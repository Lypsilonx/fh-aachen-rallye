import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_text_input.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translation/translated_text.dart';
import 'package:fh_aachen_rallye/translation/translator.dart';
import 'package:flutter/material.dart';

class PageLoginRegister extends FunPage {
  const PageLoginRegister({super.key});

  @override
  String get tileAssetPath => 'assets/background_1.png';

  @override
  double get tileSize => 200;

  @override
  Color get color => Colors.grey;

  @override
  State<PageLoginRegister> createState() => _PageLoginRegisterState();
}

class _PageLoginRegisterState extends FunPageState<PageLoginRegister> {
  TextEditingController usernameController = TextEditingController();

  bool isLogin = true;

  @override
  Widget title(BuildContext context) =>
      TranslatedText(isLogin ? 'LOGIN' : 'REGISTER', style: Styles.h1);

  @override
  Widget buildPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          height: Sizes.large,
        ),
        Column(
          children: [
            FunTextInput(
              label: translate('USERNAME'),
              controller: usernameController,
            ),
            const SizedBox(height: Sizes.small),
            FunTextInput(
              label: translate('PASSWORD'),
              obscureText: true,
              submitButton:
                  isLogin ? translate('LOGIN') : translate('REGISTER'),
              onSubmitted: (value) async {
                var (loggedIn, failMessage) = isLogin
                    ? await Backend.login(usernameController.text, value)
                    : await Backend.register(usernameController.text, value);
                if (loggedIn) {
                  Navigator.of(context).pushReplacementNamed('/challenges');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(failMessage),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: Sizes.large),
        FunButton(
          isLogin
              ? translate('NOT_REGISTERED')
              : translate('ALREADY_REGISTERED'),
          Colors.orange,
          onPressed: () => {
            setState(() {
              isLogin = !isLogin;
            }),
          },
        ),
        FunButton(
          Translator.language == Language.english
              ? 'Zu Deutsch wechseln'
              : 'Switch to English',
          Colors.blue,
          onPressed: () {
            Translator.setLanguage(
              Translator.language == Language.english
                  ? Language.german
                  : Language.english,
            );
          },
        ),
      ],
    );
  }
}
