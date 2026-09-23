import 'package:cinecatalog/core/theme/app_theme.dart';
import 'package:cinecatalog/features/home/presentation/widgets/stacked_deck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  Future<void> pumpDeck(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: StackedDeck(
              items: [for (var i = 0; i < 5; i++) movieFixture(i)],
              onTap: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  String frontLabel(WidgetTester tester) =>
      tester.getSemantics(find.byType(StackedDeck)).label;

  testWidgets('swiping right shows the previous title', (tester) async {
    await pumpDeck(tester);
    expect(frontLabel(tester), startsWith('Movie 0.'));

    await tester.drag(find.byType(StackedDeck), const Offset(200, 0));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(frontLabel(tester), startsWith('Movie 4.'));
  });

  testWidgets('swiping left shows the next title', (tester) async {
    await pumpDeck(tester);

    await tester.drag(find.byType(StackedDeck), const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(frontLabel(tester), startsWith('Movie 1.'));
  });
}
