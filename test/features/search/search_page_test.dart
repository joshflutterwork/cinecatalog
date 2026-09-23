import 'package:cinecatalog/core/theme/app_theme.dart';
import 'package:cinecatalog/features/search/presentation/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/stub_repositories.dart';

void main() {
  testWidgets('shows trending titles from the API as suggestions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: stubRepositories(),
        child: MaterialApp(theme: AppTheme.light, home: const SearchPage()),
      ),
    );
    await tester.pump();
    expect(find.text('Inception'), findsOneWidget);
  });

  testWidgets('typing shows the skeleton, then the results', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: stubRepositories(),
        child: MaterialApp(theme: AppTheme.light, home: const SearchPage()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'dark');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('RESULT'), findsNothing);

    // Past the 400 ms debounce, then let the stub answer.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump();
    expect(find.text('2 RESULTS'), findsOneWidget);
    expect(find.text('The Dark Knight'), findsOneWidget);
  });
}
