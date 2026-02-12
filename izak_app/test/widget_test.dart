import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:izak_app/app.dart';
import 'package:izak_app/features/game/widgets/game_board_widget.dart';
import 'package:izak_app/features/game/widgets/score_display.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'tutorial_seen': true});
  });

  testWidgets('Home screen renders title and buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: IzakApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Drop Merge'), findsOneWidget);
    expect(find.text('Block Merge Puzzle'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Tapping start navigates to game with countdown overlay',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: IzakApp(),
      ),
    );
    // Allow async settings load to complete
    await tester.pump();

    await tester.tap(find.text('START'));
    await tester.pumpAndSettle();

    // Game screen is visible behind countdown overlay
    expect(find.byType(GameBoardWidget), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('Countdown on game screen: 3 -> 2 -> 1 -> game starts',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: IzakApp(),
      ),
    );
    // Allow async settings load to complete
    await tester.pump();

    await tester.tap(find.text('START'));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Countdown gone, game board and score display visible
    expect(find.text('3'), findsNothing);
    expect(find.byType(GameBoardWidget), findsOneWidget);
    expect(find.byType(ScoreDisplay), findsOneWidget);
  });
}
