
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:hexacom_user/common/widgets/language_select_widget.dart';
import 'package:hexacom_user/features/language/widgets/language_select_button_widget.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/provider/language_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChooseLanguageScreen extends StatefulWidget {
  final bool fromMenu;
  const ChooseLanguageScreen({super.key, this.fromMenu = false});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<LanguageProvider>(context, listen: false).initializeAllLanguages(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return CustomPopScopeWidget(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Branded header: logo badge + title + subtitle
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: primary.withValues(alpha: 0.18)),
                ),
                padding: const EdgeInsets.all(14),
                child: Image.asset(Images.logo, fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              Text(
                getTranslated('select_language', context),
                style: rubikBold.copyWith(
                  fontSize: 24,
                  color: theme.textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                child: Text(
                  getTranslated('choose_the_language', context),
                  textAlign: TextAlign.center,
                  style: rubikRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: theme.hintColor,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: LanguageSelectWidget(fromMenu: widget.fromMenu),
                ),
              ),

              LanguageSelectButtonWidget(fromMenu: widget.fromMenu),
            ],
          ),
        ),
      ),
    );
  }
}





