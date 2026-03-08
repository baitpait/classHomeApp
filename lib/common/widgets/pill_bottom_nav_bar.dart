import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';

/// Pill-shaped bottom navigation bar: dark pill, active item with oval + icon + label, inactive icon-only.
class PillBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PillNavItem> items;
  final int? cartCount;
  final int? wishlistCount;

  const PillBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.cartCount,
    this.wishlistCount,
  });

  @override
  Widget build(BuildContext context) {
    final barBg = ColorResources.navBarNavy;
    final activeBg = Colors.white.withValues(alpha: 0.18);
    final iconColor = Colors.white;
    final screenWidth = MediaQuery.sizeOf(context).width;
    const horizontalPadding = 28.0 * 2;
    final barWidth = (screenWidth - horizontalPadding).clamp(0.0, Dimensions.bottomNavBarMaxWidth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 56,
            constraints: BoxConstraints(maxWidth: barWidth),
        decoration: BoxDecoration(
          color: barBg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = index == currentIndex;
                    final showBadge = (index == 2 && (cartCount ?? 0) > 0) ||
                        (index == 3 && (wishlistCount ?? 0) > 0);
                    final badgeCount = index == 2 ? (cartCount ?? 0) : (index == 3 ? (wishlistCount ?? 0) : 0);

                    final content = InkWell(
                      onTap: () => onTap(index),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 12 : 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? activeBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: isSelected
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _NavIcon(
                                    icon: item.icon,
                                    color: iconColor,
                                    size: 24,
                                    showBadge: showBadge,
                                    badgeCount: badgeCount,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      item.label,
                                      style: rubikMedium.copyWith(
                                        color: iconColor,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: _NavIcon(
                                  icon: item.icon,
                                  color: iconColor.withValues(alpha: 0.85),
                                  size: 26,
                                  showBadge: showBadge,
                                  badgeCount: badgeCount,
                                ),
                              ),
                      ),
                    );

                    return isSelected
                        ? Expanded(child: content)
                        : SizedBox(width: 46, child: content);
              }),
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool showBadge;
  final int badgeCount;

  const _NavIcon({
    required this.icon,
    required this.color,
    required this.size,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: color, size: size),
        if (showBadge)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF3B30),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: rubikMedium.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class PillNavItem {
  final IconData icon;
  final String label;

  const PillNavItem({required this.icon, required this.label});
}
