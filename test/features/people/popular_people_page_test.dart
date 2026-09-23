import 'package:cinecatalog/core/theme/app_theme.dart';
import 'package:cinecatalog/features/people/presentation/pages/popular_people_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/stub_repositories.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: stubRepositories(),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PopularPeoplePage(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('search narrows the grid, cancel brings back popular', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(find.text('Person 0'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.bySemanticsLabel('Search people'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'person 3');
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.text('Person 0'),
      findsNothing,
      reason: 'skeleton while typing',
    );

    // Past the debounce, then let the stub answer.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump();
    expect(find.text('Person 3'), findsOneWidget);
    expect(find.text('Person 0'), findsNothing);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Person 0'), findsOneWidget);
  });

  testWidgets('no match shows the empty state', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.bySemanticsLabel('Search people'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump();
    expect(find.text('Not found'), findsOneWidget);
  });

  testWidgets('the FAB is here too, with Popular People active', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.bySemanticsLabel('Open menu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    for (final item in ['Movies', 'TV Shows', 'Watchlist']) {
      final pill = find.text(item);
      expect(pill, findsOneWidget, reason: item);
      final opacity = tester
          .widget<Opacity>(
            find.ancestor(of: pill, matching: find.byType(Opacity)).first,
          )
          .opacity;
      expect(opacity, 1, reason: '$item is visible');
    }
  });
}
