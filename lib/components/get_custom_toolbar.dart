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
    title: const Text('Epub Browser'),
    titleWidth: 250,
    actions: [
      const ToolBarSpacer(spacerUnits: 3),
      // ToolBarPullDownButton(
      //   label: "Actions",
      //   icon: CupertinoIcons.ellipsis_circle,
      //   tooltipMessage: "Perform tasks with the selected items",
      //   items: [
      //     MacosPulldownMenuItem(
      //       title: const Text("Choose Folder to scan"),
      //       onTap: () async {
      //         String? selectedDirectory = await FilePicker.platform
      //             .getDirectoryPath(initialDirectory: '/Volumes');
      //         if (selectedDirectory != null) {
      //           appStateNotifier
      //               .setFolder(folderPath: selectedDirectory);
      //         }
      //       },
      //     ),
      //     const MacosPulldownMenuDivider(),
      //     MacosPulldownMenuItem(
      //       title: const Text("Save last search result"),
      //       onTap: () async {
      //         final selectedFile = await FilePicker.platform.saveFile(
      //             initialDirectory: '/Users/aschilken/flutterdev',
      //             dialogTitle: 'Choose file to save search result',
      //             fileName: 'search-result.txt');
      //         if (selectedFile != null) {
      //           searchOptionsNotifier.saveSearchResult(selectedFile);
      //         }
      //       },
      //     ),
      //     MacosPulldownMenuItem(
      //       title: const Text("Combine search results"),
      //       onTap: () async {
      //         final selectedFiles = await FilePicker.platform.pickFiles(
      //           initialDirectory: '/Users/aschilken/flutterdev',
      //           dialogTitle: 'Choose search results to combine',
      //           allowMultiple: true,
      //         );
      //         if (selectedFiles != null) {
      //           searchOptionsNotifier.combineSearchResults(
      //               filePaths: selectedFiles.paths);
      //         }
      //       },
      //     ),
      //   ],
      // ),
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
      // const ToolBarDivider(),
      // ToolBarIconButton(
      //   label: "Share",
      //   icon: const MacosIcon(
      //     CupertinoIcons.share,
      //   ),
      //   onPressed: () => debugPrint("pressed"),
      //   showLabel: false,
      // ),
    ],
  );
}
