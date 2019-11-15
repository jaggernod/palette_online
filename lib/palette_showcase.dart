import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class PaletteShowcase extends StatelessWidget {
  const PaletteShowcase({Key key, @required this.image})
      : assert(image != null),
        super(key: key);

  final Uri image;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Flexible(flex: 2, child: Image.network(image.toString())),
        Flexible(
          flex: 1,
          child: _PaletteColors(
            image: image,
          ),
        ),
      ],
    );
  }
}

class _PaletteColors extends StatelessWidget {
  const _PaletteColors({Key key, @required this.image})
      : assert(image != null),
        super(key: key);

  final Uri image;

  Future<Map<PaletteTarget, PaletteColor>> _updatePaletteGenerator() async {
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(image.toString()),
      timeout: Duration.zero, // Never give up! Never surrender!
    );

    final swatches = Map.of(paletteGenerator.selectedSwatches);

    swatches[PaletteTarget()] = paletteGenerator.dominantColor;
    return swatches;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _updatePaletteGenerator(),
      initialData: <PaletteTarget, PaletteColor>{},
      builder:
          (context, AsyncSnapshot<Map<PaletteTarget, PaletteColor>> snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              snapshot.data.entries.where((entry) => entry.value != null).map(
            (entry) {
              return _PaletteColor(
                colorName: _name(entry.key),
                paletteColor: entry.value,
              );
            },
          ).toList(),
        );
      },
    );
  }

  String _name(PaletteTarget target) {
    if (target == PaletteTarget.lightVibrant) {
      return 'Light Vibrant';
    } else if (target == PaletteTarget.vibrant) {
      return 'Vibrant';
    } else if (target == PaletteTarget.darkVibrant) {
      return 'Dark Vibrant';
    } else if (target == PaletteTarget.lightMuted) {
      return 'Light Muted';
    } else if (target == PaletteTarget.muted) {
      return 'Muted';
    } else if (target == PaletteTarget.darkMuted) {
      return 'Dark Muted';
    } else
      return "Dominant";
  }
}

class _PaletteColor extends StatefulWidget {
  const _PaletteColor(
      {Key key, @required this.colorName, @required this.paletteColor})
      : assert(colorName != null),
        assert(paletteColor != null),
        super(key: key);

  final String colorName;
  final PaletteColor paletteColor;

  @override
  _PaletteColorState createState() => _PaletteColorState();
}

class _PaletteColorState extends State<_PaletteColor>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  Color background;
  Color titleColor;
  ColorTween _backgroundColorTween;
  ColorTween _titleColorTween;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    )..addListener(() => setState(() {}));

    _updatePalette(
      newPalette: widget.paletteColor,
    );
  }

  @override
  void didUpdateWidget(_PaletteColor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.colorName != widget.colorName) {
      _updatePalette(
        oldPalette: oldWidget.paletteColor,
        newPalette: widget.paletteColor,
      );
    }
  }

  Future<void> _updatePalette({
    PaletteColor oldPalette,
    @required PaletteColor newPalette,
  }) async {
    if (mounted) {
      background = newPalette.color;
      titleColor = newPalette.titleTextColor
          .withRed(255 - newPalette.titleTextColor.red)
          .withGreen(255 - newPalette.titleTextColor.red)
          .withBlue(255 - newPalette.titleTextColor.blue);

      _backgroundColorTween = ColorTween(
        begin: oldPalette?.color ?? Colors.white,
        end: background,
      );

      _titleColorTween = ColorTween(
        begin: oldPalette?.bodyTextColor ?? Colors.white,
        end: titleColor,
      );

      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColorTween.evaluate(_animation),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          widget.colorName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _titleColorTween.evaluate(_animation),
          ),
        ),
      ),
    );
  }
}
