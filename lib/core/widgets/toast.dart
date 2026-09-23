import 'dart:async';

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:flutter/material.dart';

OverlayEntry? _current;
Timer? _timer;

/// A short glass message above the bottom controls. Replaces any toast
/// already on screen.
void showToast(BuildContext context, String message) =>
    showToastOn(Overlay.of(context), message);

/// [showToast] for callers without a context under the overlay, such as the
/// app-wide network error listener.
void showToastOn(OverlayState overlay, String message) {
  _timer?.cancel();
  _current?.remove();
  final bottom = MediaQuery.paddingOf(overlay.context).bottom;
  final entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 20,
      right: 20,
      bottom: bottom + 110,
      child: IgnorePointer(
        // Overlay entries sit outside the Scaffold, so without a Material
        // the Text falls back to the yellow-underlined debug style.
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 260),
              curve: AppMotion.ease,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - t)),
                  child: child,
                ),
              ),
              child: Glass(
                color: AppColors.glassStrong,
                borderColor: AppColors.glassBorderStrong,
                shadow: AppShadows.fabItem,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppText.pill.copyWith(
                    fontSize: 13,
                    color: AppColors.inkBadge,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  _current = entry;
  _timer = Timer(const Duration(milliseconds: 1800), () {
    if (_current == entry) {
      entry.remove();
      _current = null;
    }
  });
}
