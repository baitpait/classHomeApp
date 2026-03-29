/// Resolves the profile/avatar image URL: user photo when present, else app logo from config.
class UserAvatarImageUrl {
  UserAvatarImageUrl._();

  static String _joinBaseAndPath(String base, String path) {
    final b = base.trim();
    final p = path.trim();
    if (b.isEmpty || p.isEmpty) return '';
    final noTrailing = b.endsWith('/') ? b.substring(0, b.length - 1) : b;
    final noLeading = p.startsWith('/') ? p.substring(1) : p;
    return '$noTrailing/$noLeading';
  }

  /// Returns a non-empty network URL, or `null` to fall back to local placeholder / icon.
  static String? resolve({
    required bool isLoggedIn,
    String? userImage,
    String? customerImageUrl,
    String? appLogo,
    String? ecommerceImageUrl,
  }) {
    final userImg = (userImage ?? '').trim();
    if (isLoggedIn && userImg.isNotEmpty) {
      final base = (customerImageUrl ?? '').trim();
      if (base.isNotEmpty) {
        return _joinBaseAndPath(base, userImg);
      }
    }

    final logo = (appLogo ?? '').trim();
    final eco = (ecommerceImageUrl ?? '').trim();
    if (logo.isNotEmpty && eco.isNotEmpty) {
      return _joinBaseAndPath(eco, logo);
    }

    return null;
  }
}
