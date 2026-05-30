import 'package:address_research_mobile/main.dart';
import 'package:address_research_mobile/shell/web_app_shell.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('uses legacy Flutter app when web app URL is not configured',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(buildRootApp(webAppUrl: ''));
    await tester.pump();

    expect(find.text('폴더'), findsOneWidget);
  });

  test('selects web app shell for a configured https URL', () {
    final root = buildRootApp(webAppUrl: 'https://place-note.vercel.app');

    expect(root, isA<WebAppShell>());
  });
}
