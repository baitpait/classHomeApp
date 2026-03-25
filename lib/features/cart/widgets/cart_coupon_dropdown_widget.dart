import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/features/coupon/domain/models/coupon_model.dart';
import 'package:hexacom_user/features/coupon/providers/coupon_provider.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/provider/localization_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

/// Displays available coupons in a dropdown and applies the selected one.
/// Replaces manual coupon code entry; list is loaded from API on first display.
/// Styled like the original coupon field (dotted border, icon, pill button).
class CartCouponDropdownWidget extends StatefulWidget {
  final double totalAmount;

  const CartCouponDropdownWidget({super.key, required this.totalAmount});

  @override
  State<CartCouponDropdownWidget> createState() => _CartCouponDropdownWidgetState();
}

class _CartCouponDropdownWidgetState extends State<CartCouponDropdownWidget> {
  bool _listLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listLoaded) {
      _listLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<CouponProvider>().getCouponList(context);
      });
    }
  }

  String _couponLabel(CouponModel c) {
    final displayName = (c.title ?? '').trim().isNotEmpty ? c.title!.trim() : (c.code ?? '').trim();
    final discount = c.discount ?? 0;
    final type = c.discountType ?? 'amount';
    if (type == 'percent') {
      return '$displayName (${discount.toStringAsFixed(0)}%)';
    }
    return '$displayName (${PriceConverterHelper.convertPrice(discount)})';
  }

  @override
  Widget build(BuildContext context) {
    final isLtr = Provider.of<LocalizationProvider>(context, listen: false).isLtr;

    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        dashPattern: const [5, 5],
        strokeWidth: 2,
        color: Theme.of(context).primaryColor,
        radius: const Radius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
        child: Consumer<CouponProvider>(
          builder: (context, couponProvider, _) {
            final list = couponProvider.couponList;
            final selectedCoupon = couponProvider.coupon;
            final isLoading = couponProvider.isLoading;
            final hasCoupon = selectedCoupon != null;
            final selectedId = selectedCoupon?.id;
            final items = _buildItems(list);
            final valueExists = selectedId == null ||
                items.any((item) => item.value == selectedId);

            return Row(
              children: [
                const CustomAssetImageWidget(
                  Images.cartCouponIcon,
                  width: 30,
                  height: 30,
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(isLtr ? 10 : 0),
                        right: Radius.circular(isLtr ? 0 : 10),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: valueExists ? selectedId : null,
                        isExpanded: true,
                        isDense: true,
                        hint: Text(
                          getTranslated('apply_coupon', context),
                          style: rubikRegular.copyWith(color: Theme.of(context).hintColor),
                        ),
                        items: items,
                        onChanged: isLoading
                            ? null
                            : (int? id) => _onCouponChanged(context, id, list),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: isLoading
                      ? null
                      : () {
                          if (hasCoupon) {
                            couponProvider.removeCouponData(true);
                          }
                        },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    height: 40,
                    width: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: hasCoupon
                        ? const Icon(Icons.clear, color: Colors.white, size: 20)
                        : isLoading
                            ? const SizedBox(
                                width: Dimensions.paddingSizeDefault,
                                height: Dimensions.paddingSizeDefault,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                getTranslated('apply', context),
                                style: rubikMedium.copyWith(color: Colors.white),
                              ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem<int?>> _buildItems(List<CouponModel>? list) {
    final items = <DropdownMenuItem<int?>>[
      DropdownMenuItem<int?>(
        value: null,
        child: Text(
          getTranslated('without_coupon', context),
          style: rubikRegular,
        ),
      ),
    ];
    if (list != null && list.isNotEmpty) {
      for (final c in list) {
        if (c.id == null) continue;
        items.add(
          DropdownMenuItem<int?>(
            value: c.id,
            child: Text(_couponLabel(c), style: rubikRegular),
          ),
        );
      }
    }
    return items;
  }

  Future<void> _onCouponChanged(
    BuildContext context,
    int? id,
    List<CouponModel>? list,
  ) async {
    final couponProvider = context.read<CouponProvider>();
    if (id == null) {
      couponProvider.removeCouponData(true);
      return;
    }
    CouponModel? coupon;
    if (list != null) {
      for (final c in list) {
        if (c.id == id) {
          coupon = c;
          break;
        }
      }
    }
    if (coupon == null) return;
    final code = coupon.code ?? '';
    if (code.isEmpty) return;
    final discount = await couponProvider.applyCoupon(code, widget.totalAmount);
    if (!context.mounted) return;
    if ((discount ?? 0) > 0) {
      showCustomSnackBar(
        '${getTranslated('you_got', context)} ${PriceConverterHelper.convertPrice(discount)} ${getTranslated('discount', context)}',
        context,
        isError: false,
      );
    }
  }
}
