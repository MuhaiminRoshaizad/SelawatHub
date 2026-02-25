import 'package:flutter_test/flutter_test.dart';
import 'package:selawathub/app/app.dart';

void main() {
  testWidgets('App shell renders bottom tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const SelawatHubApp());
    await tester.pumpAndSettle();

    expect(find.text('Counter'), findsOneWidget);
    expect(find.text('Group'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
