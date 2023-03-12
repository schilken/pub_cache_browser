import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:path/path.dart' as p;

import 'providers.dart';

class AppCommands {

  AppCommands(this.currentFolder);
  final String currentFolder;

  void showInFinder(String path) {
    final folderPath = p.join(currentFolder, path);
    Process.run('open', ['-R', folderPath]);
  }

  void copyToClipboard(String path) {
    final folderPath = p.join(currentFolder, path);
    Clipboard.setData(ClipboardData(text: folderPath));
  }

  void showInTerminal(String path) {
    final folderPath = p.join(currentFolder, path);
    Process.run('open', ['-a', 'iTerm', folderPath]);
  }

  void openEditor(String path) {
    final fullPath = p.join(currentFolder, path);
    Process.run('code', [fullPath]);
  }

}

final appCommandsProvider = Provider<AppCommands>(
  (ref) {
    return AppCommands(
      ref.watch(defaultFolderNotifier),
    );
  },
);
