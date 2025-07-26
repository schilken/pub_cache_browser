// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/components.dart';
import '../models/detail_record.dart';
import '../providers/package_content_notifier.dart';
import 'detail_page.dart';
import 'package_info_page.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
//  Detail? _selectedDetail;

  void _showEbook(DetailRecord selectedDetail, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<DetailPage>(
        builder: (_) {
          return DetailPage(selectedDetail: selectedDetail);
        },
      ),
    );
  }

  void _onAction(String action, String filePath, BuildContext context) {
    debugPrint('_onAction: $action $filePath');
    ref.read(packageContentNotifier.notifier).parse(filePath);
    Navigator.of(context).push(
      MaterialPageRoute<PackageInfoPage>(
        builder: (_) {
          debugPrint('_onAction builder: $action $filePath');
          return PackageInfoPage(
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
