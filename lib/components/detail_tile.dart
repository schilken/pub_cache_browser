// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as p;

import '../models/detail.dart';
import '../providers/providers.dart';
import '../utils/typedefs.dart';
import 'highlighted_text.dart';

class DetailTile extends StatefulWidget {
  const DetailTile({
    super.key,
    required this.detail,
    required this.highlights,
    required this.onClick,
    this.onAction,
  });
  final Detail detail;
  final List<String> highlights;
  final VoidCallback onClick;
  final TwoStringsCallback? onAction;

  @override
  State<DetailTile> createState() => _DetailTileState();
}

class _DetailTileState extends State<DetailTile> {
  String? infoForSelectedDate;
  @override
  Widget build(BuildContext context) {
    return MacosListTile(
      title: Row(
        children: [
          ListTilePullDownMenu(
            detail: widget.detail,
            onAction: widget.onAction,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: HighlightedText(
              text: widget.detail.fileName,
              style: Theme.of(context).textTheme.titleLarge!,
              highlights: widget.highlights,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HighlightedText(
              text: widget.detail.directoryPath,
              style: Theme.of(context).textTheme.bodyMedium!,
              highlights: widget.highlights,
              caseSensitive: false,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
      onClick: widget.onClick,
    );
  }
}

class ListTilePullDownMenu extends ConsumerWidget {
  const ListTilePullDownMenu({
    super.key,
    required this.detail,
    this.onAction,
  });

  final Detail detail;
  final TwoStringsCallback? onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filePath = p.join(
      detail.directoryPath,
      detail.fileName,
    );
    return MacosPulldownButton(
      icon: CupertinoIcons.ellipsis_circle,
      items: [
        MacosPulldownMenuItem(
          title: const Text('Show File in Finder'),
          onTap: () =>
              ref.read(appCommandsProvider).showInFinder(filePath),
        ),
        MacosPulldownMenuItem(
          title: const Text('Open Terminal in Folder'),
          onTap: () =>
              ref
              .read(appCommandsProvider)
              .showInTerminal(filePath),
        ),
        MacosPulldownMenuItem(
          title: const Text('Copy File Path to Clipboard'),
          onTap: () => ref
              .read(appCommandsProvider)
              .copyToClipboard(filePath),
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text('Put Project on Excluded List in Preferences'),
          onTap: () {
            ref
                .read(settingsNotifier.notifier)
                .addExcludedProject(detail.fileName);
            BotToast.showText(
              text: 'Project is now on List of excluded Projects.',
              duration: const Duration(seconds: 3),
              align: const Alignment(0, 0.3),
            );
          },
        ),
        MacosPulldownMenuItem(
          title: const Text('ePUB Info'),
          onTap: () => Future.delayed(
            Duration(milliseconds: 10),
            () => onAction?.call(
              'epubInfo',
              filePath,
            ),
          ),
        ),
      ],
    );
  }
}
