import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/features/auth/widgets/code_picker_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final Color? fillColor;
  final int maxLines;
  final bool isPassword;
  final bool isCountryPicker;
  final bool isShowBorder;
  final bool isIcon;
  final bool isShowSuffixIcon;
  final bool isShowPrefixIcon;
  final Function? onTap;
  final Function? onSuffixTap;
  final IconData? suffixIconUrl;
  final String? suffixAssetUrl;
  final IconData? prefixIconUrl;
  final String? prefixAssetUrl;
  final bool isSearch;
  final Function? onSubmit;
  final bool isEnabled;
  final TextCapitalization capitalization;
  final bool isElevation;
  final bool isPadding;
  final Function? onChanged;
  final String? Function(String? )? onValidate;
  final Color? imageColor;
  final String? title;
  final bool isRequired;
  final String? countryDialCode;
  /// When set, shows a fixed, non-editable dial-code prefix (e.g. "+972") instead of the country picker.
  final String? fixedCountryCode;
  final Color? prefixAssetImageColor;
  final Function(CountryCode countryCode)? onCountryChanged;
  final bool isToolTipSuffix;
  final String? toolTipMessage;
  final GlobalKey? toolTipKey;
  final bool isSuffixIconLoading;
  final Color? borderColor;
  final double? hintFontSize;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLength;
  final TextStyle? titleTextStyle;
  final List<TextInputFormatter>? inputFormatters;
  final double? imageSize;
  final bool isDense;

  const CustomTextFieldWidget({super.key,  this.hintText = 'Write something...',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onSuffixTap,
    this.fillColor,
    this.onSubmit,
    this.capitalization = TextCapitalization.none,
    this.isCountryPicker = false,
    this.isShowBorder = false,
    this.isShowSuffixIcon = false,
    this.isShowPrefixIcon = false,
    this.onTap,
    this.isIcon = false,
    this.isPassword = false,
    this.suffixIconUrl,
    this.prefixIconUrl,
    this.isSearch = false,
    this.isElevation = true,
    this.onChanged,
    this.prefixAssetImageColor,
    this.isPadding=true, this.suffixAssetUrl, this.prefixAssetUrl,
    this.onValidate,
    this.imageColor, this.title, this.isRequired = false,
    this.countryDialCode,
    this.fixedCountryCode,
    this.onCountryChanged,
    this.hintFontSize,
    this.toolTipKey, this.toolTipMessage, this.isToolTipSuffix = false,
    this.isSuffixIconLoading = false,
    this.borderColor, this.contentPadding, this.maxLength, this.titleTextStyle,
    this.inputFormatters, this.imageSize, this.isDense = true
  });

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  bool _obscureText = true;
  bool isFocusActive = false;

  @override
  void initState() {
    widget.focusNode?.addListener(() {
      isFocusActive = widget.focusNode!.hasFocus;
      setState(() {});
    });
    widget.toolTipKey != null ? showAndCloseTooltip(widget.toolTipKey) : null;
    super.initState();
  }

  Future showAndCloseTooltip(var key) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
    await Future.delayed(const Duration(milliseconds: 10));
    tooltip?.deactivate();
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.sizeOf(context);
    final fontFamily = Theme.of(context).textTheme.bodyLarge?.fontFamily;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

      if(widget.title?.isNotEmpty ?? false)...[
        RichText(text: TextSpan(children: [

          TextSpan(
            text: widget.title,
            style: widget.titleTextStyle ?? rubikMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontFamily: fontFamily),
          ),

          if(widget.isRequired)
            TextSpan(
              text: ' *',
              style: rubikMedium.copyWith(color: Theme.of(context).colorScheme.error, fontFamily: fontFamily),
            ),


        ])),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
      ],

      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context)? 20 : 12),
        ),
        child: TextFormField(
          maxLength: widget.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          maxLines: widget.maxLines,
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeLarge),
          textInputAction: widget.inputAction,
          keyboardType: widget.inputType,
          cursorColor: Theme.of(context).primaryColor,
          textCapitalization: widget.capitalization,
          enabled: widget.isEnabled,
          autofocus: false,
          //onChanged: widget.isSearch ? widget.languageProvider.searchLanguage : null,
          obscureText: widget.isPassword ? _obscureText : false,
          inputFormatters: widget.inputFormatters ?? (widget.inputType == TextInputType.phone ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9+]'))] : null),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: widget.contentPadding
                ?? EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeLarge,
                  horizontal: widget.isPadding ? 22 : 0,
                ),
            enabledBorder: !widget.isShowBorder ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                width: 1,
                color: widget.borderColor ?? Theme.of(context).hintColor.withValues(alpha: 0.25),
              ),
            ),
            focusedBorder: !widget.isShowBorder ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                width: 1.5,
                color: widget.borderColor ?? Theme.of(context).primaryColor,
              ),
            ),
            errorBorder: !widget.isShowBorder ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7)),
            ),
            focusedErrorBorder: !widget.isShowBorder ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(width: 1.5, color: Theme.of(context).colorScheme.error),
            ),
            border: !widget.isShowBorder ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                width: 1,
                color: widget.borderColor ?? Theme.of(context).hintColor.withValues(alpha: 0.25),
              ),
            ),
            isDense: widget.isDense,
            hintText: getTranslated(widget.hintText, context),
            fillColor: widget.fillColor ?? Theme.of(context).cardColor,
            hintStyle: rubikRegular.copyWith(fontSize: widget.hintFontSize ?? Dimensions.fontSizeDefault, color: Theme.of(context).hintColor.withValues(alpha: 0.6), fontFamily: fontFamily),
            filled: true,
            prefixIcon: widget.isShowPrefixIcon
                ? IconButton(
              padding: const EdgeInsets.all(0),
              icon: widget.prefixAssetUrl != null ? Image.asset(
                widget.prefixAssetUrl!,
                color: isFocusActive ?
                widget.prefixAssetImageColor ?? Theme.of(context).primaryColor :
                (widget.prefixAssetImageColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.5),
                scale: 2.5, height: widget.imageSize,
              ) : Icon(
                widget.prefixIconUrl,
                color: isFocusActive ?
                widget.prefixAssetImageColor ?? Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6) :
                (widget.prefixAssetImageColor ?? Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))?.withValues(alpha: 0.5),
              ),
              onPressed: () {},
            )
                : widget.fixedCountryCode != null ? Padding(
                    padding: EdgeInsets.only(left: widget.isShowBorder == true ? 14 : 0, right: 8),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        widget.fixedCountryCode!,
                        style: rubikRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 22, color: Theme.of(context).dividerColor),
                    ]),
                  )
                : widget.countryDialCode != null ? Padding( padding:  EdgeInsets.only(left: widget.isShowBorder == true ?  10 : 0),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  CodePickerWidget(
                    onChanged: widget.onCountryChanged,
                    initialSelection: widget.countryDialCode,
                    favorite: [widget.countryDialCode ?? ""],
                    showDropDownButton: true,
                    padding: EdgeInsets.zero,
                    showFlagMain: true,
                    showFlagDialog: true,
                    dialogSize: Size(Dimensions.webScreenWidth/2, size.height*0.6),
                    dialogBackgroundColor: Theme.of(context).cardColor,
                    //barrierColor: Get.isDarkMode?Colors.black.withValues(alpha: 0.4):null,
                    textStyle: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color, fontFamily: fontFamily),
                  ),
                ])): null,
            prefixIconConstraints: widget.isSearch ? const BoxConstraints(minWidth: 23, maxHeight: 20) : null,
            suffixIconConstraints: widget.isSearch ? const BoxConstraints(
              minWidth: 25, // Adjust these values to fit the design
              minHeight: 25,
              maxWidth: 35,
              maxHeight: 35,
            ) : null,
            suffixIcon: widget.isShowSuffixIcon
                ? widget.isPassword
                ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                onPressed: _toggle)
                : widget.isIcon
                ? IconButton(
              onPressed: widget.onSuffixTap as void Function()?,
              icon: ResponsiveHelper.isDesktop(context)? Image.asset(
                widget.suffixAssetUrl!,
                width: 18,
                height: 18,
                color: widget.imageColor ?? Theme.of(context).primaryColor,
              ) : Icon(widget.suffixIconUrl, color: Theme.of(context).primaryColor.withValues(alpha: 0.6)),
            )
                : widget.isToolTipSuffix ?
            Tooltip(
              key: widget.toolTipKey,
              preferBelow: false,
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              triggerMode: TooltipTriggerMode.manual,
              message : widget.toolTipMessage ?? '',
              child: IconButton(
                onPressed: widget.onSuffixTap as void Function()?,
                icon: CustomAssetImageWidget(
                  widget.suffixAssetUrl!,
                  width: 18,
                  height: 18,
                )),
            ) : widget.isSuffixIconLoading ?
            Container(
              height: 15, width: 15,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: const CircularProgressIndicator(),
            ): null : null,
          ),
          onTap: widget.onTap as void Function()?,
          onChanged: widget.onChanged as void Function(String)?,
          onFieldSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus)
              : widget.onSubmit != null ? widget.onSubmit!(text) : null,
          validator: widget.onValidate,

        ),
      ),
    ],
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
