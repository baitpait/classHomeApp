import 'package:hexacom_user/common/models/language_model.dart';
import 'package:hexacom_user/common/widgets/custom_single_child_list_widget.dart';
import 'package:hexacom_user/provider/language_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSelectWidget extends StatelessWidget {
  final bool fromMenu;
  const LanguageSelectWidget({
    super.key, required this.fromMenu,
  });


  @override
  Widget build(BuildContext context) {

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) => Center(child: SizedBox(
        width: Dimensions.webScreenWidth,
        child: CustomSingleChildListWidget(
            itemCount: languageProvider.languages.length,
            itemBuilder: (index) => _LanguageItemWidget(
              fromMenu: fromMenu,
              languageModel: languageProvider.languages[index],
              index: index,
            )),
      )),
    );
  }
}

class _LanguageItemWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final int index;
  final bool fromMenu;
  const _LanguageItemWidget({required this.languageModel, required this.index, required this.fromMenu});

  /// Native label for common languages, falls back to the provided name.
  static String _nativeName(String? code, String fallback) {
    switch (code) {
      case 'ar': return 'العربية';
      case 'en': return 'English';
      case 'he': return 'עברית';
      default: return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Consumer<LanguageProvider>(builder: (context, languageProvider, _) {
      final selected = languageProvider.selectIndex == index;
      final native = _nativeName(languageModel.languageCode, languageModel.languageName ?? '');
      final english = languageModel.languageName ?? '';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
            onTap: () {
              languageProvider.setSelectedLanguageModel(languageModel);
              languageProvider.setSelectIndex(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
                color: selected ? primary.withValues(alpha: 0.08) : theme.cardColor,
                border: Border.all(
                  color: selected ? primary : theme.dividerColor.withValues(alpha: 0.4),
                  width: selected ? 1.6 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _FlagAvatar(languageModel: languageModel),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          native,
                          style: rubikSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: selected ? primary : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (english.isNotEmpty && english != native)
                          Text(
                            english,
                            style: rubikRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: theme.hintColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Selection indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? primary : Colors.transparent,
                      border: Border.all(
                        color: selected ? primary : theme.dividerColor,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Circular flag avatar with a graceful fallback (country code) when no image.
class _FlagAvatar extends StatelessWidget {
  final LanguageModel languageModel;
  const _FlagAvatar({required this.languageModel});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final hasImage = (languageModel.imageUrl ?? '').isNotEmpty;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: 0.1),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasImage
          ? Image.asset(
              languageModel.imageUrl!,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(primary),
            )
          : _fallback(primary),
    );
  }

  Widget _fallback(Color primary) {
    return Center(
      child: Text(
        (languageModel.countryCode ?? languageModel.languageCode ?? '?').toUpperCase(),
        style: rubikSemiBold.copyWith(fontSize: 12, color: primary),
      ),
    );
  }
}

