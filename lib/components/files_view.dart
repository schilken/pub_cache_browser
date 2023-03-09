// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as p;

import '../components/components.dart';
import '../models/detail_record.dart';
import '../providers/providers.dart';
import '../utils/typedefs.dart';

typedef DetailCallback = void Function(DetailRecord);

class FilesView extends ConsumerWidget {
  const FilesView({
    super.key,
    required this.onSelect,
    this.onAction,
  });

  final DetailCallback onSelect;
  final TwoStringsCallback? onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailListAsyncValue = ref.watch(detailsNotifier);
    return Column(
      children: [
        Container(
          color: Colors.blueGrey[100],
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
          child: Row(
            children: [
              SelectableText(
                ref.watch(defaultFolderNotifier),
              ),
              const Spacer(),
              MacosIconButton(
                backgroundColor: Colors.transparent,
                icon: const MacosIcon(
//                        size: 32,
                  CupertinoIcons.refresh,
                ),
                shape: BoxShape.circle,
                onPressed: () =>
                    ref.read(detailsNotifier.notifier).refreshFileList(),
              ),
              AsyncValueWidget<List<DetailRecord>?>(
                value: detailListAsyncValue,
                data: (records) {
                  if (records == null) {
                    return const Center(child: Text('-'));
                  }
                  return Text('${records.length} Packages');
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: AsyncValueWidget<List<DetailRecord>?>(
              value: detailListAsyncValue,
              data: (records) {
                if (records == null) {
                  return const Center(child: Text('Not yet scanned'));
                }
                if (records.isEmpty) {
                  return const Center(child: Text('No paackages found'));
                }
              return RecordsView(
                records,
                ref,
                onAction: onAction,
              );
            },
          ),
        ),
      ],
    );
  }
}

class RecordsView extends StatelessWidget {
  const RecordsView(
    this.records,
    this.ref, {
    this.onAction,  
    super.key,
  });
  final List<DetailRecord> records;
  final TwoStringsCallback? onAction;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (_, index) {
        final record = records[index];
        return MacosListTile(
          leading: ListTilePullDownMenu(
            record: record,
            onAction: onAction,
          ),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${record.packageName} - ${record.versionCount}',
            ),
          ),
          subtitle: Text('Versions: ${record.versions.join(", ")}'),
        );
      },
    );
  }
}

class ListTilePullDownMenu extends ConsumerWidget {
  const ListTilePullDownMenu({
    super.key,
    required this.record,
    this.onAction,
  });

  final DetailRecord record;
  final TwoStringsCallback? onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filePath = p.join(
      record.directoryPath,
      record.packageName,
    );
    return MacosPulldownButton(
      icon: CupertinoIcons.ellipsis_circle,
      items: [
        MacosPulldownMenuItem(
          title: const Text('Show File in Finder'),
          onTap: () => ref.read(appCommandsProvider).showInFinder(filePath),
        ),
        MacosPulldownMenuItem(
          title: const Text('Open Terminal in Folder'),
          onTap: () => ref.read(appCommandsProvider).showInTerminal(filePath),
        ),
        MacosPulldownMenuItem(
          title: const Text('Copy File Path to Clipboard'),
          onTap: () => ref.read(appCommandsProvider).copyToClipboard(filePath),
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text('Open Package in VSCode'),
          onTap: () {
            // ref
            //     .read(settingsNotifier.notifier)
            //     .addExcludedProject(record.packageName);
            // BotToast.showText(
            //   text: 'Project is now on List of excluded Projects.',
            //   duration: const Duration(seconds: 3),
            //   align: const Alignment(0, 0.3),
            // );
          },
        ),
        MacosPulldownMenuItem(
          title: const Text('Copy Package and Open it in VSCode'),
          onTap: () {
            // ref
            //     .read(settingsNotifier.notifier)
            //     .addExcludedProject(record.packageName);
            // BotToast.showText(
            //   text: 'Project is now on List of excluded Projects.',
            //   duration: const Duration(seconds: 3),
            //   align: const Alignment(0, 0.3),
            // );
          },
        ),
        MacosPulldownMenuItem(
          title: const Text('Package Info'),
          onTap: () => Future.delayed(
            Duration(milliseconds: 10),
            () => onAction?.call(
              'packageInfo',
              filePath,
            ),
          ),
        ),
      ],
    );
  }
}
