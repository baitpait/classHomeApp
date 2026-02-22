import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:hexacom_user/common/models/category_model.dart';
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
  const ProductFilterBottomSheetWidget({
    super.key, required this.onClearTap, required this.onSubmitTap,
    required this.sliderMax, required this.sliderMin, required this.searchMaxPrice,
    required this.searchMinPrice, required this.canFiltered
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
  List<CategoryModel> categoryList = [];
  bool _isSeeMoreShow = false;

  @override
  void initState() {
    SearchProvider searchProvider = Provider.of<SearchProvider>(context, listen: false);
    sliderMax =  widget.sliderMax ??  1;
    sliderMin =  widget.sliderMin ?? 0;
    searchProvider.setLowerAndUpperValue(widget.searchMinPrice ?? sliderMin, widget.searchMaxPrice ?? sliderMax, isUpdate: false);
    categoryList = Provider.of<CategoryProvider>(context, listen: false).categoryList ?? [];
    _isSeeMoreShow = categoryList.length > 5 ? true : false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
        builder: (context, searchProvider, child){
          final double minPrice = searchProvider.lowerValue ?? 0;
          final double maxPrice = searchProvider.upperValue ?? 1;
          minPriceController.text = minPrice.toStringAsFixed(2);
          maxPriceController.text = maxPrice.toStringAsFixed(2);

          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.95),
            height: ResponsiveHelper.isWeb() ? MediaQuery.of(context).size.height * 0.55 : null,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                border: ResponsiveHelper.isWeb() ? Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.3)) : null,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const SizedBox(),

                  Text(
                    getTranslated('filter', context),
                    textAlign: TextAlign.center,
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: ColorResources.getGreyBunkerColor(context),
                    ),
                  ),

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
                  ),

                ]),
              ),

              Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Flexible(child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                        hintText: 'enter_min_price',
                        prefixText: 'min_price',
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
                        hintText: 'enter_max_price',
                        prefixText: 'max_price',
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
                    child: Text(getTranslated('rating', context), style: rubikBold),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: ListView.builder(
                        itemCount: 5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, index){
                          return InkWell(
                            onTap: ()=> searchProvider.setRating(index),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('${index +1 }${index != 4 ? '+' : '  '} ${getTranslated('rating', context)}', style: rubikRegular),

                              Radio(
                                  value: index,
                                  groupValue: searchProvider.rating,
                                  onChanged: (v){
                                    searchProvider.setRating(v ?? 0);
                                  }
                              )
                            ]),
                          );
                        }
                    ),
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
                            onTap: ()=> searchProvider.setSelectShortBy(SearchShortBy.values[index]),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(getTranslated(SearchShortBy.values[index].name, context), style: rubikRegular),

                              Radio(
                                  value: SearchShortBy.values[index],
                                  groupValue: searchProvider.selectedSearchShotBy,
                                  onChanged: (v){
                                    searchProvider.setSelectShortBy(SearchShortBy.values[index]);
                                },
                              )
                            ]),
                          );
                        }
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

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
                        itemCount: _isSeeMoreShow ? 5 : categoryList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, index){
                          return InkWell(
                            onTap: ()=> searchProvider.selectCategoryListAdd(categoryList[index].id!),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('${categoryList[index].name}', style: rubikRegular),

                              Checkbox(
                                  value: searchProvider.selectCategoryList.contains(categoryList[index].id!),
                                  checkColor: Theme.of(context).cardColor,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (value){
                                    searchProvider.selectCategoryListAdd(categoryList[index].id!);
                                  }
                              ),
                            ]),
                          );
                        }
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  if(_isSeeMoreShow)...[
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
                              '${getTranslated('see_more', context)} (${categoryList.length - 5})',
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
                ]),
              )),

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
}

