// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:epub_view/epub_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as p;

import '../components/components.dart';
import '../models/detail.dart';

class EbookPage extends ConsumerWidget {
  const EbookPage({super.key, required this.selectedDetail});
  final Detail selectedDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: Text(selectedDetail.fileName),
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
          builder: (context, scrollController) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView(
                      controller: scrollController,
//                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                      const SizedBox(height: 16),
                      Padding(
                          padding: const EdgeInsets.all(8),
                        child: EpubViewer(
                            filePath: p.join(
                              selectedDetail.directoryPath,
                              selectedDetail.fileName,
                            ),
                          height: 550, //constraints.maxHeight,
                        ),
                      ),
                    ],
                  );
                  },
                ),
              ),
            );
          },
        ),
        ResizablePane(
          // minWidth: 300,
          // startWidth: 450,
          minSize: 300,
          startSize: 450,
          windowBreakpoint: 700,
          resizableSide: ResizableSide.left,
          builder: (_, __) {
            return Material(
              child: Consumer(
                builder: (context, ref, child) {
                  return AsyncValueWidget<EpubController>(
                    value: ref.watch(epubControllerProvider),
                    data: (controller) => TableOfContentsView(
                      controller: controller,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
