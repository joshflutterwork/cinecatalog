import 'package:cinecatalog/core/theme/app_theme.dart';
import 'package:cinecatalog/core/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toast text does not fall back to the debug underline', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => showToast(context, 'Hello'),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(GestureDetector));
    await tester.pump(const Duration(milliseconds: 300));

    final text = tester
        .widgetList<RichText>(find.byType(RichText))
        .singleWhere((t) => t.text.toPlainText() == 'Hello');
    expect(text.text.style?.decoration, isNot(TextDecoration.underline));

    // Let the dismiss timer fire.
    await tester.pump(const Duration(seconds: 2));
  });
}
