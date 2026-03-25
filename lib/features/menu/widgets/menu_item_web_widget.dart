import 'package:hexacom_user/features/menu/domain/models/menu_model.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter/material.dart';

class MenuItemWebWidget extends StatelessWidget {
  final MenuModel menu;
  const MenuItemWebWidget({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final destructive = menu.destructive;
    final color = destructive
        ? scheme.error
        : (theme.textTheme.titleMedium?.color ?? scheme.primary);
    final bgColor = destructive
        ? scheme.error.withValues(alpha: 0.10)
        : theme.cardColor;
    final borderColor = destructive
        ? scheme.error.withValues(alpha: 0.65)
        : theme.dividerColor.withValues(alpha: 0.12);
    final borderWidth = destructive ? 2.0 : 1.0;

    return Semantics(
      button: true,
      label: menu.title,
      hint: destructive ? getTranslated('delete_account_title_hint', context) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
        onTap: () => menu.route(),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: destructive
                    ? scheme.error.withValues(alpha: 0.12)
                    : theme.shadowColor.withValues(alpha: 0.06),
                blurRadius: destructive ? 16 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (destructive) ...[
                Icon(Icons.warning_amber_rounded, size: 18, color: scheme.error),
                const SizedBox(height: 4),
              ],
              if (menu.iconData != null)
                Icon(menu.iconData!, size: destructive ? 28 : 32, color: color)
              else
                CustomAssetImageWidget(menu.icon, height: destructive ? 28 : 32, width: destructive ? 28 : 32, color: color),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Text(
                  menu.title!,
                  style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: color,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (destructive) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Text(
                    getTranslated('delete_account_title_hint', context),
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: scheme.error.withValues(alpha: 0.85),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
