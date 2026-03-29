import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:hexacom_user/common/models/attribute_model.dart';
import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/common/models/tag_model.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_debounce_widget.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/features/search/widgets/price_text_field.dart';
import 'package:hexacom_user/features/search/providers/search_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


class ProductFilterBottomSheetWidget extends StatefulWidget {
  final VoidCallback onSubmitTap;
  final VoidCallback onClearTap;
  final double? sliderMax;
  final double? sliderMin;
  final double? searchMaxPrice;
  final double? searchMinPrice;
  final bool canFiltered;
  final List<TagModel>? tagList;
  final List<AttributeModel>? attributeList;
  final bool showCloseButton;
  final bool autoApply;
  final bool scrollContent;
  const ProductFilterBottomSheetWidget({
    super.key,
    required this.onClearTap,
    required this.onSubmitTap,
    required this.sliderMax,
    required this.sliderMin,
    required this.searchMaxPrice,
    required this.searchMinPrice,
    required this.canFiltered,
    this.tagList,
    this.attributeList,
    this.showCloseButton = true,
    this.autoApply = false,
    this.scrollContent = true,
  });

  @override
  State<ProductFilterBottomSheetWidget> createState() => _ProductFilterBottomSheetWidgetState();
}

class _ProductFilterBottomSheetWidgetState extends State<ProductFilterBottomSheetWidget> {
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  double sliderMax = 1;
  double sliderMin = 0;
  final CustomDebounceWidget customDebounceWidget = CustomDebounceWidget(milliseconds: 1500);
  final CustomDebounceWidget _autoApplyDebounce = CustomDebounceWidget(milliseconds: 500);
  List<CategoryModel> categoryList = [];
  bool _isSeeMoreShow = false;

  void _autoApply() {
    if (!widget.autoApply) return;
    if (!widget.canFiltered) return;
    _autoApplyDebounce.run(widget.onSubmitTap);
  }

  @override
  void initState() {
    SearchProvider searchProvider = Provider.of<SearchProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    sliderMax =  widget.sliderMax ??  1;
    sliderMin =  widget.sliderMin ?? 0;
    searchProvider.setLowerAndUpperValue(widget.searchMinPrice ?? sliderMin, widget.searchMaxPrice ?? sliderMax, isUpdate: false);
    categoryList = categoryProvider.categoryList ?? [];
    if (categoryProvider.categoryList == null || categoryProvider.categoryList!.isEmpty) {
      categoryProvider.getCategoryList(false);
    }
    _isSeeMoreShow = categoryList.length > 5;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
        builder: (context, searchProvider, child){
          final categories = Provider.of<CategoryProvider>(context).categoryList ?? categoryList;
          final showSeeMore = _isSeeMoreShow && categories.length > 5;
          final double minPrice = searchProvider.lowerValue ?? 0;
          final double maxPrice = searchProvider.upperValue ?? 1;
          minPriceController.text = minPrice.toStringAsFixed(2);
          maxPriceController.text = maxPrice.toStringAsFixed(2);

          return Container(
            constraints: widget.showCloseButton
                ? BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.95)
                : const BoxConstraints(),
            height: (widget.showCloseButton && ResponsiveHelper.isWeb())
                ? MediaQuery.sizeOf(context).height * 0.55
                : null,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                // When embedded in a desktop sidebar we already wrap it with an outer card border.
                // Keep the internal border only for bottom-sheet/dialog usage.
                border: (ResponsiveHelper.isWeb() && widget.showCloseButton)
                    ? Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.3))
                    : null,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  widget.showCloseButton ? const SizedBox() : const SizedBox(width: 18),

                  Text(
                    getTranslated('filters', context),
                    textAlign: TextAlign.center,
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: ColorResources.getGreyBunkerColor(context),
                    ),
                  ),

                  if (widget.showCloseButton)
                    InkWell(
                      onTap: ()=> Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: Icon(Icons.close, size: 18, color: Theme.of(context).disabledColor),
                      ),
                    )
                  else
                    const SizedBox(width: 18),

                ]),
              ),

              Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              if (widget.scrollContent)
                Flexible(child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _filterBody(context, searchProvider, categories, showSeeMore, minPrice, maxPrice),
                  ]),
                ))
              else
                _filterBody(context, searchProvider, categories, showSeeMore, minPrice, maxPrice),

              if (!widget.autoApply)
                Container(
                  padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withValues(alpha: 0.1), blurRadius: 10)]
                  ),
                  child: Row(children: [
                    Flexible(child: CustomButtonWidget(
                      backgroundColor: Theme.of(context).hintColor.withValues(alpha: 0.2),
                      style: TextStyle(color: ColorResources.getTextColor(context)),
                      onTap: widget.onClearTap,
                      btnTxt: getTranslated('clear_filter', context),
                    )),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Flexible(child: CustomButtonWidget(
                      onTap: widget.canFiltered ? widget.onSubmitTap : null,
                      btnTxt: getTranslated('filter', context),
                    )),
                  ]),
                )

            ]),
          );
        });
  }

  Widget _filterBody(
    BuildContext context,
    SearchProvider searchProvider,
    List<CategoryModel> categories,
    bool showSeeMore,
    double minPrice,
    double maxPrice,
  ) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(getTranslated('in_stock_only', context), style: rubikBold),
                        Switch(
                          value: searchProvider.inStockOnly,
                          onChanged: (v) {
                            searchProvider.setInStockOnly(v);
                            _autoApply();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Text(getTranslated('price_range', context), style: rubikBold),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: FlutterSlider(
                      values: [minPrice, maxPrice],
                      rangeSlider: true,
                      max: sliderMax,
                      min: sliderMin,
                      handlerHeight: 25,
                      handlerWidth: 25,
                      trackBar: FlutterSliderTrackBar(activeTrackBar: BoxDecoration(color: Theme.of(context).primaryColor), activeTrackBarHeight: 6),
                      handler: FlutterSliderHandler(
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                        child: Container(
                          height: Dimensions.paddingSizeSmall, width: Dimensions.paddingSizeSmall,
                          decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                        ),
                      ),
                      rightHandler: FlutterSliderHandler(
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                        child: Container(
                          height: Dimensions.paddingSizeSmall, width: Dimensions.paddingSizeSmall,
                          decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                        ),
                      ),
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        searchProvider.setLowerAndUpperValue(lowerValue, upperValue);
                        _autoApply();
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Flexible(child: PriceTextFieldWidget(
                        controller: minPriceController,
                        borderColor: Theme.of(context).hintColor.withValues(alpha: .5),
                        inputType: TextInputType.number,
                        isShowBorder: true,
                        hintText: getTranslated('enter_min_price', context),
                        prefixText: getTranslated('min_price', context),
                        maxLines: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')), // Allow only digits
                        ],
                        onChanged: (String text) {

                          final double tempMinPrice = double.tryParse(minPriceController.text) ?? 0;
                          final double tempMaxPrice = double.tryParse(maxPriceController.text) ?? 0;

                          customDebounceWidget.run((){
                            if(tempMinPrice >= sliderMin && tempMinPrice < tempMaxPrice) {
                              if(tempMinPrice >= tempMaxPrice){
                                searchProvider.setLowerAndUpperValue(sliderMax, tempMaxPrice);
                              }else{
                                searchProvider.setLowerAndUpperValue(tempMinPrice, tempMaxPrice);
                              }
                            }else {
                              searchProvider.setLowerAndUpperValue(sliderMin, sliderMax);
                            }
                            _autoApply();
                          });
                        },
                      )),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Flexible(child: PriceTextFieldWidget(
                        controller: maxPriceController,
                        borderColor: Theme.of(context).hintColor.withValues(alpha: .5),
                        inputType: TextInputType.number,
                        isShowBorder: true,
                        maxLines: 1,
                        hintText: getTranslated('enter_max_price', context),
                        prefixText: getTranslated('max_price', context),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')), // Allow only digits
                        ],
                        onChanged: (String text) {

                          final double tempMinPrice = double.tryParse(minPriceController.text) ?? 0;
                          final double tempMaxPrice = double.tryParse(maxPriceController.text) ?? 0;

                          customDebounceWidget.run((){
                            if(tempMaxPrice <= sliderMax && tempMinPrice < tempMaxPrice) {
                              if(tempMaxPrice <= sliderMin){
                                searchProvider.setLowerAndUpperValue(tempMinPrice, sliderMin);
                              }else{
                                searchProvider.setLowerAndUpperValue(tempMinPrice, tempMaxPrice);
                              }

                            }else {
                              searchProvider.setLowerAndUpperValue(sliderMin, sliderMax);
                            }
                            _autoApply();
                          });
                        },
                      ))
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Text(getTranslated('shorting', context), style: rubikBold),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: ListView.builder(
                        itemCount: SearchShortBy.values.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, index){
                          return InkWell(
                            onTap: (){
                              searchProvider.setSelectShortBy(SearchShortBy.values[index]);
                              _autoApply();
                            },
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(getTranslated(SearchShortBy.values[index].name, context), style: rubikRegular),

                              Radio(
                                  value: SearchShortBy.values[index],
                                  groupValue: searchProvider.selectedSearchShotBy,
                                  onChanged: (v){
                                    searchProvider.setSelectShortBy(SearchShortBy.values[index]);
                                    _autoApply();
                                },
                              )
                            ]),
                          );
                        }
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  if (widget.tagList != null && widget.tagList!.isNotEmpty) ...[
                    Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Text(getTranslated('tags', context), style: rubikBold),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.tagList!.map((tag) {
                          final selected = searchProvider.selectedTagIds.contains(tag.id);
                          return FilterChip(
                            label: Text(tag.name ?? '${tag.id}'),
                            selected: selected,
                            onSelected: (_) {
                              searchProvider.toggleTag(tag.id);
                              _autoApply();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],

                  if (widget.attributeList != null && widget.attributeList!.isNotEmpty) ...[
                    Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Text(getTranslated('attributes', context), style: rubikBold),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.attributeList!.map((attr) {
                          final selected = searchProvider.selectedAttributeIds.contains(attr.id);
                          return FilterChip(
                            label: Text(attr.name ?? '${attr.id}'),
                            selected: selected,
                            onSelected: (_) {
                              searchProvider.toggleAttribute(attr.id);
                              _autoApply();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],

                  Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Text(getTranslated('categories', context), style: rubikBold),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: ListView.builder(
                        itemCount: showSeeMore ? 5 : categories.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, index){
                          final category = categories[index];
                          final categoryId = category.id;
                          if (categoryId == null) return const SizedBox.shrink();
                          return InkWell(
                            onTap: (){
                              searchProvider.selectCategoryListAdd(categoryId);
                              _autoApply();
                            },
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('${category.name}', style: rubikRegular),

                              Checkbox(
                                  value: searchProvider.selectCategoryList.contains(categoryId),
                                  checkColor: Theme.of(context).cardColor,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (value){
                                    searchProvider.selectCategoryListAdd(categoryId);
                                    _autoApply();
                                  }
                              ),
                            ]),
                          );
                        }
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  if(showSeeMore)...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Center(
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              _isSeeMoreShow = false;
                            });
                          },
                          child: Text(
                              '${getTranslated('see_more', context)} (${categories.length - 5})',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: ColorResources.getIndicatorColor(context),
                                decorationColor: ColorResources.getIndicatorColor(context)
                              )
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall)
                  ],

                  Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Text(getTranslated('rating', context), style: rubikBold),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: ListView.builder(
                      itemCount: 6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, index) {
                        // index 0 => "0" (no rating filter; includes unrated products)
                        final ratingValue = index == 0 ? -1 : (index - 1);
                        final stars = ratingValue == -1 ? 0 : (ratingValue + 1);
                        final selected = searchProvider.rating == ratingValue;
                        return InkWell(
                          onTap: () {
                            searchProvider.setRating(ratingValue);
                            _autoApply();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                                      size: 18,
                                      color: i < stars ? Colors.amber.shade700 : Theme.of(context).hintColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      stars == 0
                                          ? '0'
                                          : (stars == 5 ? '5' : '$stars+'),
                                      style: rubikRegular.copyWith(
                                        color: selected ? Theme.of(context).primaryColor : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Radio(
                                      value: ratingValue,
                                      groupValue: searchProvider.rating,
                                      onChanged: (v) {
                                        searchProvider.setRating(v ?? -1);
                                        _autoApply();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
    ]);
  }
}

