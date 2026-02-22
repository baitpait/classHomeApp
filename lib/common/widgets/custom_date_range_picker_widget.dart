import 'package:flutter/material.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class CustomDateRangePickerWidget extends StatefulWidget {
  final String? text;
  final String? image;
  final bool requiredField;
  final Function? selectDate;
  final bool isFromHistory;
  const CustomDateRangePickerWidget({super.key, this.text,this.image, this.requiredField = false,this.selectDate, this.isFromHistory = false});

  @override
  State<CustomDateRangePickerWidget> createState() => _CustomDateRangePickerWidgetState();
}

bool _isDateSet(String dateText) {
  return dateText.contains('yyyy-mm-dd');
}

class _CustomDateRangePickerWidgetState extends State<CustomDateRangePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeController, _ ) {
        return GestureDetector(
          onTap: widget.selectDate as void Function()?,
          child: Container(
            margin:  const EdgeInsets.only(left: Dimensions.paddingSizeSmall,right: Dimensions.paddingSizeSmall),
            child: Container(
              height: 40,
              padding:  const EdgeInsets.fromLTRB(Dimensions.paddingSizeExtraSmall,Dimensions.paddingSizeExtraSmall,0,Dimensions.paddingSizeExtraSmall),

              /// todo - try to remove the unnecessary row widget
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                Text(widget.text!, style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                    color: _isDateSet(widget.text!) ? Theme.of(context).hintColor: widget.isFromHistory ?
                    themeController.darkTheme ? Theme.of(context).hintColor.withValues(alpha:.5) : Theme.of(context).cardColor: null,
                )),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              ]),
            ),
          ),
        );
      }
    );
  }
}



