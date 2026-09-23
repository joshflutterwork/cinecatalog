// SVG path data is split across adjacent literals; spaces would break it.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icon strokes copied from the design's inline SVGs (24×24 viewBox).
final class AppIconData {
  const AppIconData(this.body, {this.strokeWidth = 1.7, this.filled = false});

  final String body;
  final double strokeWidth;
  final bool filled;

  String get svg => filled
      ? '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
            'fill="#000">$body</svg>'
      : '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
            'fill="none" stroke="#000" stroke-width="$strokeWidth" '
            'stroke-linecap="round" stroke-linejoin="round">$body</svg>';
}

abstract final class AppIcons {
  static const search = AppIconData(
    '<circle cx="11" cy="11" r="7"/><path d="M16.5 16.5 21 21"/>',
  );
  static const searchBold = AppIconData(
    '<circle cx="11" cy="11" r="7"/><path d="M16.5 16.5 21 21"/>',
    strokeWidth: 1.9,
  );
  static const searchEmpty = AppIconData(
    '<circle cx="11" cy="11" r="7"/><path d="M16.5 16.5 21 21"/>'
    '<path d="M8.5 11h5"/>',
    strokeWidth: 1.6,
  );
  static const chevronRight = AppIconData(
    '<path d="m9 5 7 7-7 7"/>',
    strokeWidth: 2.2,
  );
  static const back = AppIconData('<path d="M15 5 8 12l7 7"/>', strokeWidth: 2);
  static const star = AppIconData(
    '<path d="m12 3 2.6 5.6 6.1.8-4.5 4.2 1.2 6L12 16.8 6.6 19.6l1.2-6'
    'L3.3 9.4l6.1-.8z"/>',
    filled: true,
  );
  static const cast = AppIconData(
    '<rect x="2.5" y="4.5" width="19" height="13" rx="3"/><path d="M8 21h8"/>',
  );
  static const share = AppIconData(
    '<path d="M4 12v7a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-7"/>'
    '<path d="M12 15V3"/><path d="m8 7 4-4 4 4"/>',
  );
  static const play = AppIconData('<path d="M8 5v14l11-7z"/>', filled: true);
  static const heart = AppIconData(
    '<path d="M12 20s-7-4.5-7-9.2A4 4 0 0 1 12 8a4 4 0 0 1 7 2.8'
    'C19 15.5 12 20 12 20z"/>',
  );
  static const heartFilled = AppIconData(
    '<path d="M12 20s-7-4.5-7-9.2A4 4 0 0 1 12 8a4 4 0 0 1 7 2.8'
    'C19 15.5 12 20 12 20z"/>',
    filled: true,
  );
  static const plus = AppIconData(
    '<path d="M12 5v14M5 12h14"/>',
    strokeWidth: 1.9,
  );
  static const close = AppIconData(
    '<path d="M6 6l12 12M18 6 6 18"/>',
    strokeWidth: 3,
  );
  static const movies = AppIconData(
    '<path d="M3 6.5A2.5 2.5 0 0 1 5.5 4h13A2.5 2.5 0 0 1 21 6.5v11'
    'A2.5 2.5 0 0 1 18.5 20h-13A2.5 2.5 0 0 1 3 17.5zM8 4v16M16 4v16'
    'M3 12h18"/>',
  );
  static const tv = AppIconData(
    '<path d="M3 8.5A2.5 2.5 0 0 1 5.5 6h13A2.5 2.5 0 0 1 21 8.5v8'
    'a2.5 2.5 0 0 1-2.5 2.5h-13A2.5 2.5 0 0 1 3 16.5zM8 2.8l4 3.2 4-3.2"/>',
  );
  static const people = AppIconData(
    '<path d="M12 12.2a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM5 20.5a7 7 0 0 1 14 0"/>',
  );
  static const swipe = AppIconData(
    '<path d="M8 13V5.5a1.5 1.5 0 0 1 3 0V12M11 11.5a1.5 1.5 0 0 1 3 0v1'
    'M14 12a1.5 1.5 0 0 1 3 0v1.5M17 13.5a1.5 1.5 0 0 1 3 0V16a6 6 0 0 1-6 6'
    'h-1.5a6 6 0 0 1-5-2.7L5 16a1.5 1.5 0 0 1 2.6-1.5L8 15"/>',
  );
  static const wifiOff = AppIconData(
    '<path d="M2 8.5a15 15 0 0 1 20 0"/><path d="M5.5 12a10 10 0 0 1 13 0"/>'
    '<path d="M9 15.5a5 5 0 0 1 6 0"/><path d="M3 3l18 18"/>',
  );
  static const refresh = AppIconData(
    '<path d="M20 12a8 8 0 1 1-2.6-5.9"/><path d="M20 4v4h-4"/>',
    strokeWidth: 2.2,
  );
  static const trending = AppIconData(
    '<path d="m3 17 6-6 4 4 8-8"/><path d="M15 7h6v6"/>',
    strokeWidth: 2,
  );
  static const arrowRight = AppIconData(
    '<path d="M5 12h14"/><path d="m13 6 6 6-6 6"/>',
    strokeWidth: 2.2,
  );
  static const film = AppIconData(
    '<rect x="3" y="5" width="18" height="14" rx="3.5"/>'
    '<path d="M10 9.5v5l4.5-2.5z"/>',
    strokeWidth: 1.6,
  );
}

class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {required this.color, this.size = 17, super.key});

  final AppIconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    icon.svg,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}
