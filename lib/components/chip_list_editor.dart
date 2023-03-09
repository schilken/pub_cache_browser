import 'package:flutter/cupertino.dart' hide OverlayVisibilityMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../providers/providers.dart';

class ChipListEditor extends ConsumerStatefulWidget {
  const ChipListEditor({super.key});

  @override
  _ListEditorState createState() => _ListEditorState();
}

class _ListEditorState extends ConsumerState<ChipListEditor> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
  }

  void addItem(BuildContext context, String newItem) {
//    print('Adding $newItem');
    if (newItem.isEmpty) {
      return;
    }
    ref.read(settingsNotifier.notifier).addExcludedProject(newItem);
    _textEditingController.clear();
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
//    FocusScope.of(context).requestFocus(_focusNode);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('ChipListEditor'),
          ),
          Expanded(
            child: Material(
              color: Colors.white,
              child: Builder(
                builder: (context) {
                  final chips = ref
                      .watch(settingsNotifier)
                      .excludedProjects
                      .map(
                        (item) => Chip(
                          label: Text(item),
                          deleteIcon:
                              const MacosIcon(CupertinoIcons.clear_circled),
                          onDeleted: () {
                            ref
                                .read(settingsNotifier.notifier)
                                .removeExcludedProject(item);
                          },
                        ),
                      )
                      .toList();
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: chips,
                  );
                },
              ),
            ),
          ),
          Row(
            children: [
              const Text('Add String to the List:'),
              const SizedBox(width: 20),
              Expanded(
                child: MacosTextField(
                  controller: _textEditingController,
                  focusNode: _focusNode,
                  onChanged: (value) {},
                  onSubmitted: (item) => addItem(context, item),
                  clearButtonMode: OverlayVisibilityMode.editing,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
