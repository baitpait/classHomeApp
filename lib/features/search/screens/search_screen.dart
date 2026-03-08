
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_debounce_widget.dart';
import 'package:hexacom_user/common/widgets/highlighted_text_widget.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/search/providers/search_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CustomDebounceWidget debounceWidget = CustomDebounceWidget(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    Provider.of<SearchProvider>(context, listen: false).getHistoryList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final double horizontalPadding = isMobile ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge;
    final EdgeInsets searchFieldPadding = isMobile
        ? const EdgeInsets.symmetric(vertical: 12, horizontal: 16)
        : const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: 22);

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const CustomAppBarWidget() : null,
      body: SafeArea(child: Center(child: SizedBox(
        width: Dimensions.webScreenWidth,
        child: Consumer<SearchProvider>(
          builder: (context, searchProvider, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isMobile ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
                            border: Border.all(
                              color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(isMobile ? 12 : 40),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(isMobile ? 12 : 40),
                            child: CustomTextFieldWidget(
                              contentPadding: searchFieldPadding,
                              fillColor: Colors.transparent,
                              hintText: getTranslated('search_for_products', context),
                              isShowPrefixIcon: true,
                              isSearch: true,
                              prefixAssetImageColor: Theme.of(context).primaryColor,
                              prefixAssetUrl: Images.search,
                              onSuffixTap: () {
                                if (_searchController.text.isNotEmpty) {
                                  searchProvider.saveSearchAddress(_searchController.text);
                                  RouteHelper.getSearchResultRoute(
                                    context,
                                    text: _searchController.text,
                                    action: RouteAction.pushReplacement,
                                  );
                                }
                              },
                              controller: _searchController,
                              inputAction: TextInputAction.search,
                              isIcon: true,
                              onChanged: (text) {
                                debounceWidget.run(() {
                                  searchProvider.getSuggestionList(text);
                                });
                              },
                              onSubmit: (text) {
                                if (_searchController.text.isNotEmpty) {
                                  searchProvider.saveSearchAddress(_searchController.text);
                                  RouteHelper.getSearchResultRoute(
                                    context,
                                    text: _searchController.text,
                                    action: RouteAction.pushReplacement,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? Dimensions.paddingSizeExtraSmall : 0),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.close,
                              color: Theme.of(context).disabledColor,
                              size: isMobile ? 22 : 25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isMobile ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault),

              if(_searchController.text.isEmpty)...[
                if(searchProvider.historyList.isNotEmpty) Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated('recent_search', context),
                        style: rubikMedium,
                      ),

                      searchProvider.historyList.isNotEmpty
                          ? TextButton(
                          onPressed: searchProvider.clearSearchAddress,
                          child: Text(
                            getTranslated('clear_all', context),
                            style: rubikRegular.copyWith(color: Theme.of(context).colorScheme.error),
                          ))
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),

                if(searchProvider.historyList.isNotEmpty)
                  Expanded(flex: 1, child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: ListView.builder(
                    itemCount: searchProvider.historyList.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Row(children: [
                        Expanded(
                          child: InkWell(
                            onTap: ()=> RouteHelper.getSearchResultRoute(context, text: searchProvider.historyList[index], action: RouteAction.pushReplacement),
                            child: Row(children: [
                              Icon(Icons.history, size: 20, color: Theme.of(context).hintColor),
                              const SizedBox(width: 13),

                              Expanded(
                                child: Text(
                                  searchProvider.historyList[index],
                                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ]),
                          ),
                        ),

                        InkWell(
                          onTap: ()=> searchProvider.removeSearchAddressByName(searchProvider.historyList[index]),
                          child: Icon(Icons.clear, size: 20, color: Theme.of(context).hintColor),
                        ),
                      ]),
                    ),
                  ),
                )),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Expanded(flex: 2, child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Dimensions.paddingSizeSmall, children: [
                    Text(getTranslated('popular_categories', context), style: rubikMedium),

                    Wrap(
                      children: Provider.of<CategoryProvider>(context, listen: false).popularCategoryModel!.map((categoryData) {
                        return Padding(
                          padding: EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeSmall),
                          child: InkWell(
                            onTap: ()=> RouteHelper.getCategoryRoute(context, categoryData),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.1)),
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                              ),
                              child: Text(categoryData.name ?? ''),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  ]),
                ))
              ],

              if(_searchController.text.isNotEmpty)...[
                Expanded(flex: 1, child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: ListView.builder(
                    itemCount: searchProvider.productSuggestionModel?.products?.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          searchProvider.saveSearchAddress(searchProvider.productSuggestionModel?.products?[index].name ?? '');
                          searchProvider.setSearchText(searchProvider.productSuggestionModel?.products?[index].name ?? '');
                          RouteHelper.getSearchResultRoute(context, text: searchProvider.productSuggestionModel?.products?[index].name, action: RouteAction.pushReplacement);

                        },
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            Icon(Icons.history, size: 20, color: Theme.of(context).hintColor),
                            const SizedBox(width: 13),

                            Expanded(
                              child: HighlightedTextWidget(
                                text: searchProvider.productSuggestionModel?.products?[index].name ?? '',
                                searchQuery: _searchController.text,
                                baseStyle: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: ColorResources.getTextColor(context)),
                              ),
                            ),

                            Transform.rotate(
                              angle: -45,
                              child: Icon(Icons.arrow_upward, size: 20, color: Theme.of(context).hintColor.withValues(alpha: 0.4)),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                )),
              ]
            ],
          ),
        ),
      ))),
    );
  }
}
