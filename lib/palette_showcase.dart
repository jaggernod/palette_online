import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

typedef OnColorSelected = void Function(Color);

class PaletteShowcase extends StatelessWidget {
  const PaletteShowcase({
    Key key,
    @required this.image,
    this.onColorSelected,
  })  : assert(image != null),
        super(key: key);

  final Uri image;
  final OnColorSelected onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.network(
          image.toString(),
          fit: BoxFit.cover,
          width: 300,
          height: 300,
        ),
        Flexible(
          flex: 1,
          child: SizedBox(
            width: 300,
            height: 300,
            child: _PaletteColors(
              image: image,
              onColorSelected: onColorSelected,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaletteColors extends StatefulWidget {
  const _PaletteColors({Key key, @required this.image, this.onColorSelected})
      : assert(image != null),
        super(key: key);

  final Uri image;
  final OnColorSelected onColorSelected;

  @override
  __PaletteColorsState createState() => __PaletteColorsState();
}

class __PaletteColorsState extends State<_PaletteColors> {
  Map<PaletteTarget, PaletteColor> selectedSwatches = {};

  @override
  void initState() {
    super.initState();

    _updatePaletteGenerator().then((palette) {
      if (mounted) {
        setState(() {
          selectedSwatches = palette;
        });
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          selectedSwatches = {};
        });
      }
    });
  }

  @override
  void didUpdateWidget(_PaletteColors oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.image != widget.image) {
      _updatePaletteGenerator().then((palette) {
        if (mounted) {
          setState(() {
            selectedSwatches = palette;
          });
        }
      }).catchError((_) {
        if (mounted) {
          setState(() {
            selectedSwatches = {};
          });
        }
      });
    }
  }

  Future<Map<PaletteTarget, PaletteColor>> _updatePaletteGenerator() async {
    print('Generate palette...');
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.image.toString()),
      );

      final swatches = Map.of(paletteGenerator.selectedSwatches);

      swatches[PaletteTarget()] = paletteGenerator.dominantColor;

      print('Generate palette... Done ${swatches.length}');

      return swatches;
    } on Exception catch (e) {
      print('Unable to load the palette $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children:
          selectedSwatches.entries.where((entry) => entry.value != null).map(
        (entry) {
          return GestureDetector(
            onTap: () {
              if (widget.onColorSelected != null) {
                widget.onColorSelected(entry.value.color);
              }
            },
            child: _PaletteColor(
              colorName: _name(entry.key),
              paletteColor: entry.value,
            ),
          );
        },
      ).toList(),
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
  const _PaletteColor({
    Key key,
    @required this.colorName,
    @required this.paletteColor,
    this.onColorSelected,
  })  : assert(colorName != null),
        assert(paletteColor != null),
        super(key: key);

  final String colorName;
  final PaletteColor paletteColor;
  final OnColorSelected onColorSelected;

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
      titleColor = newPalette.titleTextColor;

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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
