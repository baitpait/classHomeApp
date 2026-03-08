import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/flash_sale/providers/flash_sale_provider.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlashSaleTimerWidget extends StatelessWidget {
  const FlashSaleTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashSaleProvider>(
      builder: (context, flashSaleProvider, _) {
        int d = 0, h = 0, m = 0, s = 0;
        if (flashSaleProvider.duration != null) {
          d = flashSaleProvider.duration!.inDays;
          h = flashSaleProvider.duration!.inHours - d * 24;
          m = flashSaleProvider.duration!.inMinutes - (24 * d * 60) - (h * 60);
          s = flashSaleProvider.duration!.inSeconds - (24 * d * 60 * 60) - (h * 60 * 60) - (m * 60);
        }
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: UnconstrainedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimerChip(value: d, label: getTranslated('days', context)),
                _Separator(),
                _TimerChip(value: h, label: getTranslated('hours', context)),
                _Separator(),
                _TimerChip(value: m, label: getTranslated('mins', context)),
                _Separator(),
                _TimerChip(value: s, label: getTranslated('sec', context)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerChip extends StatelessWidget {
  final int value;
  final String label;

  const _TimerChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final display = value > 9 ? value.toString() : '0$value';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            display,
            style: rubikBold.copyWith(
              color: onSurface,
              fontSize: 16,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: rubikMedium.copyWith(
            fontSize: 9,
            color: onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: rubikBold.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 16,
        ),
      ),
    );
  }
}
