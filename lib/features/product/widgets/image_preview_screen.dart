import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/widgets/custom_inkwell_widget.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class ImagePreviewScreen extends StatefulWidget {
  final List<String> images;
  final int selectedIndex;
  const ImagePreviewScreen({super.key, required this.images, required this.selectedIndex});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _currentPage = widget.selectedIndex;
    _pageController =  PageController(initialPage: widget.selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: isDesktop ? Colors.transparent : Colors.black,
      body: SafeArea(child: Stack(children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal:ResponsiveHelper.isDesktop(context) ? 110 : 0,vertical: 50),
          child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) async {
                setState(() {
                  _currentPage = i;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return PhotoView(
                  backgroundDecoration: BoxDecoration(color: isDesktop ? Colors.transparent : Colors.black),
                  tightMode: true,
                  imageProvider: CachedNetworkImageProvider('${Provider.of<SplashProvider>(context,listen: false).baseUrls?.reviewImageUrl}/${widget.images[index]}'),
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.images[index]),
                );
              }
          ),
        ),

        Positioned(top: 10, right: 0, child: IconButton(
          splashRadius: 5,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.clear, color: Colors.white),
        )),

        if(_isPreviousPageExist())
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color:Colors.white),
              ),
              margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
              child: CustomInkWellWidget(
                onTap: _previousPage,
                radius: 50,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Icon(Icons.arrow_back_ios, color:Colors.white),
              ),
            ),
          ),

        if (_isNextPageExist())
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color:Colors.white),
              ),
              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              child: CustomInkWellWidget(
                onTap: _nextPage,
                radius: 50,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Icon(Icons.arrow_forward_ios, color:Colors.white),
              ),
            ),
          ),

      ])),
    );
  }

  bool _isNextPageExist() => _currentPage < widget.images.length - 1;

  bool _isPreviousPageExist() => _currentPage > 0;

  void _nextPage() {
    if (_isNextPageExist()) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_isPreviousPageExist()) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }
}