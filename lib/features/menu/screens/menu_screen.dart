import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/menu/widgets/menu_mobile_content.dart';
import 'package:hexacom_user/features/menu/widgets/menu_web_widget.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/provider/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  @override
  void initState() {
    Provider.of<LanguageProvider>(context, listen: false).initializeAllLanguages(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const CustomAppBarWidget() : null,
      body: Consumer<ProfileProvider>(
          builder: (ctx, userController, _) {
            final bool isLoggedIn = authProvider.isLoggedIn();
            return ResponsiveHelper.isDesktop(context) ? MenuWebWidget(isLoggedIn: isLoggedIn) : const MenuMobileContent();
          }
      ),
    );
  }
}
