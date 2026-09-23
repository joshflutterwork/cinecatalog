import 'package:cinecatalog/core/config/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _seenOnboardingKey = 'seenOnboarding';

final onboardingSeenProvider = NotifierProvider<OnboardingSeenNotifier, bool>(
  OnboardingSeenNotifier.new,
);

final class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.read(sharedPreferencesProvider).getBool(_seenOnboardingKey) ?? false;

  Future<void> markSeen() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_seenOnboardingKey, true);
  }
}
