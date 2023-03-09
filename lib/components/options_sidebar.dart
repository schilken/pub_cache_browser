import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'macos_popup_button_notified.dart';

class OptionsSidebar extends ConsumerWidget {
  const OptionsSidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Sort files by:'),
          const SizedBox(
            height: 8,
          ),
          MacosPopupButtonNotified(
            SortOrderNotifier.sortOrders,
            sortOrderNotifier,
            onChanged: (newValue) =>
                ref.read(sortOrderNotifier.notifier).setValue(newValue!),
          ),
          const SizedBox(height: 16),
          // const Text('Time Range:'),
          // const SizedBox(
          //   height: 8,
          // ),
          // MacosPopupButtonNotified(
          //   TimeRangeNotifier.timeRanges,
          //   timeRangeNotifier,
          //   onChanged: (newValue) =>
          //       ref.read(timeRangeNotifier.notifier).setTimeRange(newValue!),
          // ),
          // const SizedBox(height: 16),
          // const Text('Show'),
          // const SizedBox(
          //   height: 8,
          // ),
          // MacosPopupButtonNotified(
          //   DisplayModeNotifier.displayModes,
          //   displayModeNotifier,
          //   onChanged: (newValue) =>
          //       ref.read(displayModeNotifier.notifier).setValue(newValue!),
          // ),
//          const SizedBox(height: 16),
          // MacosCheckBoxListTile(
          //   title: const Text('Heatmap over all projects'),
          //   leadingWhitespace: 0,
          //   onChanged: (value) => ref
          //       .read(filterStateProvider.notifier)
          //       .toggleSearchOption('combineIntersection', value ?? false),
          //   value: ref.watch(filterStateProvider).combineIntersection,
          // ),
          // const SizedBox(height: 8),
          // MacosCheckBoxListTile(
          //   title: const Text('With 4 context lines'),
          //   leadingWhitespace: 0,
          //   onChanged: (value) => ref
          //       .read(filterStateProvider.notifier)
          //       .toggleSearchOption('showWithContext', value ?? false),
          //   value: ref.watch(filterStateProvider).showWithContext,
          // ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
