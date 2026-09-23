import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/detail_layout.dart';
import 'package:cinecatalog/core/widgets/poster_image.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:cinecatalog/features/people/presentation/providers/people_providers.dart';
import 'package:cinecatalog/features/people/presentation/state/person_detail_state.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Not in the design handoff; built from the same detail layout so it feels
/// like the movie and TV pages, without the Play row.
class PersonDetailPage extends ConsumerWidget {
  const PersonDetailPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void back() => context.popOrHome();
    return switch (ref.watch(personDetailProvider(id))) {
      PersonDetailLoading() => DetailSkeleton(onBack: back),
      PersonDetailError(:final failure) => DetailErrorView(
        failure: failure,
        onRetry: () => ref.read(personDetailProvider(id).notifier).retry(),
        onBack: back,
      ),
      PersonDetailLoaded(:final detail) => _PersonDetailView(detail: detail),
    };
  }
}

class _PersonDetailView extends StatelessWidget {
  const _PersonDetailView({required this.detail});

  final PersonDetail detail;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String? get _birthday {
    final d = detail.birthday;
    return d == null ? null : '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final person = detail.person;
    final bio = detail.biography.isEmpty
        ? 'No biography for ${person.name} yet.'
        : detail.biography;
    return DetailLayout(
      imagePath: person.profilePath,
      seed: person.id + 2,
      imageLabel: initialsOf(person.name),
      tags: [
        person.knownForDepartment,
        if (detail.birthday != null) 'Born ${detail.birthday!.year}',
      ],
      title: person.name,
      overview: bio,
      onBack: () => context.popOrHome(),
      extras: [
        InfoTiles(
          items: [
            ('Known for', person.knownForDepartment),
            ('Born', _birthday ?? '–'),
          ],
        ),
        if (detail.placeOfBirth case final place?)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Text('Place of birth: $place', style: AppText.meta),
          ),
        if (detail.biography.isNotEmpty)
          DetailSection(
            title: 'Biography',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(detail.biography, style: AppText.detailBody),
            ),
          ),
        if (detail.credits.isNotEmpty)
          DetailSection(
            title: 'Known for',
            child: PosterRail(
              items: detail.credits,
              onTap: (m) => context.push(Routes.media(m)),
            ),
          ),
      ],
    );
  }
}
