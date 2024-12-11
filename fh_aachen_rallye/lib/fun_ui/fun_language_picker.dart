import 'package:country_flags/country_flags.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:flutter/material.dart';

class FunLanguagePicker extends StatefulWidget {
  const FunLanguagePicker({super.key});

  @override
  State<FunLanguagePicker> createState() => _FunLanguagePickerState();
}

class _FunLanguagePickerState extends State<FunLanguagePicker> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Language>(
      popUpAnimationStyle: AnimationStyle.noAnimation,
      color: Colors.transparent,
      elevation: 0,
      constraints: BoxConstraints.expand(
        width: Sizes.large + Sizes.medium,
        height: Language.values.length * (Sizes.large + Sizes.medium) +
            Sizes.medium,
      ),
      onSelected: (Language language) {
        Translator.setLanguage(language);
        setState(() {});
      },
      offset: const Offset(Sizes.small, Sizes.large + Sizes.small),
      itemBuilder: (BuildContext context) {
        return Language.values.map((Language language) {
          var index = Language.values.indexOf(language);
          return PopupMenuItem<Language>(
            enabled: false,
            padding: EdgeInsets.zero,
            value: language,
            child: FunContainer(
              onTap: () {
                Navigator.pop(context, language);
              },
              hoverStrength: 0.2,
              color: Colors.white,
              rounded: RoundedSides(
                topLeft: index == 0,
                topRight: index == 0,
                bottomLeft: index == Language.values.length - 1,
                bottomRight: index == Language.values.length - 1,
              ),
              builder: (hovered) => buildFlag(language, hovered: hovered),
            ),
          );
        }).toList();
      },
      child: buildFlag(Translator.language),
    );
  }

  Widget buildFlag(Language language, {bool hovered = false}) {
    return Container(
      width: Sizes.large,
      height: Sizes.large,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: hovered ? Colors.white : Colors.black,
          width: 2,
        ),
      ),
      child: CountryFlag.fromLanguageCode(
        language.name,
        width: Sizes.large,
        height: Sizes.large,
        shape: const Circle(),
      ),
    );
  }
}
