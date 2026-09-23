/// A named route: [name] identifies it, [path] is its URL pattern.
///
/// Parameterized paths use `:param` segments (e.g. `/movie/:id`); [build]
/// fills them in order to produce a concrete URL.
class PathRoute {
  const PathRoute({required this.name, required this.path});

  /// Identifier for named navigation (`context.pushNamed`, `goNamed`).
  final String name;

  /// URL pattern; its `:param` segments are filled by [build].
  final String path;

  static final RegExp _param = RegExp(r':\w+');

  /// Fills this route's `:param` segments with [values], in order:
  /// `Routes.movie.build([42]) == '/movie/42'`.
  String build([List<Object> values = const []]) {
    var url = path;
    for (final value in values) {
      url = url.replaceFirst(_param, '$value');
    }
    assert(
      !_param.hasMatch(url),
      'PathRoute.build: $values left params unfilled in $this',
    );
    return url;
  }

  @override
  String toString() => 'PathRoute($name, $path)';
}
