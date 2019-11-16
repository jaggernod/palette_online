import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_online/color_bloc.dart';
import 'package:palette_online/palette_bloc.dart';

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
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PaletteBloc>(
          builder: (_) => PaletteBloc(ticker: Ticker()),
        ),
        BlocProvider<ColorBloc>(builder: (_) => ColorBloc()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocBuilder<ColorBloc, ColorState>(
              builder: (context, state) {
                return state.color != null
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: 100,
                          height: 100,
                          color: state.color,
                          child: Center(
                            child: Text(
                              '0x${state.color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    : SizedBox();
              },
            ),
            Expanded(
              child: Builder(
                builder: (context) => BlocBuilder<PaletteBloc, PaletteState>(
                    builder: (context, state) {
                  return state.uri != null
                      ? PaletteShowcase(
                          image: state.uri,
                          onColorSelected: (color) =>
                              BlocProvider.of<ColorBloc>(context).add(
                            SelectColor(color: color),
                          ),
                        )
                      : Center(
                          child: Text(
                          'Copy a web link of an image',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ));
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
