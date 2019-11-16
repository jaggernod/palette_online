import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ColorBloc extends Bloc<ColorEvent, ColorState> {
  @override
  ColorState get initialState => Empty();

  @override
  Stream<ColorState> mapEventToState(ColorEvent event) async* {
    if (event is SelectColor) {
      yield Colorful(event.color);
    }
  }
}

abstract class ColorState extends Equatable {
  final Color color;

  const ColorState(this.color);

  @override
  List<Object> get props => [color];
}

class Empty extends ColorState {
  const Empty() : super(null);

  @override
  String toString() => 'Empty {}';
}

class Colorful extends ColorState {
  const Colorful(Color color) : super(color);

  @override
  String toString() => 'ChosenColor { color: $color }';
}

abstract class ColorEvent extends Equatable {
  const ColorEvent();

  @override
  List<Object> get props => [];
}

class SelectColor extends ColorEvent {
  final Color color;

  const SelectColor({@required this.color});

  @override
  String toString() => "SelectColor { color: $color }";
}
