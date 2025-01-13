import 'package:fh_aachen_rallye/backend.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_button.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_language_picker.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_text_input.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';

class PageLoginRegister extends FunPage {
  const PageLoginRegister({super.key});

  @override
  String get title => 'LOGIN';

  @override
  String get navPath => '/login';

  @override
  IconData? get footerIcon => null;

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
  String get title => isLogin ? widget.title : 'REGISTER';

  @override
  Widget trailing(BuildContext context) {
    return const FunLanguagePicker();
  }

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
      ],
    );
  }
}
