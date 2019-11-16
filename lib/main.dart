import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_online/image_field.dart';

import 'palette_showcase.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Some widgets do not yet support desktop environments
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palette',
      home: HomePage(title: 'Palette'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uri uri;

  Color _color;

  @override
  void initState() {
    super.initState();

    Clipboard.getData('text/plain').then((data) {
      print("Text ${data.text}");
      if (data?.text != null &&
          data.text.isNotEmpty &&
          Uri.tryParse(data.text) != null) {
        final newUri = Uri.parse(data.text);

        if (newUri.hasAuthority && newUri.hasScheme) {
          setState(() {
            uri = Uri.parse(data.text);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: _color,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ImageField(
              onChanged: (url) {
                setState(() => uri = Uri.parse(url));
              },
              initial: uri?.toString(),
            ),
          ),
          if (uri != null)
            Expanded(
              child: PaletteShowcase(
                image: uri,
                onColorSelected: (color) {
                  setState(() {
                    _color = color;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
