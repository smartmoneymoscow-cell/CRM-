import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/main.dart';

void main() {
  testWidgets('App запускается без крашей', (WidgetTester tester) async {
    await tester.pumpWidget(const CrazyTroutAdminApp());
    expect(find.text('Чек'), findsOneWidget);
  });
}
