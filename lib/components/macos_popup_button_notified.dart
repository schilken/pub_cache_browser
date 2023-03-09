import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../utils/utils.dart';

class MacosPopupButtonNotified extends ConsumerWidget {
  const MacosPopupButtonNotified(
    this._values,
    this._notifier, {
    required this.onChanged,
    super.key,
  });

  final List<String> _values;
  final NotifierProvider<Notifier<String>, String> _notifier;
  final OptionalStringCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSortOrder = ref.watch(_notifier);
    return MacosPopupButton<String>(
      value: currentSortOrder,
      onChanged: onChanged,
      items: _values.map<MacosPopupMenuItem<String>>((String value) {
        return MacosPopupMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
