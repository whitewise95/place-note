import 'package:address_research_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows home screen CTA', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AddressResearchApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Place Note'), findsOneWidget);
    expect(find.text('캡쳐 텍스트 저장'), findsOneWidget);
  });

  testWidgets('canceling folder creation closes dialog without errors',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AddressResearchApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();
    expect(find.text('새 폴더'), findsOneWidget);

    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(find.text('새 폴더'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
