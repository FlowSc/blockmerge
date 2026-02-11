import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:izak_app/app.dart';

void main() {
  testWidgets('App renders game screen with title and board',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: IzakApp(),
      ),
    );

    expect(find.text('IZAK'), findsOneWidget);
    expect(find.text('Game Board'), findsOneWidget);
    expect(find.text('Score: 0'), findsOneWidget);
  });
}
