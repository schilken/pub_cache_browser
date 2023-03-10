import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../providers/providers.dart';
import 'toolbar_searchfield.dart';
import 'toolbar_widget_toggle.dart';

ToolBar getCustomToolBar(BuildContext context, WidgetRef ref) {
  final searchOptions = ref.read(searchOptionsNotifier.notifier);
  final searchOptionState = ref.watch(searchOptionsNotifier);
  return ToolBar(
    leading: MacosIconButton(
      icon: const MacosIcon(
        CupertinoIcons.sidebar_left,
        size: 40,
        color: CupertinoColors.black,
      ),
      onPressed: () {
        MacosWindowScope.of(context).toggleSidebar();
      },
    ),
    title: const Text('PubCacheBrowser'),
    titleWidth: 250,
    actions: [
      const ToolBarSpacer(spacerUnits: 3),
      _createToolBarPullDownButton(ref),
//          const MacosPulldownMenuDivider(),
      const ToolBarSpacer(),
      const ToolBarDivider(),
      const ToolBarSpacer(),
      ToolbarSearchfield(
        placeholder: 'Search word',
        onChanged: searchOptions.setSearchWord,
        onSubmitted: searchOptions.setSearchWord,
      ),
      ToolbarWidgetToggle(
        value: searchOptionState.caseSensitive,
          onChanged: searchOptions.setCaseSensitiv,
          child: const Text('Aa'),
        tooltipMessage: 'Search case sentitiv',
      ),
      ToolbarWidgetToggle(
          child: const MacosIcon(
            MdiIcons.filterOutline,
          ),
        value: searchOptionState.filterEnabled,
          onChanged: searchOptions.setFilterEnabled,
        tooltipMessage: 'Filter Projects',
      ),
    ],
  );
}

ToolBarPullDownButton _createToolBarPullDownButton(
  WidgetRef ref,
) {
  return ToolBarPullDownButton(
    label: 'Actions',
    icon: CupertinoIcons.ellipsis_circle,
//        tooltipMessage: "Perform tasks with the selected items",
    items: [
      MacosPulldownMenuItem(
        title: const Text('Delete old Packages'),
        onTap: () async {},
      ),
      MacosPulldownMenuItem(
        title: const Text('Delete .pub_cache Completely'),
        onTap: () async {},
      ),
      const MacosPulldownMenuDivider(),
    ],
  );
}
