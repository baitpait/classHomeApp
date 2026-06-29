import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';

/// Result returned by the area calculator sheet.
class AreaSelectionResult {
  final int rolls;
  final Map<String, dynamic>? areaCalc;
  AreaSelectionResult(this.rolls, this.areaCalc);
}

/// Opens the area-based purchase sheet. Returns null if the user cancels.
Future<AreaSelectionResult?> showAreaCalculatorSheet(
  BuildContext context,
  Product product,
  double unitPrice, {
  int maxStock = 9999,
}) {
  return showModalBottomSheet<AreaSelectionResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _AreaCalculatorSheet(
        product: product,
        unitPrice: unitPrice,
        maxStock: maxStock <= 0 ? 9999 : maxStock,
      ),
    ),
  );
}

class _AreaCalculatorSheet extends StatefulWidget {
  final Product product;
  final double unitPrice;
  final int maxStock;
  const _AreaCalculatorSheet({
    required this.product,
    required this.unitPrice,
    required this.maxStock,
  });

  @override
  State<_AreaCalculatorSheet> createState() => _AreaCalculatorSheetState();
}

class _AreaCalculatorSheetState extends State<_AreaCalculatorSheet> {
  bool _byArea = true;
  bool _applyWaste = false;
  final TextEditingController _widthCtrl = TextEditingController();
  final TextEditingController _lengthCtrl = TextEditingController();
  int _count = 1;

  double get _coverage => widget.product.coveragePerUnit ?? 0;
  double get _waste => widget.product.wastePercent;

  @override
  void initState() {
    super.initState();
    _applyWaste = _waste > 0; // default ON when the admin set a waste percent
  }

  @override
  void dispose() {
    _widthCtrl.dispose();
    _lengthCtrl.dispose();
    super.dispose();
  }

  double get _width => double.tryParse(_widthCtrl.text.trim()) ?? 0;
  double get _length => double.tryParse(_lengthCtrl.text.trim()) ?? 0;
  double get _rawArea => _width * _length;

  double get _effectiveArea =>
      _applyWaste && _waste > 0 ? _rawArea * (1 + _waste / 100) : _rawArea;

  /// Rolls needed (round up) in area mode, or chosen count.
  int get _rolls {
    if (!_byArea) return _count;
    if (_coverage <= 0 || _rawArea <= 0) return 0;
    return math.max(1, (_effectiveArea / _coverage).ceil());
  }

  double get _coveredArea => _rolls * _coverage;
  String get _rollWord =>
      (widget.product.rollLabel?.trim().isNotEmpty ?? false)
          ? widget.product.rollLabel!.trim()
          : getTranslated('roll', context);

  void _submit() {
    final rolls = _rolls;
    if (rolls < 1) return;
    final clamped = math.min(rolls, widget.maxStock);
    final Map<String, dynamic> areaCalc = {
      if (_byArea) 'width': _width,
      if (_byArea) 'length': _length,
      if (_byArea) 'area': double.parse(_rawArea.toStringAsFixed(2)),
      'coverage': _coverage,
      'rolls': clamped,
      'waste_percent': _byArea && _applyWaste ? _waste : 0,
      'price_basis': widget.product.priceBasis,
      'mode': _byArea ? 'area' : 'count',
    };
    Navigator.pop(context, AreaSelectionResult(clamped, areaCalc));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final canSubmit = _rolls >= 1;
    final totalPrice = widget.unitPrice * _rolls;

    return Container(
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.only(
        left: Dimensions.paddingSizeLarge,
        right: Dimensions.paddingSizeLarge,
        top: Dimensions.paddingSizeSmall,
        bottom: Dimensions.paddingSizeLarge,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                height: 4, width: 44,
                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),

            // Roll coverage info — always visible
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              ),
              child: Row(children: [
                Icon(Icons.straighten_rounded, color: primary, size: 20),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(
                    '${getTranslated('each_roll_covers', context)} ${_fmt(_coverage)} ${getTranslated('sqm', context)}',
                    style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Mode toggle
            Row(children: [
              _modeTab(getTranslated('by_area', context), _byArea, () => setState(() => _byArea = true)),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              _modeTab(getTranslated('by_count', context), !_byArea, () => setState(() => _byArea = false)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            if (_byArea) ..._areaInputs(theme) else _countInput(theme),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Live result card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                border: Border.all(color: primary.withValues(alpha: 0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (_byArea && _rawArea > 0)
                  Text(
                    '${_fmt(_width)} × ${_fmt(_length)} ${getTranslated('meter', context)} = ${_fmt(_rawArea)} ${getTranslated('sqm', context)}',
                    style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                const SizedBox(height: 4),
                Text(
                  canSubmit
                      ? '$_rolls $_rollWord'
                      : getTranslated('enter_dimensions', context),
                  style: rubikBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: primary),
                ),
                if (canSubmit) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${getTranslated('covers', context)} ${_fmt(_coveredArea)} ${getTranslated('sqm', context)}'
                    '${_byArea && _coveredArea > _rawArea && _rawArea > 0 ? ' · ${getTranslated('surplus', context)} ${_fmt(_coveredArea - _rawArea)} ${getTranslated('sqm', context)}' : ''}',
                    style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor),
                  ),
                ],
              ]),
            ),

            if (_byArea && _waste > 0) ...[
              const SizedBox(height: 4),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _applyWaste,
                activeThumbColor: primary,
                onChanged: (v) => setState(() => _applyWaste = v),
                title: Text(
                  '${getTranslated('apply_waste', context)} (+${_fmt(_waste)}%)',
                  style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
              ),
            ],

            const SizedBox(height: Dimensions.paddingSizeSmall),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusButton)),
                ),
                child: Text(
                  canSubmit
                      ? '${getTranslated('add_to_cart', context)} · $_rolls $_rollWord · ${PriceConverterHelper.convertPrice(totalPrice)}'
                      : getTranslated('add_to_cart', context),
                  style: rubikBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _areaInputs(ThemeData theme) {
    return [
      Row(children: [
        Expanded(child: _numField(_widthCtrl, getTranslated('width', context))),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(child: _numField(_lengthCtrl, getTranslated('length', context))),
      ]),
    ];
  }

  Widget _numField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: '$label (${getTranslated('meter', context)})',
        isDense: true,
      ),
    );
  }

  Widget _countInput(ThemeData theme) {
    final primary = theme.primaryColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepBtn(Icons.remove, () { if (_count > 1) setState(() => _count--); }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: Text('$_count', style: rubikBold.copyWith(fontSize: 26, color: primary)),
        ),
        _stepBtn(Icons.add, () { if (_count < widget.maxStock) setState(() => _count++); }),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    final primary = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primary, size: 24),
      ),
    );
  }

  Widget _modeTab(String label, bool selected, VoidCallback onTap) {
    final primary = Theme.of(context).primaryColor;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? primary : primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          ),
          child: Text(
            label,
            style: rubikMedium.copyWith(
              color: selected ? Colors.white : primary,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}
