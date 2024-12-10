import 'package:fh_aachen_rallye/translation/translator.dart';
import 'package:flutter/widgets.dart';

class TranslatedText extends StatefulWidget {
  final String translationKey;
  final String fallback;
  final TextStyle? style;

  const TranslatedText(this.translationKey,
      {this.style, this.fallback = '', super.key});

  @override
  State<StatefulWidget> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText>
    implements Translateable {
  @override
  void initState() {
    super.initState();
    Translator.subscribe(this, setState);
  }

  @override
  void dispose() {
    Translator.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String translation =
        Translator.translate(widget.translationKey, widget.fallback);
    return Text(translation, style: widget.style);
  }
}
