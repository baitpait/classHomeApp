import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';

class PriceTextFieldWidget extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType inputType;
  final int maxLines;
  final bool isShowBorder;
  final Function? onChanged;
  final Color? borderColor;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;

  const PriceTextFieldWidget({
    super.key,
    this.hintText = 'Write something...',
    this.controller,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
    this.isShowBorder = false,
    this.onChanged,
    this.borderColor,
    this.inputFormatters,
    this.prefixText
  });

  @override
  State<PriceTextFieldWidget> createState() => _PriceTextFieldWidgetState();
}

class _PriceTextFieldWidgetState extends State<PriceTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context)? 20 : 12),
        ),
        child: TextFormField(
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          maxLines: widget.maxLines,
          controller: widget.controller,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: Dimensions.fontSizeLarge,
              ),
          keyboardType: widget.inputType,
          cursorColor: Theme.of(context).primaryColor,
          autofocus: false,
          textAlign: TextAlign.start,
          inputFormatters: widget.inputFormatters ?? (widget.inputType == TextInputType.phone ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9+]'))] : null),
          decoration: InputDecoration(
            counterText: '',
            enabledBorder: !widget.isShowBorder ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              borderSide: BorderSide(width: 1 , color: widget.borderColor ?? Theme.of(context).hintColor.withValues(alpha: 0.2)),
            ),
            focusedBorder: !widget.isShowBorder ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              borderSide: BorderSide(width: 1 ,color: widget.borderColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.5)),
            ),
            border: !widget.isShowBorder ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),

              borderSide: BorderSide( width: 1 , color: widget.borderColor ?? Theme.of(context).hintColor.withValues(alpha: 0.2)),
            ),
            isDense: true,
            hintText: getTranslated(widget.hintText, context),
            fillColor: Theme.of(context).cardColor,
            hintStyle: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor.withValues(alpha: 0.6)),
            filled: true,
            // Using a label avoids RTL prefix overlap hiding numbers.
            labelText: widget.prefixText != null ? getTranslated(widget.prefixText, context) : null,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          onChanged: widget.onChanged as void Function(String)?,
        ),
      ),
    ],
    );
  }
}
