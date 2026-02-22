import 'package:flutter/material.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CustomCalendarWidget extends StatefulWidget {
  final PickerDateRange? initDateRange;
  final Function(PickerDateRange? dateRange) onSubmit;
  final Function() onCancel;
  const CustomCalendarWidget({super.key, required this.onSubmit, required this.onCancel, this.initDateRange});

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {

  @override
  Widget build(BuildContext context) {

    return Consumer<ThemeProvider>(builder: (context, themeController, _) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
        child: Container(width: ResponsiveHelper.isDesktop(context) ? 450 : null,
          color: themeController.darkTheme ? Theme.of(context).dividerColor : Theme.of(context).cardColor,
          child: SfDateRangePicker(
            confirmText: getTranslated('ok', context),
            showActionButtons: true,
            cancelText: getTranslated('cancel', context),
            onCancel: () => widget.onCancel(),
            onSubmit: (value){

              if(value is PickerDateRange) {

                widget.onSubmit(value);

                Navigator.pop(context);
              }

            },
            todayHighlightColor: themeController.darkTheme ? Colors.white : Theme.of(context).primaryColor,
            selectionMode: DateRangePickerSelectionMode.range,
            rangeSelectionColor: Theme.of(context).primaryColor.withValues(alpha:.50),
            view: DateRangePickerView.month,
            selectionTextStyle: TextStyle(color: Theme.of(context).cardColor),
            startRangeSelectionColor: Theme.of(context).colorScheme.primary,
            endRangeSelectionColor: Theme.of(context).colorScheme.primary,
            initialSelectedRange:  PickerDateRange(
              widget.initDateRange?.startDate,
              widget.initDateRange?.endDate,
            ),
          ),),
      );
    });

  }
}
