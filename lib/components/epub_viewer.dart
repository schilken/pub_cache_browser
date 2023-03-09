import 'dart:io';
import 'dart:typed_data';

import 'package:epub_view/epub_view.dart' hide Image;
import 'package:epub_view/src/data/models/paragraph.dart' as epub;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;

import '../utils/app_sizes.dart';
import 'text_selection_controls.dart';

final epubControllerProvider =
    StateProvider<AsyncValue<EpubController>>((_) => const AsyncLoading());

class EpubViewer extends StatefulWidget {
  const EpubViewer({
    super.key,
    required this.filePath,
    required this.height,
  });

  final String filePath;
  final double height;

  @override
  State<EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends State<EpubViewer> {
  late EpubController _epubReaderController;

  @override
  void initState() {
    debugPrint('EpubViewer.initState');
    final epubFile = File(widget.filePath);
    _epubReaderController = EpubController(
      document: EpubDocument.openFile(epubFile),
    );
    super.initState();
  }

  @override
  void didUpdateWidget(EpubViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('EpubViewer.didUpdateWidget');
    if (oldWidget.filePath != widget.filePath) {
      _reload();
    }
  }

  void _reload() {
    final epubFile = File(widget.filePath);
    final epubDocument = EpubDocument.openFile(epubFile);
    _epubReaderController.loadDocument(epubDocument);
    return;
  }

  @override
  void dispose() {
    _epubReaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('EpubViewer.build ${widget.height}');
    return Column(
      children: [
        EpubViewActualChapter(
          controller: _epubReaderController,
          builder: (chapterValue) => Text(
            chapterValue?.chapter?.title?.replaceAll('\n', '').trim() ?? '',
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: widget.height,
          child: Consumer(
            builder: (context, ref, child) {
              return EpubView(
                builders: EpubViewBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(),
                  chapterDividerBuilder: (_) => const Divider(
                    height: 5,
                    thickness: 2,
                  ),
                  chapterBuilder: _customChapterBuilder,
                ),
                controller: _epubReaderController,
                onDocumentLoaded: (_) =>
                    _onDocumentLoaded(_epubReaderController, ref),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onDocumentLoaded(EpubController controller, WidgetRef ref) {
    log.i('_onDocumentLoaded');
    ref.read(epubControllerProvider.notifier).state =
        AsyncValue.data(controller);
  }

  Widget _customChapterBuilder(
    BuildContext context,
    EpubViewBuilders<DefaultBuilderOptions> builders,
    EpubBook document,
    List<EpubChapter> chapters,
    List<epub.Paragraph> paragraphs,
    int index,
    int chapterIndex,
    int paragraphIndex,
    ExternalLinkPressed onExternalLinkPressed,
  ) {
    if (paragraphs.isEmpty) {
      return Container();
    }
    final defaultBuilder = builders;
    final options = defaultBuilder.options;
    final isNewChapter = chapterIndex >= 0 && paragraphIndex == 0;
    var htmlCode = paragraphs[index].element.outerHtml;
//    print('>>>> chapterIndex $chapterIndex $paragraphIndex $index $htmlCode');
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        if (isNewChapter)
          builders.chapterDividerBuilder(chapters[chapterIndex]),
        if (htmlCode.contains('<img'))
          html.Html(
            data: htmlCode,
            onLinkTap: (href, _, __, ___) => onExternalLinkPressed(href!),
            style: {
              'html': html.Style(
                padding: options.paragraphPadding as EdgeInsets?,
              ).merge(html.Style.fromTextStyle(options.textStyle)),
            },
            customRenders: {
              html.tagMatcher('img'): html.CustomRender.widget(
                widget: (context, buildChildren) {
                  final url = context.tree.element!.attributes['src']!
                      .replaceAll('../', '');
                  if (document.content?.images[url]?.content == null) {
                    debugPrint('>>>>> Image $url not found');
                    return Text('Image $url not found');
                  }
                  return Image(
                    image: MemoryImage(
                      Uint8List.fromList(
                        document.content!.images[url]!.content!,
                      ),
                    ),
                  );
                },
              ),
            },
          )
        else ...[
          html.SelectableHtml(
            data: htmlCode,
            onLinkTap: (href, _, __, ___) => onExternalLinkPressed(href!),
            selectionControls: FlutterSelectionControls(
              toolBarItems: <ToolBarItem>[
                ToolBarItem(
                  item: Text(
                    'Select All',
                    style: theme.textTheme.bodyLarge,
                  ),
                  itemControl: ToolBarItemControl.selectAll,
                ),
                ToolBarItem(
                  item: Text(
                    'Copy',
                    style: theme.textTheme.bodyLarge,
                  ),
                  itemControl: ToolBarItemControl.copy,
                ),
                ToolBarItem(
                  item: Text(
                    'Highlight',
                    style: theme.textTheme.bodyLarge,
                  ),
                  onItemPressed: (highlightedText, startIndex, endIndex) {
                    debugPrint('onItemPressed Highlight $highlightedText');
                  }, // TODO:
                ),
                ToolBarItem(
                  item: Text(
                    'Share',
                    style: theme.textTheme.bodyLarge,
                  ),
                  onItemPressed: (highlightedText, startIndex, endIndex) {
                    debugPrint('onItemPressed share $highlightedText');
                  },
                ),
              ],
            ),
          ),
          gapHeight8,
        ]
      ],
    );
  }
}
