import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_number_picker.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/settings.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FunSetting<T> extends StatefulWidget {
  final SettingsEntry<T> settingsEntry;

  const FunSetting(
    this.settingsEntry, {
    super.key,
  });

  @override
  State<FunSetting<T>> createState() => _FunSettingState<T>();
}

class _FunSettingState<T> extends TranslatedState<FunSetting<T>> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(translate(widget.settingsEntry.key)),
      trailing: switch (T) {
        bool => Switch(
            value: Settings.get(widget.settingsEntry as SettingsEntry<bool>),
            onChanged: (value) {
              Settings.set(widget.settingsEntry as SettingsEntry<bool>, value);
              setState(() {});
            },
          ),
        int => FunNumberPicker<int>(
            widget.settingsEntry as SettingsEntry<int>,
          ),
        double => FunNumberPicker<double>(
            widget.settingsEntry as SettingsEntry<double>,
          ),
        String => Builder(builder: (context) {
            TextEditingController controller = TextEditingController(
              text: Settings.get(widget.settingsEntry as SettingsEntry<String>),
            );
            return FunContainer(
              expand: false,
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.medium,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: Sizes.extraSmall / 2),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Sizes.extraLarge * 2,
                    minWidth: Sizes.large,
                  ),
                  child: IntrinsicWidth(
                    child: TextField(
                      cursorHeight: Sizes.medium,
                      style: Styles.bodyLarge,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: controller,
                      onChanged: (value) {
                        Settings.set<String>(
                          widget.settingsEntry as SettingsEntry<String>,
                          value,
                        );
                      },
                      onSubmitted: (value) {
                        controller.text = Settings.get<String>(
                          widget.settingsEntry as SettingsEntry<String>,
                        ).toString();
                        setState(() {});
                      },
                      onTapOutside: (value) {
                        controller.text = Settings.get<String>(
                          widget.settingsEntry as SettingsEntry<String>,
                        ).toString();
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            );
          }),
        _ => const Text('Unknown type'),
      },
    );
  }
}
