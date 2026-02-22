import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';

class CategoryItemWidget extends StatelessWidget {
  final String? title;
  final String? icon;
  final bool isSelected;

  const CategoryItemWidget({super.key, required this.title, required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 110,
      decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor
      ),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(
            height: 60,
            width: 60,
            alignment: Alignment.center,
            //padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withValues(alpha: 0.1)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CustomImageWidget(
                image: '$icon',
                fit: BoxFit.cover, width: 100, height: 100,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            child: Text(title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: rubikRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: isSelected ? Theme.of(context).canvasColor : Theme.of(context).textTheme.bodyLarge?.color
                )),
          ),
        ]),
      ),
    );
  }
}
