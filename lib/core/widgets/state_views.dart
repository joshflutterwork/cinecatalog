import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/gradient_button.dart';
import 'package:flutter/widgets.dart';

/// Any error from a provider, as a [Failure].
Failure asFailure(Object error) =>
    error is Failure ? error : ServerFailure(error.toString());

/// User-facing copy for each failure type.
extension FailureCopy on Failure {
  String get title => switch (this) {
    NetworkFailure() => 'No connection',
    UnauthorizedFailure() => 'Access denied',
    NotFoundFailure() => 'Not found',
    ServerFailure() => 'Server is having trouble',
    ParsingFailure() => 'Data could not be read',
    RateLimitFailure() => 'Too many requests',
    StorageFailure() => 'Could not save',
  };

  String get body => switch (this) {
    NetworkFailure() =>
      'Could not load the catalog from TMDB. Check your connection and '
          'try again.',
    UnauthorizedFailure() => 'The TMDB token is invalid or has expired.',
    NotFoundFailure() => 'This title is no longer on TMDB.',
    ServerFailure() => 'TMDB did not respond correctly. Try again later.',
    ParsingFailure() => 'The TMDB response was not in the expected format.',
    RateLimitFailure() =>
      'TMDB is limiting requests right now. Wait a moment and try again.',
    StorageFailure() => 'Your watchlist could not be read or saved.',
  };
}

/// Glass card with a pink icon, the failure copy and a "Try again" button.
class ErrorCard extends StatelessWidget {
  const ErrorCard({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = asFailure(error);
    return Glass(
      radius: 30,
      blur: 24,
      borderColor: AppColors.glassBorderStrong,
      shadow: AppShadows.errorCard,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 30),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.errorIconGradient,
                boxShadow: AppShadows.errorIcon,
              ),
              child: const Center(
                child: AppIcon(
                  AppIcons.wifiOff,
                  color: AppColors.errorInk,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              failure.title,
              textAlign: TextAlign.center,
              style: AppText.cardTitle,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Text(
                failure.body,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  height: 1.6,
                  color: AppColors.inkBody,
                ),
              ),
            ),
            const SizedBox(height: 22),
            GradientButton(
              label: 'Try again',
              onTap: onRetry,
              leading: AppIcons.refresh,
              height: 48,
              shadow: AppShadows.retry,
              textStyle: AppText.button.copyWith(
                fontSize: 14,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round blue icon, title and body. Used for empty lists and searches.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.body,
    super.key,
    this.icon = AppIcons.searchEmpty,
  });

  final String title;
  final String body;
  final AppIconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 54),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.avatarGradient,
            border: Border.all(color: AppColors.glassBorderStrong, width: 0.5),
            boxShadow: AppShadows.emptyIcon,
          ),
          child: Center(
            child: AppIcon(icon, color: AppColors.avatarInk, size: 28),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.cardTitle.copyWith(fontSize: 18, letterSpacing: -0.36),
        ),
        const SizedBox(height: 7),
        Text(
          body,
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(height: 1.6, color: AppColors.inkFaint),
        ),
      ],
    ),
  );
}
