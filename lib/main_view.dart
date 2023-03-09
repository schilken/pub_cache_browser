import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'components/options_sidebar.dart';
import 'main.dart';
import 'pages/file_content_page.dart';
import 'pages/pages.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {

  int sidebarPageIndex = 0;

  void _changeSidebarIndex(int newIndex) {
    setState(() {
      sidebarPageIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'PubCacheBrowser',
          menus: [
            PlatformMenuItem(
              label: 'About',
              onSelected: () async {
                final window = await DesktopMultiWindow.createWindow(jsonEncode(
                  {
                    'args1': 'About',
                    'args2': 500,
                    'args3': true,
                  },
                  ),
                );
                debugPrint('$window');
                window
                  ..setFrame(const Offset(0, 0) & const Size(350, 350))
                  ..center()
                  ..setTitle('About pub_cache_browser')
                  ..show();
              },
            ),
            const PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.quit,
            ),
          ],
        ),
      ],
      child: MacosWindow(
        sidebar: Sidebar(
          shownByDefault: false,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
          ),
          minWidth: 200,
          maxWidth: 200,
          top: const OptionsSidebar(),
          builder: (context, scrollController) => SidebarItems(
            currentIndex: sidebarPageIndex,
            scrollController: scrollController,
            onChanged: _changeSidebarIndex,
            items: const [
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.search),
                label: Text('Packages'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.gear),
                label: Text('Preferences'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.archivebox),
                label: Text('Show Log file'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.info_circle),
                label: Text('Help'),
              ),
            ],
          ),
          bottom: const MacosListTile(
            leading: MacosIcon(CupertinoIcons.profile_circled),
            title: Text('PubCacheBrowser'),
            subtitle: Text('alfred@schilken.de'),
          ),
        ),
        child: IndexedStack(
          index: sidebarPageIndex,
          children: [
            CupertinoTabView(
              builder: (_) => const MainPage(),
            ),
            const SettingsPage(),
            const FileContentPage(filePath: '$loggerFolder/log_0.log'),
            const HelpPage(),
          ],
        ),
      ),
    );
  }
}
