import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:fh_aachen_rallye/settings.dart';
import 'package:fh_aachen_rallye/translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FunNumberPicker<T extends num> extends StatefulWidget {
  final SettingsEntry<T> settingsEntry;

  const FunNumberPicker(
    this.settingsEntry, {
    super.key,
  });

  @override
  State<FunNumberPicker<T>> createState() => _FunNumberPickerState<T>();
}

class _FunNumberPickerState<T extends num>
    extends TranslatedState<FunNumberPicker<T>> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(
      text: Settings.get(widget.settingsEntry).toString(),
    );
    return FunContainer(
      expand: false,
      padding: EdgeInsets.symmetric(
        horizontal: switch (T) {
          int => Sizes.small,
          double => Sizes.medium,
          _ => throw Exception('Unknown type'),
        },
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (T == int)
            IconButton(
              color: Settings.get(widget.settingsEntry) ==
                      (widget.settingsEntry).options['min']
                  ? Colors.grey
                  : null,
              iconSize: Sizes.medium,
              icon: const Icon(Icons.remove),
              onPressed: () {
                Settings.set<T>(
                  widget.settingsEntry,
                  Settings.get(widget.settingsEntry) - 1 as T,
                );
                controller.text = Settings.get(
                  widget.settingsEntry,
                ).toString();
                setState(() {});
              },
            ),
          Padding(
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
                  keyboardType: TextInputType.numberWithOptions(
                    signed: true,
                    decimal: T == double,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                      switch (T) {
                        int => RegExp(r'^-?[0-9]*$'),
                        double => RegExp(r'^-?[0-9]*\.?[0-9]*$'),
                        _ => throw Exception('Unknown type'),
                      },
                    ),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  controller: controller,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      return;
                    }
                    Settings.set<T>(
                      widget.settingsEntry,
                      switch (T) {
                        int => int.parse(value),
                        double => double.parse(value),
                        _ => throw Exception('Unknown type'),
                      } as T,
                    );
                  },
                  onSubmitted: (value) {
                    controller.text = Settings.get(
                      widget.settingsEntry,
                    ).toString();
                    setState(() {});
                  },
                  onTapOutside: (value) {
                    controller.text = Settings.get(
                      widget.settingsEntry,
                    ).toString();
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          if (T == int)
            IconButton(
              color: Settings.get(widget.settingsEntry) ==
                      (widget.settingsEntry).options['max']
                  ? Colors.grey
                  : null,
              iconSize: Sizes.medium,
              icon: const Icon(Icons.add),
              onPressed: () {
                Settings.set<T>(
                  widget.settingsEntry,
                  Settings.get(widget.settingsEntry) + 1 as T,
                );
                controller.text = Settings.get(
                  widget.settingsEntry,
                ).toString();
                setState(() {});
              },
            ),
        ],
      ),
    );
  }
}
