import 'package:flutter/material.dart';

import 'app.dart';
import 'shell/web_app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(buildRootApp());
}

const configuredWebAppUrl = String.fromEnvironment('PLACE_NOTE_WEB_APP_URL');

Widget buildRootApp({String webAppUrl = configuredWebAppUrl}) {
  final uri = Uri.tryParse(webAppUrl);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    return const AddressResearchApp();
  }

  return WebAppShell(webAppUri: uri);
}
