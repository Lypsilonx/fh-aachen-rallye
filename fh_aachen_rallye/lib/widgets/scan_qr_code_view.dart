import 'dart:async';

import 'package:fh_aachen_rallye/fun_ui/fun_container.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_page.dart';
import 'package:fh_aachen_rallye/fun_ui/fun_text_input.dart';
import 'package:fh_aachen_rallye/helpers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRCodeView extends FunPage {
  final String? acceptRegex;
  final String? manualInput;

  const ScanQRCodeView({super.key, this.acceptRegex, this.manualInput});

  @override
  ScanQRCodeViewState createState() => ScanQRCodeViewState();

  @override
  Color get color => Colors.blue;

  @override
  String get tileAssetPath => "assets/background_1.png";

  @override
  double get tileSize => 200;
}

class ScanQRCodeViewState extends FunPageState<ScanQRCodeView>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
      // required options for the scanner
      );

  StreamSubscription<Object?>? _subscription;
  bool block = false;
  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      var barcode = barcodes.barcodes.firstOrNull;
      if (barcode != null && !block) {
        block = true;
        checkCode(barcode.rawValue!);
      }
    }
  }

  void checkCode(String code) async {
    if (widget.acceptRegex == null ||
        RegExp(widget.acceptRegex!).hasMatch(code)) {
      Navigator.pop(context, code);
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        block = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate('INVALID_QR_CODE')),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);
    unawaited(controller.start());
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FunContainer(
            child: MobileScanner(
              controller: controller,
              errorBuilder: (context, error, child) {
                return Text('Error: $error');
              },
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (widget.manualInput != null) const SizedBox(height: Sizes.large),
        if (widget.manualInput != null)
          FunTextInput(
            label: widget.manualInput!,
            submitButton: translate('SUBMIT'),
            onSubmitted: (value) {
              checkCode(value);
            },
          ),
      ],
    );
  }

  @override
  Widget title(BuildContext context) {
    return Text(translate('SCAN_QR_CODE'), style: Styles.h1);
  }
}
