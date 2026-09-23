import 'package:cinecatalog/core/theme/app_theme.dart';
import 'package:cinecatalog/core/widgets/detail_layout.dart';
import 'package:cinecatalog/core/widgets/poster_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _long =
    'Ewan Gordon McGregor (born March 31, 1971) is a Scottish actor. His '
    'accolades include a Golden Globe Award and a Primetime Emmy Award. In '
    '2013, he was appointed an Officer of the Order of the British Empire '
    'for services to drama and charity. He rose to fame in the 1990s and '
    'went on to lead a long list of films and series.';

void main() {
  Future<void> pump(WidgetTester tester, String overview) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: DetailLayout(
          imagePath: null,
          seed: 1,
          tags: const ['Acting'],
          title: 'Ewan McGregor',
          overview: overview,
          onBack: () {},
          extras: const [SizedBox(height: 300)],
        ),
      ),
    );
    await tester.pump();
  }

  Text overviewText(WidgetTester tester, String overview) =>
      tester.widget<Text>(find.text(overview));

  testWidgets('long overview: Show more expands, Show less collapses', (
    tester,
  ) async {
    await pump(tester, _long);
    expect(overviewText(tester, _long).maxLines, 3);
    final posterHeight = tester.getSize(find.byType(PosterImage)).height;

    await tester.tap(find.text('Show more'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(overviewText(tester, _long).maxLines, isNull);
    expect(find.text('Show less'), findsOneWidget);
    expect(
      tester.getSize(find.byType(PosterImage)).height,
      posterHeight,
      reason: 'the poster keeps its height; the text grows below it',
    );

    // The longer text pushed the link down; scroll to it, as a user would.
    await tester.ensureVisible(find.text('Show less'));
    await tester.pump();
    await tester.tap(find.text('Show less'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(overviewText(tester, _long).maxLines, 3);
    expect(find.text('Show more'), findsOneWidget);
  });

  testWidgets('short overview: no Show more', (tester) async {
    await pump(tester, 'A short biography.');
    expect(find.text('Show more'), findsNothing);
  });
}
