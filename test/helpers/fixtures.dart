import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';

/// A movie without images, so widget tests never hit the network.
Movie movieFixture(int id, {String? title}) => Movie(
  id: id,
  title: title ?? 'Movie $id',
  overview: 'Overview $id',
  voteAverage: 7.5,
  date: DateTime(2020),
);

PaginatedEntity<Movie> moviePage(
  int page, {
  int perPage = 3,
  int totalPages = 2,
}) => PaginatedEntity(
  items: [
    for (var i = 0; i < perPage; i++) movieFixture((page - 1) * perPage + i),
  ],
  page: page,
  totalPages: totalPages,
  totalResults: perPage * totalPages,
);
