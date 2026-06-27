import 'package:flutter/foundation.dart' show kIsWeb;

/// Feature flags to disable third-party and non-cash features in the app.
/// When true, the corresponding feature is hidden/disabled in the UI and logic.
/// Aligns with admin panel: when Firebase is hidden/disabled there (e.g. force_cash_only_and_hide_third_party),
/// Firebase is hidden and disabled here too.
class FeatureFlags {
  FeatureFlags._();

  /// Cash only: do not show any digital payment methods (only cash on delivery).
  static const bool cashOnly = true;

  /// Hide social login (Google, Facebook, Apple) from login and OTP screens.
  static const bool hideSocialLogin = true;

  /// Disable Google Map (address picker, tracking map). Address still uses text + city.
  static const bool disableMap = true;

  /// Disable Firebase and push on **all** platforms (FCM init, token, background handler).
  /// Same as admin: Firebase hidden and disabled.
  static const bool disableFirebaseAndPush = true;

  /// Web-only: skip Firebase/FCM when the site is display/streaming-only (no push, no fcm-subscribe API).
  /// Set to false if you enable push on web again. Code paths stay in place; guards use [skipFirebaseAndPush].
  static const bool disableFirebaseAndPushOnWeb = true;

  /// True when Firebase Messaging / push should not run (global [disableFirebaseAndPush] or web + [disableFirebaseAndPushOnWeb]).
  static bool get skipFirebaseAndPush =>
      disableFirebaseAndPush || (kIsWeb && disableFirebaseAndPushOnWeb);

  /// Disable Firebase OTP verification in auth (phone login uses SMS only). Same as admin.
  static const bool disableFirebaseAuth = true;
}
