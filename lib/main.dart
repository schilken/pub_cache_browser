import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'pages/about_window.dart';
import 'providers/providers.dart';

const loggerFolder = '/tmp/pub_cache_browser_log';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('main: $args');
  log.initLogger(loggerFolder);
  log.i('after initLogger');
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final arguments = args[2].isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(args[2]) as Map<String, dynamic>;
    if (arguments['args1'] == 'About') {
      runApp(
        AboutWindow(
          windowController: WindowController.fromWindowId(windowId),
          args: arguments,
        ),
      );
    }
  } else {
    final sharedPreferences = await SharedPreferences.getInstance();
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const App(),
      ),
    );
  }
}
