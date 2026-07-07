import 'package:flutter_test/flutter_test.dart';
import 'package:up_police_hrms/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UPPoliceHrmsApp());
    expect(find.byType(UPPoliceHrmsApp), findsOneWidget);
  });
}
