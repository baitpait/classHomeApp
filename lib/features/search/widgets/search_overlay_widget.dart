import 'package:flutter/material.dart';
import 'package:hexacom_user/common/widgets/highlighted_text_widget.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/features/search/providers/search_provider.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class SearchOverlayWidget extends StatelessWidget {
  const SearchOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)
      ),
      child: Consumer<SearchProvider>(builder: (context, searchProvider, child)=> Column(children: [
        if(searchProvider.searchController.text.isEmpty)...[
          if(searchProvider.historyList.isNotEmpty) Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
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
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: ListView.builder(
              itemCount: searchProvider.historyList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Row(children: [
                  Expanded(
                    child: InkWell(
                      onTap: ()=> RouteHelper.getSearchResultRoute(context, text: searchProvider.historyList[index], action: RouteAction.push),
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
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
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

        if(searchProvider.searchController.text.isNotEmpty)...[
          Expanded(flex: 1, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: ListView.builder(
              itemCount: searchProvider.productSuggestionModel?.products?.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    searchProvider.saveSearchAddress(searchProvider.productSuggestionModel?.products?[index].name ?? '');
                    searchProvider.setSearchText(searchProvider.productSuggestionModel?.products?[index].name ?? '');
                    RouteHelper.getSearchResultRoute(context, text: searchProvider.productSuggestionModel?.products?[index].name, action: RouteAction.push);

                  },
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Row(children: [
                      Icon(Icons.history, size: 20, color: Theme.of(context).hintColor),
                      const SizedBox(width: 13),

                      Expanded(
                        child: HighlightedTextWidget(
                          text: searchProvider.productSuggestionModel?.products?[index].name ?? '',
                          searchQuery: searchProvider.searchController.text,
                          baseStyle: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: ColorResources.getTextColor(context)),
                        ),
                      ),

                      Transform.rotate(
                        angle: -45,
                        child: Icon(Icons.arrow_upward, size: 20, color: Theme.of(context).hintColor.withValues(alpha: 0.4)),
                      )
                    ]),
                  ),
                );
              },
            ),
          )),
        ]
      ])),
    );
  }
}
