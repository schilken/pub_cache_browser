import 'package:flutter/src/widgets/framework.dart';
import 'package:macos_ui/macos_ui.dart';

class SidebarSwitch extends SidebarItem {
  const SidebarSwitch(
      {required super.label,
      required bool value,
      required Null Function(dynamic value) onChanged});

  @override
  Widget build(BuildContext context) {
    return MacosSwitch(
      value: false,
      onChanged: (value) {
        print('onChanged: $value');
      },
    );
  }
}
