import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';

class TableOfContentsView extends StatelessWidget {
  const TableOfContentsView({
    required this.controller,
    this.padding,
    this.itemBuilder,
    this.loader,
    super.key,
  });

  final EdgeInsetsGeometry? padding;
  final EpubController controller;

  final Widget Function(
    BuildContext context,
    int index,
    EpubViewChapter chapter,
    int itemCount,
  )? itemBuilder;
  final Widget? loader;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<EpubViewChapter>>(
        valueListenable: controller.tableOfContentsListenable,
        builder: (_, data, child) {
          Widget content;

          if (data.isNotEmpty) {
            content = ListView.builder(
              padding: padding,
              controller: ScrollController(),
              key: Key('$runtimeType.content'),
              itemBuilder: (context, index) =>
                  itemBuilder?.call(context, index, data[index], data.length) ??
                  ListTile(
                    title: Text(
                      data[index].title!.trim(),
                      style: TextStyle(
                        fontSize: data[index].type == 'chapter' ? 20 : 14,
                      ),
                    ),
                    onTap: () {
                      debugPrint(
                        'onTap index: $index ${data[index].startIndex}',
                      );
                      controller.scrollTo(index: data[index].startIndex);
                    },
                  ),
              itemCount: data.length,
            );
          } else {
            content = KeyedSubtree(
              key: Key('$runtimeType.loader'),
              child: loader ?? const Center(child: CircularProgressIndicator()),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: content,
          );
        },
      );
}
