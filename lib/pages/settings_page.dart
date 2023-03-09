import 'package:flutter/cupertino.dart' hide OverlayVisibilityMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/components.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _controller = MacosTabController(
    initialIndex: 0,
    length: 3,
  );

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: const ToolBar(
        title: Text('Preferences'),
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: MacosTabView(
                controller: _controller,
                tabs: [
                  MacosTab(
                    label: 'General',
                    active: _controller.index == 0,
                  ),
                  MacosTab(
                    label: 'Ignore Folders for Scan',
                    active: _controller.index == 1,
                  ),
                  MacosTab(
                    label: 'Exclude Projects from Search',
                    active: _controller.index == 2,
                  ),
                ],
                children: const [
                  Center(
                    child: SettingsFieldsView(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: ListEditor(),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: ChipListEditor(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
