import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Developer credit bar — teal gradient + peach accent (Anagheem Home identity).
/// Used from the web menu sheet and [FooterWebWidget].
class DeveloperCreditBarWidget extends StatelessWidget {
  const DeveloperCreditBarWidget({super.key});

  static const String _creditUrl = 'http://baitpait.com/';

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white.withValues(alpha: 0.92);
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadiusDirectional.only(
          topStart: const Radius.circular(14),
          bottomStart: const Radius.circular(14),
          topEnd: const Radius.circular(26),
          bottomEnd: const Radius.circular(26),
        ),
        child: InkWell(
          onTap: () async {
            if (await canLaunchUrlString(_creditUrl)) {
              await launchUrlString(_creditUrl);
            }
          },
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorResources.brandTealDark.withValues(alpha: 0.95),
                  ColorResources.navBarNavy,
                ],
              ),
              borderRadius: BorderRadiusDirectional.only(
                topStart: const Radius.circular(14),
                bottomStart: const Radius.circular(14),
                topEnd: const Radius.circular(26),
                bottomEnd: const Radius.circular(26),
              ),
              border: Border.all(
                color: ColorResources.brandTeal.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorResources.brandPeach.withValues(alpha: 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: const Radius.circular(4),
                        bottomStart: const Radius.circular(4),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ColorResources.brandTeal,
                          ColorResources.brandPeach,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorResources.brandPeach.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeLarge,
                        horizontal: Dimensions.paddingSizeLarge,
                      ),
                      child: Center(
                        child: Text(
                          getTranslated('footer_developer_credit', context),
                          style: rubikMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault + 1,
                            color: textColor,
                            height: 1.4,
                            letterSpacing: 0.15,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
