/// 8.4567 → "8.5". TMDB uses 0 for "no votes yet".
String formatRating(double vote) => vote <= 0 ? '–' : vote.toStringAsFixed(1);

/// Year, or "TBA" when TMDB has no date.
String formatYear(int? year) => year?.toString() ?? 'TBA';

/// 148 → "2h 28m".
String formatRuntime(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

/// "★ 8.4 · 2010".
String ratingAndYear(double vote, int? year) =>
    '★ ${formatRating(vote)} · ${formatYear(year)}';
