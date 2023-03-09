library dynamic_text_highlighting;

import 'dart:math';

import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
//  final TextHeightBehavior textHeightBehavior;

  const HighlightedText({
    //DynamicTextHighlighting
    super.key,
    required this.text,
    required this.highlights,
    this.color = Colors.yellow,
    this.style = const TextStyle(
      color: Colors.black,
    ),
    this.caseSensitive = true,

    //RichText
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.maxLines = 50,
//    this.locale = Locale,
//    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
//    this.textHeightBehavior,
  });
  //DynamicTextHighlighting
  final String text;
  final List<String> highlights;
  final Color color;
  final TextStyle style;
  final bool caseSensitive;

  //RichText
  final TextAlign textAlign;
  final TextDirection textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int maxLines;
//  final Locale locale;
//  final StrutStyle strutStyle;
  final TextWidthBasis textWidthBasis;

  @override
  Widget build(BuildContext context) {
    //Controls
    if (text == '') {
      return _richText(_normalSpan(text));
    }
    if (highlights.isEmpty) {
      return _richText(_normalSpan(text));
    }
    for (var i = 0; i < highlights.length; i++) {
      if (highlights[i].isEmpty) {
        assert(highlights[i].isNotEmpty);
        return _richText(_normalSpan(text));
      }
    }

    //Main code
    final _spans = <TextSpan>[];
    var _start = 0;

    //For "No Case Sensitive" option
    final _lowerCaseText = text.toLowerCase();
    final _lowerCaseHighlights = <String>[];

    for (final element in highlights) {
      _lowerCaseHighlights.add(element.toLowerCase());
    }

    while (true) {
      final _highlightsMap = <int, String>{}; //key (index), value (highlight).

      if (caseSensitive) {
        for (var i = 0; i < highlights.length; i++) {
          final _index = text.indexOf(highlights[i], _start);
          if (_index >= 0) {
            _highlightsMap.putIfAbsent(_index, () => highlights[i]);
          }
        }
      } else {
        for (var i = 0; i < highlights.length; i++) {
          var _index = _lowerCaseText.indexOf(_lowerCaseHighlights[i], _start);
          if (_index >= 0) {
            _highlightsMap.putIfAbsent(_index, () => highlights[i]);
          }
        }
      }

      if (_highlightsMap.isNotEmpty) {
        final _indexes = <int>[];
        _highlightsMap.forEach((key, value) => _indexes.add(key));

        final _currentIndex = _indexes.reduce(min);
        final _currentHighlight = text.substring(
          _currentIndex,
          _currentIndex + _highlightsMap[_currentIndex]!.length,
        );

        if (_currentIndex == _start) {
          _spans.add(_highlightSpan(_currentHighlight));
          _start += _currentHighlight.length;
        } else {
          _spans.add(_normalSpan(text.substring(_start, _currentIndex)));
          _spans.add(_highlightSpan(_currentHighlight));
          _start = _currentIndex + _currentHighlight.length;
        }
      } else {
        _spans.add(_normalSpan(text.substring(_start, text.length)));
        break;
      }
    }

    return _richText(TextSpan(children: _spans));
  }

  TextSpan _highlightSpan(String value) {
    if (style.color == null) {
      return TextSpan(
        text: value,
        style: style.copyWith(
          color: Colors.black,
          backgroundColor: color,
        ),
      );
    } else {
      return TextSpan(
        text: value,
        style: style.copyWith(
          backgroundColor: color,
        ),
      );
    }
  }

  TextSpan _normalSpan(String value) {
    if (style.color == null) {
      return TextSpan(
        text: value,
        style: style.copyWith(
          color: Colors.black,
        ),
      );
    } else {
      return TextSpan(
        text: value,
        style: style,
      );
    }
  }

  RichText _richText(TextSpan text) {
    return RichText(
      key: key,
      text: text,
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
//      locale: locale,
//      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
//      textHeightBehavior: textHeightBehavior,
    );
  }
}
