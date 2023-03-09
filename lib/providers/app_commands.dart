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
    Process.run('open', ['-R', path]);
  }

  void copyToClipboard(String path) {
    Clipboard.setData(ClipboardData(text: path));
  }

  void showInTerminal(String path) {
    final folderPath = _projectFolderPath(path);
    Process.run('open', ['-a', 'iTerm', folderPath]);
  }

  void openEditor(String path) {
    Process.run('code', [path]);
  }

  String _projectFolderPath(String pathName) {
    final parts = p.split(pathName);
    final folderPath = parts.sublist(1, parts.length - 1).join('/');
    return '/$folderPath';
  }
}

final appCommandsProvider = Provider<AppCommands>(
  (ref) {
    return AppCommands(
      ref.watch(defaultFolderNotifier),
    );
  },
);
