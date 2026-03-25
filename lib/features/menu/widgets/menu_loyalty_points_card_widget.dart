import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';

/// Compact card for displaying loyalty points in the menu (e.g. PC header).
class MenuLoyaltyPointsCardWidget extends StatelessWidget {
  final int points;
  final VoidCallback? onTap;

  const MenuLoyaltyPointsCardWidget({
    super.key,
    required this.points,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars_rounded,
                size: 22,
                color: Colors.white,
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                '$points ${getTranslated('points', context)}',
                style: rubikMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
