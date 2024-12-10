import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/translation/translator.dart';

class TranslatedString implements Translateable {
  final String translationKey;
  final String fallback;

  TranslatedString(setState, this.translationKey, {this.fallback = ''}) {
    Translator.subscribe(this, setState);
  }

  String register(FunPageState state) {
    state.registerTranslateable(this);

    String translation = Translator.translate(translationKey, fallback);
    return translation;
  }
}
