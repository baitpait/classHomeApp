import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/onboarding/providers/onboarding_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatefulWidget {

  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {

    _pageController.addListener((){
      if(_pageController.offset > ((context.size?.width ?? 0) * 2)){
        RouteHelper.getWelcomeRoute(context, action: RouteAction.pushReplacement);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<OnBoardingProvider>(context, listen: false).initBoardingList(context);
    Size size = MediaQuery.sizeOf(context);

    return CustomPopScopeWidget(
      child: Scaffold(
        body: Consumer<OnBoardingProvider>(
          builder: (context, onBoardingList, child) => onBoardingList.onBoardingList.isNotEmpty ?
          SafeArea(child: Column(children: [
            onBoardingList.selectedIndex != onBoardingList.onBoardingList.length-1 ?
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                  onTap: () {
                    onBoardingList.toggleShowOnBoardingStatus();
                    RouteHelper.getWelcomeRoute(context, action: RouteAction.pushReplacement);
                    },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    margin: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)
                    ),
                    child: Text(
                      getTranslated('skip', context),
                      style: rubikRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                  ),
              ),
            ) :
            const SizedBox(),

            Expanded(
              child: PageView.builder(
                itemCount: onBoardingList.onBoardingList.length,
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(children: [
                    SizedBox(
                      height: 400,
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Image.asset(onBoardingList.onBoardingList[index].imageUrl),
                      ),
                    ),

                    Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 60, right: 60, top: 0, bottom: 22),
                        child: Text(
                          onBoardingList.selectedIndex == 0 ?
                          onBoardingList.onBoardingList[0].title :
                          onBoardingList.selectedIndex == 1 ?
                          onBoardingList.onBoardingList[1].title :
                          onBoardingList.onBoardingList[2].title,
                          style: rubikSemiBold.copyWith(fontSize: 24.0, color: Theme.of(context).textTheme.bodyLarge!.color),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: Text(
                          onBoardingList.selectedIndex == 0 ?
                          onBoardingList.onBoardingList[0].description :
                          onBoardingList.selectedIndex == 1 ?
                          onBoardingList.onBoardingList[1].description :
                          onBoardingList.onBoardingList[2].description,
                          style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: ColorResources.getGrayColor(context)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Row(mainAxisAlignment: MainAxisAlignment.center, children: _getIndexList(onBoardingList.onBoardingList.length).map((i) => Container(
                        width: i == Provider.of<OnBoardingProvider>(context).selectedIndex ? 16 : 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: i == Provider.of<OnBoardingProvider>(context).selectedIndex ? Theme.of(context).primaryColor : ColorResources.getGrayColor(context),
                          borderRadius: i == Provider.of<OnBoardingProvider>(context).selectedIndex ? BorderRadius.circular(50) : BorderRadius.circular(25),
                        ),
                      )).toList()),

                    ]),
                  ]);
                  },
                onPageChanged: (index) {
                  onBoardingList.changeSelectIndex(index);
                  },
              ),
            ),

            Container(
              padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                onBoardingList.selectedIndex == 0 ?
                const SizedBox.shrink() :
                InkWell(
                  onTap: () {
                    _pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.ease);
                  },
                  child: Container(
                    width: size.width * 0.4, height: size.height * 0.04,
                    decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault)
                    ),
                    child: Center(child: Text(
                      getTranslated('previous', context),
                      style: rubikRegular,
                    )),
                  ),
                ),


                InkWell(
                  onTap: () {
                    if(onBoardingList.selectedIndex == 2){
                      RouteHelper.getWelcomeRoute(context, action: RouteAction.pushReplacement);
                    }else{
                      _pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.ease);
                    }

                  },
                  child: Container(
                    width: size.width * 0.4, height: size.height * 0.04,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault)
                    ),
                    child: Center(child: Text(
                      getTranslated(onBoardingList.selectedIndex == 2 ? 'lets_start' : 'next', context),
                      style: rubikRegular.copyWith(color: Theme.of(context).cardColor),
                    )),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge)

          ])) :
          const SizedBox(),
        ),
      ),
    );
  }

  List<int> _getIndexList(int length) {
    List<int> list = [];

    for(int i = 0; i < length; i++) {
      list.add(i);
    }

    return list;
  }
}


