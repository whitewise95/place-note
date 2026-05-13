import 'package:address_research_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows folder-first home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AddressResearchApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Place Note'), findsOneWidget);
    expect(find.text('폴더'), findsOneWidget);
    expect(find.text('기본 보관함'), findsOneWidget);
    expect(find.text('캡쳐 텍스트 저장'), findsNothing);
    expect(find.text('사진 읽기'), findsNothing);
    expect(find.byTooltip('사진 속 글자 읽기'), findsOneWidget);
  });

  testWidgets('canceling folder creation closes dialog without errors',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AddressResearchApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('추가'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('새 폴더'), findsOneWidget);

    await tester.tap(find.text('취소'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('새 폴더'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
