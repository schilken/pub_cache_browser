// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

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
                  return Text(records.length.toString());
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
                return RecordsView(records, ref);
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
    super.key,
  });
  final List<DetailRecord> records;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (_, index) {
        final record = records[index];
        return Material(
          child: ListTile(
            title: Text(
              '${record.packageName} - ${record.versionCount}',
            ),
            subtitle: Text('Versions: ${record.versions.join(", ")}'),
          ),
        );
      },
    );
  }
}
