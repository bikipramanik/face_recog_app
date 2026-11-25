import 'package:flutter_test/flutter_test.dart';
import 'package:face_recog_app/main.dart';

void main() {
  testWidgets('App renders Home Screen with Register and Verify', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Face Recognition App'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
  });
}
