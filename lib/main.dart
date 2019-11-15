import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  Uri uri = Uri.parse(
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTYLJMPNl9X_9K05O19gtgSvwJE9780d4Zm3fQxXHA9qqVsaYl5pg&s');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: ImageField(onChanged: (url) {
              uri = Uri.parse(url);

              setState(() {});
            }),
          ),
          Expanded(
            child: PaletteShowcase(image: uri),
          ),
        ],
      ),
    );
  }
}
