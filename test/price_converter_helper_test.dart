import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/product_model.dart' as product_model;
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/main.dart';

class _FakeSplashProvider extends SplashProvider {
  _FakeSplashProvider({required ConfigModel config}) : super(splashRepo: null) {
    _configModel = config;
  }

  // Hold a local config for overriding the getter
  ConfigModel? _configModel;
  @override
  ConfigModel? get configModel => _configModel;
}

void main() {
  late ConfigModel configLeft;
  late ConfigModel configRight;

  setUp(() {
    configLeft = ConfigModel(
      currencySymbol: '4', // '$'
      currencySymbolPosition: 'left',
    );
    configRight = ConfigModel(
      currencySymbol: '£',
      currencySymbolPosition: 'right',
    );
  });

  Widget wrapWithProviders({required Widget child, required ConfigModel config}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SplashProvider>(
          create: (_) => _FakeSplashProvider(config: config),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(body: child),
      ),
    );
  }

  group('PriceConverterHelper.convertPrice', () {
    testWidgets('applies amount discount and formats with left symbol', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        config: configLeft,
        child: const SizedBox.shrink(),
      ));

      final text = PriceConverterHelper.convertPrice(100.0, discount: 10.0, discountType: 'amount');
      // Expect left symbol and formatted price 90.00
      expect(text.startsWith('4 '), isTrue); // starts with '$ '
      expect(text.contains('90.00'), isTrue);
    });

    testWidgets('applies percent discount and formats with right symbol', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        config: configRight,
        child: const SizedBox.shrink(),
      ));

      final text = PriceConverterHelper.convertPrice(2000.0, discount: 10.0, discountType: 'percent');
      // 10% off -> 1800.00; verify thousands separator and symbol present
      expect(text.contains('1,800.00'), isTrue);
      expect(text.contains('£'), isTrue);
    });

    testWidgets('no discount keeps original value and formatting', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        config: configLeft,
        child: const SizedBox.shrink(),
      ));

      final text = PriceConverterHelper.convertPrice(12345.678);
      expect(text.contains('12,345.68'), isTrue);
    });
  });

  group('PriceConverterHelper.convertWithDiscount', () {
    test('amount discount returns value minus amount', () {
      final v = PriceConverterHelper.convertWithDiscount(50.0, 5.0, 'amount');
      expect(v, 45.0);
    });

    test('percent discount returns value minus percentage', () {
      final v = PriceConverterHelper.convertWithDiscount(80.0, 25.0, 'percent');
      expect(v, 60.0);
    });

    test('null discount type returns same value', () {
      final v = PriceConverterHelper.convertWithDiscount(80.0, 25.0, null);
      expect(v, 80.0);
    });
  });

  group('PriceConverterHelper.calculation', () {
    test('amount type multiplies discount by quantity', () {
      final c = PriceConverterHelper.calculation(100.0, 3.0, 'amount', 4);
      expect(c, 12.0);
    });

    test('percent type applies on amount * quantity', () {
      final c = PriceConverterHelper.calculation(200.0, 10.0, 'percent', 2);
      // 10% of (200 * 2) = 40
      expect(c, 40.0);
    });
  });

  group('PriceConverterHelper.percentageCalculation', () {
    testWidgets('shows % when discountType is percent', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        config: configLeft,
        child: const SizedBox.shrink(),
      ));

      final s = PriceConverterHelper.percentageCalculation(
        tester.element(find.byType(SizedBox)),
        100,
        15,
        'percent',
      );
      expect(s, '15.0% OFF');
    });

    testWidgets('shows currency symbol when discountType is amount', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        config: configRight,
        child: const SizedBox.shrink(),
      ));

      final s = PriceConverterHelper.percentageCalculation(
        tester.element(find.byType(SizedBox)),
        100,
        20,
        'amount',
      );
      expect(s.contains(configRight.currencySymbol!), isTrue);
      expect(s.endsWith(' OFF'), isTrue);
    });
  });

  group('PriceConverterHelper.getPriceRange', () {
    test('with variations returns sorted start and end price', () {
      final product = product_model.Product(
        price: 100,
        variations: [
          product_model.Variation(type: 'S', price: 120, stock: 1),
          product_model.Variation(type: 'M', price: 90, stock: 1),
          product_model.Variation(type: 'L', price: 200, stock: 1),
        ],
      );

      final range = PriceConverterHelper.getPriceRange(product);
      expect(range.startPrice, 90);
      expect(range.endPrice, 200);
    });

    test('without variations returns product price only', () {
      final product = product_model.Product(price: 75, variations: []);
      final range = PriceConverterHelper.getPriceRange(product);
      expect(range.startPrice, 75);
      expect(range.endPrice, isNull);
    });
  });
}
