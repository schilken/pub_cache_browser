// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/components.dart';
import '../models/detail.dart';
import '../providers/providers.dart';
import '../utils/typedefs.dart';

typedef DetailCallback = void Function(Detail);

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
    return Column(
      children: [
        Container(
          color: Colors.blueGrey[100],
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
          child: Row(
            children: [
              PushButton(
                buttonSize: ButtonSize.large,
                isSecondary: true,
                color: Colors.white,
                child: const Text('Choose Folder to scan'),
                onPressed: () async {
                  final userHomeDirectory = Platform.environment['HOME'];
                  String? selectedDirectory = await FilePicker.platform
                      .getDirectoryPath(initialDirectory: userHomeDirectory);
                  if (selectedDirectory != null) {
//                    ref.read(cacheProvider).clear();
                    ref
                        .read(defaultFolderNotifier.notifier)
                        .setFolder(selectedDirectory);
                    ref.read(detailsNotifier.notifier).refreshFileList();
                  }
                },
              ),
              const SizedBox(
                width: 8,
              ),
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
              ref.watch(detailsNotifier).when(
                    inProgress: () => const CupertinoActivityIndicator(),
                    loaded: (a, fileCount, b, c, d) =>
                        Text('$fileCount Projects'),
                  ),
            ],
          ),
        ),
        ref.watch(detailsNotifier).when(
              inProgress: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CupertinoActivityIndicator(),
                ),
              ),
              loaded: (
                details,
                fileCount,
                message,
                commandAsString,
                highlights,
              ) {
                if (message != null) {
                  return MessageBar(
                    message: message,
                    onDismiss: () =>
                        ref.read(detailsNotifier.notifier).removeMessage(),
                  );
                }
                if (details.isEmpty) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Text('No search result.'),
                  ));
                } else {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ListView.separated(
                        controller: ScrollController(),
                        itemCount: details.length,
                        itemBuilder: (context, index) {
                          final detail = details[index];
                          return DetailTile(
                            detail: detail,
                            highlights: highlights ?? [],
                            onClick: () => onSelect(detail),
                            onAction: onAction,
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(
                            thickness: 2,
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
      ],
    );
  }
}
