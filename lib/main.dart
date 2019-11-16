import 'dart:io';

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
          children: [
            BlocBuilder<ColorBloc, ColorState>(
              builder: (context, state) {
                return Container(
                  width: 200,
                  height: 200,
                  color: state.color,
                );
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
                      : SizedBox();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
