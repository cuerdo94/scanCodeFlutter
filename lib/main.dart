import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lectura/read_camera_widget.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<bool> _hidden = ValueNotifier(true);

  final ValueNotifier<String> _readingValue = ValueNotifier("");
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Reading example '),
          actions: [
            IconButton(
                onPressed: () {
                  deleteText();
                  _hidden.value = !_hidden.value;
                },
                icon: const Icon(Icons.camera))
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: _hidden,
          builder: (BuildContext context, bool value, Widget? child) {
            return value
                ? Column(
                    children: [
                      ListTile(
                          title: const Text("Reading"),
                          subtitle: ValueListenableBuilder(
                            valueListenable: _readingValue,
                            builder: (BuildContext context, String value,
                                Widget? child) {
                              return SizedBox(
                                height: 60,
                                child: Text(
                                  value,
                                  maxLines: 3,
                                ),
                              );
                            },
                          ),
                          trailing: IconButton(
                              onPressed: () => deleteText(),
                              icon: const Icon(Icons.delete))),
                      Expanded(
                        child: ReadingCameraWidget(
                          onChange: (String value) {
                            if (kDebugMode) {
                              print(value);
                            }
                            _readingValue.value = value;
                          },
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text("Nada nada Limonada"),
                  );
          },
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     _hidden.value = !_hidden.value;
        //   },
        //   child: const Icon(Icons.camera),
        // ),
      ),
    );
  }

  String deleteText() => _readingValue.value = "";
}
