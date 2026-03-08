import 'package:flutter/material.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';

class AuthLayoutWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool showLogo;
  final Widget child;

  const AuthLayoutWidget({
    super.key,
    this.title,
    this.subtitle,
    this.showLogo = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    final cardColor = theme.cardColor;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 450,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isDesktop ? 0 : Dimensions.paddingSizeDefault,
              vertical: isDesktop ? Dimensions.paddingSizeSection : Dimensions.paddingSizeLarge,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ColorResources.primary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: ColorResources.lightGray.withValues(alpha: 0.4),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showLogo) ...[
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        Images.logo,
                        height: isDesktop ? 100 : 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                  if (title != null) ...[
                    Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: rubikBold.copyWith(
                        fontSize: Dimensions.fontSizeOverLarge,
                        color: ColorResources.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: ColorResources.getGreyColor(context),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

