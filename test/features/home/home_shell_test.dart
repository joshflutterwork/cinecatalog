import 'package:cinecatalog/core/theme/app_theme.dart';
import 'package:cinecatalog/features/home/presentation/pages/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/stub_repositories.dart';

double _opacityOf(WidgetTester tester, String label) => tester
    .widget<Opacity>(
      find.ancestor(of: find.text(label), matching: find.byType(Opacity)).first,
    )
    .opacity;

void main() {
  testWidgets('opening the FAB plays the spin-in on each pill', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: stubRepositories(),
        retry: (_, _) => null,
        child: MaterialApp(theme: AppTheme.light, home: const HomeShell()),
      ),
    );
    // Let the stubs answer; the feed has looping animations.
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.bySemanticsLabel('Open menu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Mid-animation: the pill is on its way in, not already fully shown.
    final mid = _opacityOf(tester, 'Popular People');
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1));

    await tester.pump(const Duration(milliseconds: 600));
    expect(_opacityOf(tester, 'Popular People'), 1);

    // Unmount and let pending timers run out.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
