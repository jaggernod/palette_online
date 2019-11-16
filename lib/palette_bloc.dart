import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaletteBloc extends Bloc<PaletteEvent, PaletteState> {
  PaletteBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker {
    _tickerSubscription =
        _ticker.tick().listen((duration) => add(CheckClipboardData()));
  }

  final Ticker _ticker;
  StreamSubscription<int> _tickerSubscription;

  @override
  PaletteState get initialState => EmptyPalette();

  @override
  Stream<PaletteState> mapEventToState(PaletteEvent event) async* {
    if (event is LoadImage) {
      yield LoadedImage(uri: Uri.parse(event.imageUrl));
    } else if (event is PasteData) {
      print("Text ${event.data}");
      if (event.data.isNotEmpty && Uri.tryParse(event.data) != null) {
        final newUri = Uri.parse(event.data);

        if (newUri.hasAuthority && newUri.hasScheme) {
          yield LoadedImage(uri: newUri);
        }
      }
    } else if (event is CheckClipboardData) {
      final data = await Clipboard.getData('text/plain');
      if (data.text?.isNotEmpty ?? false) {
        add(PasteData(data.text));
      }
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}

abstract class PaletteState extends Equatable {
  final Color color;
  final Uri uri;

  const PaletteState({this.color, this.uri});

  @override
  List<Object> get props => [color, uri];
}

class EmptyPalette extends PaletteState {
  const EmptyPalette() : super();

  @override
  String toString() => 'Empty {}';
}

class LoadedImage extends PaletteState {
  const LoadedImage({Uri uri}) : super(uri: uri);

  @override
  String toString() => 'Loaded { uri: $uri }';
}

class PickedColor extends PaletteState {
  const PickedColor({Uri uri}) : super(uri: uri);

  @override
  String toString() => 'PickedColor { uri: $uri }';
}

abstract class PaletteEvent extends Equatable {
  const PaletteEvent();

  @override
  List<Object> get props => [];
}

class LoadImage extends PaletteEvent {
  final String imageUrl;

  const LoadImage({@required this.imageUrl});

  @override
  String toString() => "LoadImage { imageUrl: $imageUrl }";
}

class PasteData extends PaletteEvent {
  final String data;

  const PasteData(this.data);

  @override
  String toString() => 'PasteData { data: $data }';
}

class CheckClipboardData extends PaletteEvent {
  const CheckClipboardData();

  @override
  String toString() => 'CheckClipboardData { }';
}

class Ticker {
  Stream<int> tick() {
    return Stream.periodic(Duration(seconds: 1));
  }
}
