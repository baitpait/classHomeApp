import 'package:hexacom_user/common/enums/product_filter_type_enum.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductFilterPopupWidget extends StatefulWidget {
  final bool isFilterActive;
  final Function(ProductFilterType) onSelected;
  /// Called when any filter (category, price, newest) is applied or reset. Use for the filter icon dot.
  final void Function(bool hasAnyActive)? onFilterStateChanged;
  const ProductFilterPopupWidget({
    super.key,
    required this.isFilterActive,
    required this.onSelected,
    this.onFilterStateChanged,
  });

  @override
  State<ProductFilterPopupWidget> createState() => _ProductFilterPopupWidgetState();
}

class _ProductFilterPopupWidgetState extends State<ProductFilterPopupWidget> {
  bool _expanded = false;
  ProductFilterType _lastPriceSort = ProductFilterType.highToLow;
  bool _isPriceActive = false;
  bool _isNewestActive = false;
  bool _isCategoryOpen = false;
  int? _selectedCategoryId;
  String? _selectedCategoryName;

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _handlePriceTap() {
    setState(() {
      _isPriceActive = true;
      _lastPriceSort = _lastPriceSort == ProductFilterType.highToLow
          ? ProductFilterType.lowToHigh
          : ProductFilterType.highToLow;
    });

    context.read<ProductProvider>().applyHomeFilters(
          categoryId: _selectedCategoryId,
          newestOnly: _isNewestActive,
          priceSort: _lastPriceSort,
        );

    widget.onFilterStateChanged?.call(true);
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label, {
    required VoidCallback onTap,
    IconData? trailingIcon,
    bool highlighted = false,
  }) {
    final accent = ColorResources.accentNavy;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
      child: Container(
        // Match the filter icon container height & stroke
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          color: highlighted ? accent : Colors.transparent,
          border: Border.all(color: accent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: rubikMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: highlighted ? Colors.white : accent.withValues(alpha: 0.9),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 4),
              Icon(trailingIcon, size: 14, color: highlighted ? Colors.white : accent),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = ColorResources.accentNavy;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                  border: Border.all(color: accent),
                ),
                child: Icon(Icons.filter_list,
                    color: accent, size: Dimensions.paddingSizeLarge),
              ),
            ),
            if (widget.isFilterActive)
              Positioned(
                top: 8,
                right: 7,
                child: Container(
                  height: 10,
                  width: 10,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        if (_expanded) ...[
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            _selectedCategoryName ??
                getTranslated('category', context),
            trailingIcon: _isCategoryOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            onTap: () async {
              setState(() {
                _isCategoryOpen = true;
              });

              final categoryProvider = context.read<CategoryProvider>();
              if (categoryProvider.categoryList == null ||
                  categoryProvider.categoryList!.isEmpty) {
                await categoryProvider.getCategoryList(true);
              }

              final categories = (categoryProvider.categoryList ?? [])
                  .where((c) => c.hasProductsForStoreDisplay)
                  .toList();
              if (!mounted || categories.isEmpty) {
                setState(() {
                  _isCategoryOpen = false;
                });
                return;
              }

              final selected = await showModalBottomSheet<int>(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (ctx) {
                  return Container(
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final item = categories[index];
                        return ListTile(
                          title: Text(
                            item.name ?? '',
                            style: rubikMedium,
                          ),
                          onTap: () => Navigator.pop(ctx, item.id),
                        );
                      },
                    ),
                  );
                },
              );

              if (!mounted) return;

              setState(() {
                _isCategoryOpen = false;
              });

              if (selected != null) {
                final selectedCategory =
                    categories.firstWhere((c) => c.id == selected);
                setState(() {
                  _selectedCategoryId = selected;
                  _selectedCategoryName = selectedCategory.name;
                });
                context.read<ProductProvider>().applyHomeFilters(
                      categoryId: _selectedCategoryId,
                      newestOnly: _isNewestActive,
                      priceSort: _isPriceActive ? _lastPriceSort : null,
                    );
                widget.onFilterStateChanged?.call(true);
              }
            },
            highlighted: _selectedCategoryId != null,
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            context,
            getTranslated('price', context),
            onTap: _handlePriceTap,
            trailingIcon: _lastPriceSort == ProductFilterType.highToLow
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            highlighted: _isPriceActive,
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            context,
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'الأحدث'
                : getTranslated('new', context),
            onTap: () {
              setState(() {
                _isNewestActive = !_isNewestActive;
              });

              context
                  .read<ProductProvider>()
                  .applyHomeFilters(
                    categoryId: _selectedCategoryId,
                    newestOnly: _isNewestActive,
                    priceSort: _isPriceActive ? _lastPriceSort : null,
                  );
              final anyActive =
                  _selectedCategoryId != null || _isPriceActive || _isNewestActive;
              widget.onFilterStateChanged?.call(anyActive);
            },
            trailingIcon: _isNewestActive ? Icons.arrow_downward : Icons.arrow_upward,
            highlighted: _isNewestActive,
          ),
        if (_selectedCategoryId != null || _isPriceActive || _isNewestActive) ...[
          const SizedBox(width: 6),
          _buildFilterChip(
            context,
            (getTranslated('reset', context).isEmpty ? (Localizations.localeOf(context).languageCode == 'ar' ? 'إعادة' : 'Reset') : getTranslated('reset', context)),
            onTap: () {
              setState(() {
                _selectedCategoryId = null;
                _selectedCategoryName = null;
                _isPriceActive = false;
                _isNewestActive = false;
              });
              context.read<ProductProvider>().applyHomeFilters(
                    categoryId: null,
                    newestOnly: false,
                    priceSort: null,
                  );
              widget.onFilterStateChanged?.call(false);
            },
            trailingIcon: Icons.clear,
            highlighted: false,
          ),
        ],
        ],
      ],
    );
  }
}
