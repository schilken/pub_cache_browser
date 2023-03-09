// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../components/components.dart';
import '../models/detail.dart';
import '../providers/epub_content_notifier.dart';
import 'ebook_page.dart';
import 'epub_info_page.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
//  Detail? _selectedDetail;

  void _showEbook(Detail selectedDetail, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<EbookPage>(
        builder: (_) {
          return EbookPage(selectedDetail: selectedDetail);
        },
      ),
    );
  }

  void _onAction(String action, String filePath, BuildContext context) {
    debugPrint('_onAction: $action $filePath');
    ref.read(epubContentNotifier.notifier).parse(filePath);
    Navigator.of(context).push(
      MaterialPageRoute<EpubInfoPage>(
        builder: (_) {
          debugPrint('_onAction builder: $action $filePath');
          return EpubInfoPage(
            filePath: filePath,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
        toolBar: getCustomToolBar(context, ref),
        children: [
          ContentArea(
            minWidth: 200,
            builder: (context, scrollController) {
              return Padding(
              padding: const EdgeInsets.all(24),
                child: FilesView(
                  onSelect: (detail) => _showEbook(detail, context),
                onAction: (action, filePath) =>
                    _onAction(action, filePath, context),
                ),
              );
            },
          ),
//          getDetailsPane(selectedDetail),
        ],
    );
  }

}
