import 'dart:io';
import 'dart:ui';

import 'package:pub_cache_browser/providers/file_system_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/async_value_widget.dart';
import '../components/get_custom_toolbar.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;

import '../models/epub_content_record.dart';
import '../providers/epub_content_notifier.dart';
import '../providers/epub_repository.dart';
import '../utils/utils.dart';

class EpubInfoPage extends ConsumerStatefulWidget {
  const EpubInfoPage({super.key, required this.filePath});

  final String filePath;

  @override
  _EpubInfoPageState createState() => _EpubInfoPageState();
}

class _EpubInfoPageState extends ConsumerState<EpubInfoPage> {

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final epubContentAsyncValue = ref.watch(epubContentNotifier);
    double windowHeight = MediaQuery.of(context).size.height;
    log.i('MediaQuery.height $windowHeight');
    return MacosScaffold(
      toolBar: ToolBar(
        title: SelectableText(widget.filePath),
        titleWidth: 700,
        actions: [
          ToolBarPullDownButton(
            label: "Actions",
            icon: CupertinoIcons.ellipsis_circle,
//            tooltipMessage: "Perform tasks with the selected items",
            items: [
              MacosPulldownMenuItem(
                title: const Text("Go to top"),
                onTap: () async {},
              ),
              const MacosPulldownMenuDivider(),
              MacosPulldownMenuItem(
                title: const Text("Copy all selections"),
                onTap: () async {},
              ),
            ],
          ),
          ToolBarIconButton(
            label: 'Toggle Left Sidebar',
            tooltipMessage: 'Toggle Left Sidebar',
            icon: const MacosIcon(
              CupertinoIcons.sidebar_left,
            ),
            onPressed: () => MacosWindowScope.of(context).toggleSidebar(),
            showLabel: false,
          ),
          ToolBarIconButton(
            label: "Share",
            icon: const MacosIcon(
              CupertinoIcons.sidebar_right,
            ),
            onPressed: () => debugPrint("pressed"),
            showLabel: false,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, _) {
            return Column(
              children: [
//                ScanPageHeader(ref: ref),
                Expanded(
                  child: AsyncValueWidget<List<EpubContentRecord>?>(
                      value: epubContentAsyncValue,
                      data: (records) {
                        if (records == null) {
                          return const Center(child: Text('Not yet scanned'));
                        }
                        if (records.isEmpty) {
                          return const Center(
                              child: Text('No directories found'));
                        }
                        return RecordsView(records, ref);
                      }),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class RecordsView extends StatelessWidget {
  const RecordsView(
    this.records,
    this.ref, {
    super.key,
  });
  final List<EpubContentRecord> records;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (_, index) {
        final record = records[index];
        return Material(
          child: ExpansionTile(
            title: Row(
              children: [
                PushButton(
                  buttonSize: ButtonSize.large,
                  isSecondary: true,
                  color: Colors.white,
                  child: const Text('Save'),
                  onPressed: () async {
                    final userHomeDirectory = Platform.environment['HOME'];
                    final filePath = await FilePicker.platform.saveFile(
                      initialDirectory: userHomeDirectory,
                      fileName: record.fileName,
                    );
                    if (filePath != null) {
                      ref.read(fileSystemRepositoryProvider).writeTextFile(
                            filePath,
                            ref
                                .read(epubRepositoryProvider)
                                .getText(record.fileName),
                          );
                    }
                  },
                ),
                gapWidth12,
                Text(
                  record.fileName,
                ),
                Spacer(),
                Text(' ${record.size.toKilobytes} ${record.type}'),
                gapWidth12,
              ],
            ),
            children: [
              if (record.fileName.endsWith('png') ||
                  record.fileName.endsWith('jpg') ||
                  record.fileName.endsWith('gif'))
                Image.memory(
                  ref
                      .read(epubRepositoryProvider)
                      .getImageBytes(record.fileName),
                ),
              if (record.fileName.endsWith('css') ||
                  record.fileName.endsWith('xhtml') ||
                  record.fileName.endsWith('html'))
                SelectableText(
                  ref.read(epubRepositoryProvider).getText(record.fileName),
                ),
            ],
          ),
        );
      },
    );
  }
}
