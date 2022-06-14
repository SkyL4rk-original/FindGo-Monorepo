import 'package:findgo/core/constants.dart';
import 'package:flutter/material.dart';

class OfflineWidget extends StatelessWidget {
  const OfflineWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 60.0,
      child: Container(
        height: 40.0,
        width: 110.0,
        color: kColorError,
        child: const Center(child: Text("Offline")),
      ),
    );
  }
}

class DescriptionWidget extends StatefulWidget {
  final String text;
  const DescriptionWidget({Key? key, required this.text}) : super(key: key);

  @override
  _DescriptionWidgetState createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  bool _hasTextOverflow({
    required String text,
    required TextStyle style,
    double minWidth = 0,
    double maxWidth = double.infinity,
    int maxLines = 2,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  late bool _isTextOverflow;

  @override
  void initState() {
    _isTextOverflow = _hasTextOverflow(
      text: widget.text,
      style: const TextStyle(fontSize: 12.0),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.text,
            maxLines: 3,
            style: const TextStyle(fontSize: 12.0),
          ),
          if (_isTextOverflow)
            const Text(
              "...",
              style: TextStyle(fontSize: 12.0),
            ),
          if (_isTextOverflow) const SizedBox(height: 12.0),
          if (_isTextOverflow)
            const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Show More",
                style: TextStyle(color: kColorAccent, fontSize: 12.0),
              ),
            )
        ],
      ),
    );
  }
}

