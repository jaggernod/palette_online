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
      children: <Widget>[
        Image.network(image.toString()),
        _RelatedContent(
          image: image,
          defaultBackground: Colors.green,
        ),
      ],
    );
  }
}

class _RelatedContent extends StatefulWidget {
  const _RelatedContent(
      {Key key, @required this.image, @required this.defaultBackground})
      : assert(image != null),
        assert(defaultBackground != null),
        super(key: key);

  final Uri image;
  final Color defaultBackground;

  @override
  _RelatedContentState createState() => _RelatedContentState();
}

class _RelatedContentState extends State<_RelatedContent>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  PaletteGenerator _paletteGenerator;

  Color background;
  Color titleColor;
  ColorTween _backgroundColorTween;

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

    background = widget.defaultBackground;
    titleColor = Colors.white;

    _backgroundColorTween = ColorTween(
      begin: widget.defaultBackground,
      end: background,
    );
    print("SSSSSSSSSSSSSSSSs ${background}");
    try {
      _updatePaletteGenerator();
    } catch (e, s) {
      print("SSSSSSSSSSSSSs $e $s");
    }
  }

  Future<void> _updatePaletteGenerator() async {
    print("SSSSSSSSSSSSSSSSssadsdasdas ${widget.image.toString()}");
    _paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(
        widget.image.toString(),
      ),
      filters: [_avoidWhiteAndDarkPaletteFilter],
      timeout: Duration(seconds: 1), // Never give up! Never surrender!
    );
    print("SSSSSSSSSSSSSSSSssadas ${background}");
    if (mounted) {
      final palette = _paletteGenerator.darkVibrantColor ??
          _paletteGenerator.darkMutedColor ??
          _paletteGenerator.dominantColor;

      print("SSSSSSSSSSSSSSSSs ${palette?.color}");

      background = palette?.color ?? widget.defaultBackground;

      _backgroundColorTween = ColorTween(
        begin: widget.defaultBackground,
        end: background,
      );

      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_RelatedContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.image != widget.image) {
      _updatePaletteGenerator();
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Test",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            _buildImage(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Material(
      type: MaterialType.card,
      elevation: 2,
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Container(
        width: 96,
        height: 96,
      ),
    );
  }
}

bool _avoidWhiteAndDarkPaletteFilter(HSLColor color) {
  bool _isTooWhite(HSLColor hslColor) {
    const double _whiteMinLightness = 0.45;
    return hslColor.lightness >= _whiteMinLightness;
  }

  bool _isTooBlack(HSLColor hslColor) {
    const double _blackMaxLightness = 0.10;
    return hslColor.lightness <= _blackMaxLightness;
  }

  return !_isTooWhite(color) && !_isTooBlack(color);
}
