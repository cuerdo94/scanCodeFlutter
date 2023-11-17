import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mlkit_scanner/mlkit_scanner.dart';

class ReadingCameraWidget extends StatefulWidget {
  final Function(String value) onChange;
  final Color colorText;
  final Color backgroundColor;
  const ReadingCameraWidget({
    Key? key,
    required this.onChange,
    this.colorText = Colors.white,
    this.backgroundColor = Colors.black,
  }) : super(key: key);

  @override
  State<ReadingCameraWidget> createState() => _LecturaCamaraState();
}

class _LecturaCamaraState extends State<ReadingCameraWidget> {
  late BarcodeScannerController _controller;

  final ValueNotifier<bool> _pause = ValueNotifier(true);
  final ValueNotifier<bool> _flash = ValueNotifier(false);
  final ValueNotifier<int> _zoom = ValueNotifier(0);
  final int zoomValue = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BarcodeScanner(
            onScannerInitialized: _onScannerInitialized,
            initialArguments: const AndroidScannerParameters(
              cropRect: CropRect(scaleHeight: 0.7, scaleWidth: 0.7),
            ),
            onCameraInitializeError: (error) {},
            onScan: (barcode) {
              _pause.value = false;
              _controller.pauseCamera();
              if (kDebugMode) {
                print(barcode.displayValue);
              }
              widget.onChange(barcode.displayValue!);
            },
          ),
        ),
        accionButton()
      ],
    );
  }

  Widget accionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ValueListenableBuilder(
          valueListenable: _flash,
          builder: (BuildContext context, dynamic value, Widget? child) {
            return IconButton(
                onPressed: () async {
                  await _controller.toggleFlash();
                  _flash.value = !_flash.value;
                },
                icon: Icon(value ? Icons.flash_off : Icons.flash_on));
          },
        ),
        IconButton(
            onPressed: () async {
              if (_zoom.value < 10) {
                _zoom.value += zoomValue;
                if (kDebugMode) {
                  print(_zoom);
                }
                await _controller.setZoom(_zoom.value / 10);
              }
            },
            icon: const Icon(Icons.zoom_in)),
        ValueListenableBuilder(
          valueListenable: _zoom,
          builder: (BuildContext context, int value, Widget? child) {
            return CircleText(
              text: (value / 10).toStringAsFixed(1),
              backgroundColor: widget.backgroundColor,
              colorText: widget.colorText,
              diameter: 50,
            );
          },
        ),
        IconButton(
            onPressed: () async {
              if (_zoom.value > 0) {
                _zoom.value -= zoomValue;
                if (kDebugMode) {
                  print(_zoom);
                }
                await _controller.setZoom(_zoom.value / 10);
              }
            },
            icon: const Icon(Icons.zoom_out)),
        ValueListenableBuilder(
          valueListenable: _pause,
          builder: (BuildContext context, bool value, Widget? child) {
            return IconButton(
                onPressed: () async {
                  if (value) {
                    await _controller.pauseCamera();
                  } else {
                    await _controller.resumeCamera();
                  }
                  _pause.value = !value;
                },
                icon: Icon(value ? Icons.pause : Icons.play_arrow));
          },
        )
      ],
    );
  }

  Future<void> _onScannerInitialized(
      BarcodeScannerController controller) async {
    _controller = controller;

    await controller.startScan(0);
    await controller.setDelay(0);

    _zoom.value = 0;
    if (kDebugMode) {
      print(_zoom);
    }
    await controller.setZoom(_zoom.value.toDouble());
  }
}

class CircleText extends StatelessWidget {
  final String text;
  final Color colorText;
  final Color backgroundColor;
  final double diameter;

  const CircleText({
    super.key,
    required this.text,
    required this.colorText,
    required this.backgroundColor,
    required this.diameter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: colorText,
          ),
        ),
      ),
    );
  }
}
