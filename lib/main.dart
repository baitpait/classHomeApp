import 'dart:async' show Future, unawaited;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:hexacom_user/common/models/notification_body.dart';
import 'package:hexacom_user/common/widgets/cookies_widget.dart';
import 'package:hexacom_user/common/widgets/global_whatsapp_fab_widget.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/auth/providers/registration_provider.dart';
import 'package:hexacom_user/features/auth/providers/verification_provider.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/contact_us/providers/contact_us_provider.dart';
import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:hexacom_user/features/track/providers/order_map_provider.dart';
import 'package:hexacom_user/helper/notification_helper.dart';
import 'package:hexacom_user/features/flash_sale/providers/flash_sale_provider.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/feature_flags.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hexacom_user/localization/app_localization.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/home/providers/banner_provider.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/features/chat/providers/chat_provider.dart';
import 'package:hexacom_user/features/coupon/providers/coupon_provider.dart';
import 'package:hexacom_user/features/loyalty/providers/loyalty_provider.dart';
import 'package:hexacom_user/provider/localization_provider.dart';
import 'package:hexacom_user/features/notification/providers/notification_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/provider/language_provider.dart';
import 'package:hexacom_user/features/onboarding/providers/onboarding_provider.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/search/providers/search_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:hexacom_user/theme/dark_theme.dart';
import 'package:hexacom_user/theme/light_theme.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:url_strategy/url_strategy.dart';
import 'di_container.dart' as di;

late AndroidNotificationChannel channel;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  final List<Future> initFutures = [di.init()];

  if (!FeatureFlags.skipFirebaseAndPush) {
    if(kIsWeb) {
      initFutures.add(Firebase.initializeApp(options: const FirebaseOptions(
          apiKey: "AIzaSyBCtDfdfPqxXDO6rDNlmQC1VJSHOtuyo3w",
          authDomain: "gem-b5006.firebaseapp.com",
          projectId: "gem-b5006",
          storageBucket: "gem-b5006.firebasestorage.app",
          messagingSenderId: "384321080318",
          appId: "1:384321080318:web:9cf2ec90f41dfb8a2c0eaf"
      )));

      if (!FeatureFlags.hideSocialLogin) {
        initFutures.add(FacebookAuth.instance.webAndDesktopInitialize(
          appId: "YOUR_APP_ID",
          cookie: true,
          xfbml: true,
          version: "v13.0",
        ));
      }

    } else {
      initFutures.add(Firebase.initializeApp().then((_) => FirebaseMessaging.instance.requestPermission()));
    }
  }
  await Future.wait(initFutures);
  if (!FeatureFlags.skipFirebaseAndPush) {
    try {
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

      if (!kIsWeb) {
        channel = const AndroidNotificationChannel(
          'hexacom',
          'High Importance Notifications',
          importance: Importance.high,
        );
      }
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Notification init failed: $e');
      }
    }
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => di.sl<ThemeProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<SplashProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<LanguageProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<OnBoardingProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<CategoryProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<BannerProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<LocalizationProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuthProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<RegistrationProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<VerificationProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<AddressProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<LocationProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<CartProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderMapProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<CheckoutProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<ChatProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProfileProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<NotificationProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<ContactUsProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<CouponProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<LoyaltyProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<WishListProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<SearchProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<FlashSaleProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<RateReviewProvider>()),
    ],
    child: const MyApp( isWeb: !kIsWeb),
  ));
}

class MyApp extends StatefulWidget {
  final NotificationBody? body;
  final bool isWeb;
  const MyApp({super.key, this.body, required this.isWeb});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Provider.of<SplashProvider>(context, listen: false).initSharedData();

    if(kIsWeb) {
      Provider.of<CartProvider>(context, listen: false).getCartData();
      Provider.of<SplashProvider>(context, listen: false).getPolicyPage();
      Provider.of<SplashProvider>(context, listen: false).getDeliveryInfo();
      _route();
    }

  }
  Future<void> _route() async {
    await Provider.of<SplashProvider>(context, listen: false).initConfig();
    if (!mounted) return;
    unawaited(
      Provider.of<LanguageProvider>(context, listen: false).syncLanguagesFromServer(),
    );
  }
  @override
  Widget build(BuildContext context) {
    List<Locale> locals = [];
    for (var language in AppConstants.languages) {
      locals.add(Locale(language.languageCode!, language.countryCode));
    }
    return Consumer4<SplashProvider, ThemeProvider, LocalizationProvider, LanguageProvider>(
      builder: (context, splashProvider, themeProvider, localizationProvider, _, child){
        final locale = localizationProvider.locale;
        final fontFamily = (locale.languageCode == 'ar' || locale.languageCode == 'he')
            ? AppConstants.fontFamilyArabic
            : AppConstants.fontFamily;
        final baseTheme = themeProvider.darkTheme ? dark : light;
        final theme = baseTheme.copyWith(
          textTheme: baseTheme.textTheme.apply(fontFamily: fontFamily),
          primaryTextTheme: baseTheme.primaryTextTheme.apply(fontFamily: fontFamily),
          inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
            labelStyle: baseTheme.inputDecorationTheme.labelStyle?.apply(fontFamily: fontFamily),
            hintStyle: baseTheme.inputDecorationTheme.hintStyle?.apply(fontFamily: fontFamily),
            floatingLabelStyle: baseTheme.inputDecorationTheme.floatingLabelStyle?.apply(fontFamily: fontFamily),
            errorStyle: baseTheme.inputDecorationTheme.errorStyle?.apply(fontFamily: fontFamily),
          ),
        );
        if (kIsWeb && splashProvider.configModel == null) {
          final themeData = theme;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: themeData.scaffoldBackgroundColor,
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 220,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 6,
                              backgroundColor: themeData.dividerColor.withValues(alpha: 0.25),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                themeData.primaryColor.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return MaterialApp.router(
          //routerConfig: RouteHelper.goRoutes,
          routerDelegate: RouteHelper.goRoutes.routerDelegate,
          routeInformationParser: RouteHelper.goRoutes.routeInformationParser,
          routeInformationProvider: RouteHelper.goRoutes.routeInformationProvider,
          title: splashProvider.configModel != null ? splashProvider.configModel!.ecommerceName ?? '' : 'Elite Vape',
          debugShowCheckedModeBanner: false,
          theme: theme,
          locale: locale,
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: locals,
          scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {
            PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown
          }),
          builder: (context, widget)=> MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
            child: Material(child: SafeArea(
              top: false,
              child: Stack(children: [
                widget!,

                if(kIsWeb && splashProvider.configModel!.cookiesManagement != null &&
                    splashProvider.configModel!.cookiesManagement!.status!
                    && !splashProvider.getAcceptCookiesStatus(splashProvider.configModel!.cookiesManagement!.content)
                    && splashProvider.cookiesShow)
                  const Positioned.fill(child: Align(alignment: Alignment.bottomCenter, child: CookiesWidget())),

                GlobalWhatsappFabOverlay(
                  routeChangeListenable: RouteHelper.goRoutes.routerDelegate,
                ),

              ]),
            )),
          ),
        );
      },

    );
  }
}

class Get {
  static BuildContext? get context => navigatorKey.currentContext;
  static NavigatorState? get navigator => navigatorKey.currentState;
}