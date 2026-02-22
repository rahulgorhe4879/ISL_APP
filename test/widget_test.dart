import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:islapp/data.dart';
import 'package:islapp/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const ISLApp(),
      ),
    );

    expect(find.text('Unit 1'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
  });
}
