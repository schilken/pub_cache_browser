import 'dart:ui';

import 'package:pub_cache_browser/providers/file_system_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/get_custom_toolbar.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;

class FileContentPage extends ConsumerStatefulWidget {
  const FileContentPage({super.key, required this.filePath});

  final String filePath;

  @override
  _FileContentPageState createState() => _FileContentPageState();
}

class _FileContentPageState extends ConsumerState<FileContentPage> {
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
//    log.i('MediaQuery.height $windowHeight');
    return MacosScaffold(
      toolBar: getCustomToolBar(context, ref),
      children: [
        ContentArea(
          minWidth: 500,
          builder: (context, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.blueGrey[100],
                  padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SelectableText(
                        'Content of: ${widget.filePath}',
                      ),
                      MacosIconButton(
                        icon: const MacosIcon(CupertinoIcons.refresh),
                        onPressed: _refresh,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                  child: SizedBox(
                    height: windowHeight - 165,
                    child: LayoutBuilder(builder: (context, constraints) {
//                      log.i('LayoutBuilder ${constraints.maxHeight}');
                      return SingleChildScrollView(
                        controller: ScrollController(),
                        child: FutureBuilder<String>(
                            future: ref
                                .read(fileSystemRepositoryProvider)
                                .readFile(widget.filePath),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(snapshot.data!,
                                    style: const TextStyle(fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ]));
                              }
                              return const CircularProgressIndicator();
                            }),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
