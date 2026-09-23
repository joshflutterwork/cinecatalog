import 'dart:ui' show ImageFilter;

import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/utils/open_trailer.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Plays a YouTube [trailer] inside the app, over the detail page.
Future<void> showTrailer(BuildContext context, Trailer trailer) =>
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        // See-through: the detail page shows faintly behind the scrim.
        opaque: false,
        transitionDuration: AppMotion.detailIn,
        reverseTransitionDuration: AppMotion.detailIn,
        pageBuilder: (_, _, _) => TrailerPlayerPage(trailer: trailer),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: AppMotion.ease),
          child: child,
        ),
      ),
    );

/// Full page over the detail page: a see-through backdrop in the app's
/// background colour, with the trailer's name, a 16:9 YouTube player that
/// starts on its own, and "Watch on YouTube" for videos that cannot be
/// embedded. Turning the phone to landscape plays the trailer full screen.
class TrailerPlayerPage extends StatefulWidget {
  const TrailerPlayerPage({required this.trailer, super.key});

  final Trailer trailer;

  @override
  State<TrailerPlayerPage> createState() => _TrailerPlayerPageState();
}

class _TrailerPlayerPageState extends State<TrailerPlayerPage> {
  late final _controller = YoutubePlayerController.fromVideoId(
    videoId: widget.trailer.key,
    autoPlay: true,
    params: const YoutubePlayerParams(
      showFullscreenButton: true,
      strictRelatedVideos: true,
    ),
  );

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0x00000000),
    body: Stack(
      children: [
        // See-through backdrop: the detail page stays visible, lightly
        // blurred, behind the solid title, player and buttons.
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: const ColoredBox(color: AppColors.trailerScrim),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TRAILER', style: AppText.kicker),
                          const SizedBox(height: 2),
                          Text(
                            widget.trailer.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.listTitle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GlassIconButton(
                      icon: AppIcons.close,
                      iconColor: AppColors.inkButton,
                      color: AppColors.glassCard,
                      borderColor: AppColors.glassBorderStrong,
                      shadow: AppShadows.backButton,
                      onTap: () => Navigator.of(context).pop(),
                      semanticLabel: 'Close trailer',
                    ),
                  ],
                ),
              ),
              // Edge to edge: the player takes the full screen width.
              Expanded(
                child: Center(child: YoutubePlayer(controller: _controller)),
              ),
              StreamBuilder<YoutubePlayerValue>(
                stream: _controller.stream,
                builder: (context, snapshot) {
                  final error = snapshot.data?.error ?? YoutubeError.none;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (error != YoutubeError.none) ...[
                          Text(
                            error == YoutubeError.notEmbeddable ||
                                    error == YoutubeError.sameAsNotEmbeddable
                                ? 'This trailer can only be played on YouTube.'
                                : 'This trailer could not be played here.',
                            textAlign: TextAlign.center,
                            style: AppText.caption.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        _WatchOnYouTube(
                          onTap: () => openTrailer(context, widget.trailer),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Glass pill: the fallback for trailers that only play on YouTube.
class _WatchOnYouTube extends StatelessWidget {
  const _WatchOnYouTube({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Watch on YouTube',
    excludeSemantics: true,
    child: Pressable(
      onTap: onTap,
      scale: 0.96,
      child: Glass(
        height: 44,
        blur: 0,
        color: AppColors.glassStrong,
        borderColor: AppColors.glassBorderStrong,
        shadow: AppShadows.loadMore,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon(AppIcons.play, color: AppColors.accent, size: 14),
            const SizedBox(width: 8),
            Text(
              'Watch on YouTube',
              style: AppText.pill.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}
