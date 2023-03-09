import 'package:flutter/cupertino.dart' hide OverlayVisibilityMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../providers/providers.dart';

class ListEditor extends ConsumerStatefulWidget {
  const ListEditor({super.key});

  @override
  _ListEditorState createState() => _ListEditorState();
}

class _ListEditorState extends ConsumerState<ListEditor> {
  late TextEditingController _textEditingController;
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
  }

  void addItem(String newItem) {
//    print('Adding $newItem');
    if (newItem.isEmpty) {
      return;
    }
    ref.read(settingsNotifier.notifier).addIgnoredFolder(newItem);
    _textEditingController.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToEnd);
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
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
            child: Text('ListEditor'),
          ),
          Expanded(
            child: Material(
              child: Builder(
                builder: (context) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        ref.watch(settingsNotifier).ignoredFolders.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          ref.watch(settingsNotifier).ignoredFolders[index],
                        ),
                        trailing: MacosIconButton(
                          icon: const MacosIcon(CupertinoIcons.delete),
                          onPressed: () => ref
                              .watch(settingsNotifier.notifier)
                              .removeIgnoredFolder(
                                ref
                                    .watch(settingsNotifier)
                                    .ignoredFolders[index],
                              ),
                        ),
                      );
                    },
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
                  autofocus: true,
                  focusNode: _focusNode,
                  onChanged: (value) {},
                  onSubmitted: addItem,
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
