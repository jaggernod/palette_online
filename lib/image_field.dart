import 'package:flutter/material.dart';

typedef OnImport = void Function(String);
typedef OnTextInput = void Function(String);

class ImageField extends StatefulWidget {
  const ImageField({
    Key key,
    @required this.onChanged,
    this.onTextInput,
  })  : assert(onChanged != null),
        super(key: key);

  final OnImport onChanged;
  final OnTextInput onTextInput;

  @override
  _ImageFieldState createState() => _ImageFieldState();
}

class _ImageFieldState extends State<ImageField>
    with SingleTickerProviderStateMixin {
  final TextEditingController textController = TextEditingController();

  AnimationController animationController;

  bool hasText;

  @override
  void initState() {
    super.initState();

    hasText = textController.value.text.isNotEmpty;

    animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() => setState(() {}));

    textController.addListener(() {
      if (hasText != textController.value.text.isNotEmpty) {
        if (textController.value.text.isNotEmpty) {
          animationController.forward();
        } else {
          animationController.reverse();
        }
        hasText = textController.value.text.isNotEmpty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle searchTextStyle = TextStyle(
      fontSize: 17,
    );
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: textController,
              maxLines: 1,
              style: searchTextStyle,
              autofocus: true,
              onChanged: widget.onTextInput,
              onSubmitted: widget.onChanged,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(),
                hintStyle: searchTextStyle,
              ),
            ),
          ),
          // This is just for testing as the Flutter Driver has no option for
          // submitting TextInputAction.done.
          SizedBox(
            width: 1,
            height: 1,
            child: GestureDetector(
              key: Key('test-submit-area'),
              excludeFromSemantics: true,
              onTap: () => widget.onChanged(textController.text),
            ),
          ),
          Offstage(
            offstage: animationController.value == 0,
            child: Opacity(
              opacity: animationController.value,
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                icon: Icon(Icons.clear),
                color: IconTheme.of(context).color,
                onPressed: hasText ? textController.clear : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    animationController.dispose();

    super.dispose();
  }
}
