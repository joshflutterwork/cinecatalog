import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// CineCatalog light glass tokens.
///
/// Source: the design handoff (CineCatalog v3 Light.dc.html and its README),
/// kept outside the repo in `localdocs/design/`.
/// Values are copied from the design; do not invent new ones in widgets.
abstract final class AppColors {
  static const bg = Color(0xFFF6F9FE);
  static const bgPage = Color(0xFFF2F6FC);
  static const detailBottom = Color.fromRGBO(247, 245, 253, 1);

  /// Detail poster: the design's white sheen at the top (`white 0.2` →
  /// transparent at 20 %). The design lays the text over the poster with a
  /// wash from 50 %; the app puts the text below the poster instead (see
  /// [detailImageBottomFade]), because with real TMDB posters the wash hid
  /// half the image.
  static const detailHeroTopFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(255, 255, 255, 0.2),
      Color.fromRGBO(255, 255, 255, 0),
    ],
    stops: [0, 0.2],
  );

  /// Last 24px of the detail poster, fading into [detailBottom] where the
  /// hero text starts below it.
  static const detailImageBottomFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color.fromRGBO(247, 245, 253, 0), detailBottom],
  );

  /// Behind the detail CTA row, so content scrolling under it fades out
  /// into [detailBottom] instead of peeking around the buttons.
  static const detailCtaFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color.fromRGBO(247, 245, 253, 0), detailBottom],
    stops: [0, 0.25],
  );

  static const ink = Color(0xFF122036);

  /// Behind the trailer dialog: the app background ([bg]), see-through so
  /// the detail page stays visible (lightly blurred) underneath.
  static const trailerScrim = Color.fromRGBO(246, 249, 254, 0.6);

  static const inkSoft = Color.fromRGBO(30, 52, 92, 0.75);
  static const inkBody = Color.fromRGBO(30, 52, 92, 0.68);
  static const inkFaint = Color.fromRGBO(30, 52, 92, 0.62);
  static const inkMuted = Color.fromRGBO(40, 70, 120, 0.62);
  static const inkHint = Color.fromRGBO(40, 70, 120, 0.5);
  static const inkNav = Color.fromRGBO(40, 70, 120, 0.7);
  static const inkFabItem = Color.fromRGBO(35, 62, 110, 0.85);
  static const inkBadge = Color(0xFF1C3050);
  static const inkButton = Color(0xFF26406A);
  static const icon = Color(0xFF2C4A70);

  static const accent = Color(0xFF3B82F6);
  static const accentSoft = Color(0xFF93C5FD);
  static const accentInk = Color(0xFF2F5FA8);
  static const avatarInk = Color(0xFF3F6FB8);
  static const fabIcon = Color(0xFF1E4B8F);
  static const tealSolid = Color(0xFF2DD4BF);
  static const teal = Color.fromRGBO(45, 212, 191, 0.4);
  static const dot = Color.fromRGBO(60, 100, 160, 0.55);
  static const chevronBg = Color.fromRGBO(208, 225, 255, 0.6);
  static const typeBadgeBg = Color.fromRGBO(208, 225, 255, 0.7);
  static const clearBg = Color.fromRGBO(40, 70, 120, 0.12);
  static const dotInactive = Color.fromRGBO(40, 70, 120, 0.18);
  static const spinnerTrack = Color.fromRGBO(147, 197, 253, 0.35);
  static const progressTrack = Color.fromRGBO(147, 197, 253, 0.3);
  static const errorInk = Color(0xFFD2506E);
  static const onAccent = Color(0xFFF7F2FF);

  static const glass = Color.fromRGBO(255, 255, 255, 0.72);
  static const glassSoft = Color.fromRGBO(255, 255, 255, 0.62);
  static const glassCard = Color.fromRGBO(255, 255, 255, 0.78);
  static const glassBadge = Color.fromRGBO(255, 255, 255, 0.82);
  static const glassStrong = Color.fromRGBO(255, 255, 255, 0.85);
  static const glassBorder = Color.fromRGBO(255, 255, 255, 0.9);
  static const glassBorderStrong = Color.fromRGBO(255, 255, 255, 0.95);
  static const scrim = Color.fromRGBO(240, 246, 253, 0.55);

  /// FAB scrim: the design's [scrim] colour, strongest behind the menu in
  /// the bottom-right corner and fading out before the top of the screen.
  /// Deviates from the design's full-screen blurred scrim on purpose.
  static const fabScrim = RadialGradient(
    center: Alignment.bottomRight,
    radius: 1.25,
    colors: [
      Color.fromRGBO(240, 246, 253, 0.85),
      scrim,
      Color.fromRGBO(240, 246, 253, 0),
    ],
    stops: [0, 0.45, 1],
  );

  static const shimmerBase = Color.fromRGBO(214, 226, 244, 0.7);
  static const shimmerHighlight = Color.fromRGBO(255, 255, 255, 0.95);

  static const glowBlue = Color.fromRGBO(147, 197, 253, 0.55);
  static const glowTeal = Color.fromRGBO(45, 212, 191, 0.4);

  /// CSS `linear-gradient(120deg, …)`.
  static const activePill = LinearGradient(
    begin: Alignment(-0.9, -0.5),
    end: Alignment(0.9, 0.5),
    colors: [
      Color.fromRGBO(208, 225, 255, 0.92),
      Color.fromRGBO(230, 240, 255, 0.85),
    ],
  );
  static const playGradient = LinearGradient(
    begin: Alignment(-0.9, -0.5),
    end: Alignment(0.9, 0.5),
    colors: [accent, accentSoft],
  );
  static const progressGradient = LinearGradient(colors: [accent, tealSolid]);
  static const avatarGradient = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.7, 1),
    colors: [Color(0xFFE8F1FF), Color(0xFFCFE0FB)],
  );
  static const errorIconGradient = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.7, 1),
    colors: [Color(0xFFFFE9EE), Color(0xFFFFD3DD)],
  );
  static const fabGradient = LinearGradient(
    begin: Alignment(-0.8, -0.6),
    end: Alignment(0.8, 0.6),
    colors: [
      Color.fromRGBO(147, 197, 253, 0.35),
      Color.fromRGBO(255, 255, 255, 0.78),
    ],
  );
  static const logoGradient = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.7, 1),
    colors: [
      Color.fromRGBO(255, 255, 255, 0.9),
      Color.fromRGBO(208, 225, 255, 0.75),
    ],
  );

  /// Placeholder posters from the design, used when TMDB has no image.
  static const posterGradients = <List<Color>>[
    [Color(0xFFFFB3C7), Color(0xFFF4739E), Color(0xFF8E2E6B)],
    [Color(0xFFCFE3F2), Color(0xFF7FA6CE), Color(0xFF3A4C7A)],
    [Color(0xFFD6C4FF), Color(0xFF9A6BF0), Color(0xFF4A2A9E)],
    [Color(0xFFFFD3A8), Color(0xFFF0836E), Color(0xFF9B3F62)],
    [Color(0xFFA9F2E5), Color(0xFF4FB3C4), Color(0xFF2F5E8F)],
    [Color(0xFFF0CCFF), Color(0xFFB274E0), Color(0xFF5E2B86)],
    [Color(0xFFC3CEFF), Color(0xFF7C7BE0), Color(0xFF3E3A9C)],
    [Color(0xFFFFE9BC), Color(0xFFEFA279), Color(0xFFA9566B)],
  ];
}

/// All shadows are tinted blue, never black.
abstract final class AppShadows {
  static const sm = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.14),
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];
  static const md = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.12),
      offset: Offset(0, 8),
      blurRadius: 22,
    ),
  ];
  static const rail = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.18),
      offset: Offset(0, 12),
      blurRadius: 26,
    ),
  ];
  static const deck = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.30),
      offset: Offset(0, 28),
      blurRadius: 60,
    ),
  ];
  static const deckPanel = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.2),
      offset: Offset(0, 14),
      blurRadius: 34,
    ),
  ];
  static const badge = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.18),
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];
  static const chip = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.14),
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];
  static const soft = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.1),
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];
  static const chipIdle = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.06),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];
  static const button = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.18),
      offset: Offset(0, 8),
      blurRadius: 20,
    ),
  ];
  static const backButton = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.14),
      offset: Offset(0, 8),
      blurRadius: 22,
    ),
  ];
  static const favButton = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.18),
      offset: Offset(0, 10),
      blurRadius: 24,
    ),
  ];
  static const listRow = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.1),
      offset: Offset(0, 10),
      blurRadius: 26,
    ),
  ];
  static const searchRow = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.1),
      offset: Offset(0, 8),
      blurRadius: 20,
    ),
  ];
  static const searchField = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.14),
      offset: Offset(0, 10),
      blurRadius: 26,
    ),
  ];
  static const loadMore = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.12),
      offset: Offset(0, 8),
      blurRadius: 20,
    ),
  ];
  static const posterSmall = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.2),
      offset: Offset(0, 8),
      blurRadius: 18,
    ),
  ];
  static const avatar = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.22),
      offset: Offset(0, 14),
      blurRadius: 28,
    ),
  ];
  static const fabItem = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.22),
      offset: Offset(0, 14),
      blurRadius: 30,
    ),
  ];
  static const navIdle = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.16),
      offset: Offset(0, 10),
      blurRadius: 24,
    ),
  ];
  static const errorCard = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.16),
      offset: Offset(0, 22),
      blurRadius: 50,
    ),
  ];
  static const emptyIcon = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.16),
      offset: Offset(0, 14),
      blurRadius: 30,
    ),
  ];
  static const shimmerDeck = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.12),
      offset: Offset(0, 20),
      blurRadius: 44,
    ),
  ];
  static const onboardCard = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.26),
      offset: Offset(0, 26),
      blurRadius: 54,
    ),
  ];
  static const onboardChip = [
    BoxShadow(
      color: Color.fromRGBO(30, 64, 120, 0.18),
      offset: Offset(0, 14),
      blurRadius: 30,
    ),
  ];

  static const fab = [
    BoxShadow(
      color: Color.fromRGBO(37, 99, 180, 0.28),
      offset: Offset(0, 16),
      blurRadius: 34,
    ),
  ];
  static const logo = [
    BoxShadow(
      color: Color.fromRGBO(37, 99, 180, 0.3),
      offset: Offset(0, 26),
      blurRadius: 56,
    ),
  ];
  static const cta = [
    BoxShadow(
      color: Color.fromRGBO(59, 130, 246, 0.38),
      offset: Offset(0, 16),
      blurRadius: 34,
    ),
  ];
  static const retry = [
    BoxShadow(
      color: Color.fromRGBO(59, 130, 246, 0.34),
      offset: Offset(0, 14),
      blurRadius: 30,
    ),
  ];
  static const navActive = [
    BoxShadow(
      color: Color.fromRGBO(59, 130, 246, 0.2),
      offset: Offset(0, 12),
      blurRadius: 28,
    ),
  ];
  static const chipActive = [
    BoxShadow(
      color: Color.fromRGBO(59, 130, 246, 0.2),
      offset: Offset(0, 8),
      blurRadius: 20,
    ),
  ];
  static const errorIcon = [
    BoxShadow(
      color: Color.fromRGBO(220, 80, 110, 0.18),
      offset: Offset(0, 10),
      blurRadius: 24,
    ),
  ];
}

abstract final class AppRadius {
  static const poster = 18.0;
  static const deck = 30.0;
  static const deckPanel = 24.0;
  static const pill = 28.0;
  static const fab = 26.0;
  static const fabItem = 22.0;
  static const listRow = 24.0;
  static const searchRow = 20.0;
  static const listPoster = 16.0;
  static const searchPoster = 12.0;
}

abstract final class AppSpacing {
  static const page = 20.0;
  static const railGap = 13.0;
  static const section = 26.0;
}

abstract final class AppMotion {
  static const ease = Cubic(0.22, 1, 0.36, 1);

  /// CSS `ease-in-out`, used only by the ambient loops (glow, sheen, breathe).
  static const loop = Cubic(0.42, 0, 0.58, 1);

  /// CSS `ease`, used by the short fade-ins.
  static const fade = Cubic(0.25, 0.1, 0.25, 1);
  static const deck = Duration(milliseconds: 420);
  static const detailIn = Duration(milliseconds: 360);
  static const listIn = Duration(milliseconds: 340);
  static const searchIn = Duration(milliseconds: 300);
  static const rowIn = Duration(milliseconds: 400);
  static const fabRotate = Duration(milliseconds: 320);
  static const fabItem = Duration(milliseconds: 460);
  static const fabItemStagger = Duration(milliseconds: 40);
  static const scrim = Duration(milliseconds: 220);
  static const navPill = Duration(milliseconds: 300);
  static const ringTurn = Duration(milliseconds: 3400);
  static const shimmer = Duration(milliseconds: 1300);
  static const searchDebounce = Duration(milliseconds: 350);
  static const splash = Duration(seconds: 2);
  static const deckSwipeThreshold = 90.0;
  static const deckTapSlop = 8.0;
}

abstract final class AppFonts {
  static const sora = 'Sora';
  static const dmSans = 'DM Sans';
}

abstract final class AppText {
  static const pageTitle = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.05,
    height: 1.05,
    color: AppColors.ink,
  );
  static const kicker = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
    color: AppColors.inkMuted,
  );
  static const sectionTitle = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 19,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.47,
    color: AppColors.ink,
  );
  static const railTitle = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.34,
    color: AppColors.ink,
  );
  static const listTitle = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.66,
    color: AppColors.ink,
  );
  static const deckTitle = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 27,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.95,
    height: 1.1,
    color: AppColors.ink,
  );
  static const detailTitle = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 31,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.24,
    height: 1.08,
    color: AppColors.ink,
  );
  static const cardTitle = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 19,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.38,
    color: AppColors.ink,
  );
  static const rowTitle = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    height: 1.25,
    color: AppColors.ink,
  );
  static const onboardTitle = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 29,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.1,
    height: 1.1,
    color: AppColors.ink,
  );
  static const brand = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.98,
    color: AppColors.ink,
  );
  static const body = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 13,
    height: 1.5,
    color: AppColors.inkSoft,
  );
  static const detailBody = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 13.5,
    height: 1.62,
    color: Color.fromRGBO(30, 52, 92, 0.72),
  );
  static const caption = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 12,
    height: 1.5,
    color: AppColors.inkFaint,
  );
  static const meta = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 11.5,
    color: AppColors.inkMuted,
  );
  static const viewAll = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 12.5,
    color: Color.fromRGBO(40, 70, 120, 0.68),
  );
  static const pill = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: AppColors.accentInk,
  );
  static const button = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: AppColors.onAccent,
  );
  static const posterTitle = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: Color(0xFFFFFFFF),
  );
  static const badge = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBadge,
  );
  static const badgeSmall = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBadge,
  );
  static const chip = TextStyle(
    fontFamily: AppFonts.dmSans,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(30, 52, 92, 0.9),
  );
}
