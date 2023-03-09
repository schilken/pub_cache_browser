import 'package:flutter/cupertino.dart' hide OverlayVisibilityMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../providers/providers.dart';

class SettingsFieldsView extends ConsumerStatefulWidget {
  const SettingsFieldsView({super.key});

  @override
  _SettingsFieldsViewState createState() => _SettingsFieldsViewState();
}

class _SettingsFieldsViewState extends ConsumerState<SettingsFieldsView> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _controller.text = ref.watch(settingsNotifier).committerName;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Committer\'s Name to filter all Commits'),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          width: 300.0,
          child: MacosTextField(
            controller: _controller,
            placeholder: 'Enter name here',
            clearButtonMode: OverlayVisibilityMode.editing,
            maxLines: 1,
            onSubmitted: (value) =>
                ref.read(settingsNotifier.notifier).setCommitterName(value),
          ),
        ),
      ],
    );
  }
}
