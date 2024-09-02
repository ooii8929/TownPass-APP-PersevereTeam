import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/service/account_service.dart';
import 'package:town_pass/service/device_service.dart';
import 'package:town_pass/service/geo_locator_service.dart';
import 'package:town_pass/service/package_service.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/service/shared_preferences_service.dart';
import 'package:town_pass/service/speech_to_text_service.dart'; // 导入 WifiInfoService
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(
  //   widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  // );

  developer.log('Application started'); // 添加日志记录

  await initServices();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // 初始化 WifiInfoService 并打印 WiFi 信息
  developer.log('Initializing WifiInfoService'); // 添加日志记录
  final wifiInfoService = await Get.putAsync(() => WifiInfoService().init());
  developer.log('WiFiInfoService initialized'); // 添加日志记录
  developer.log('WiFi Name: ${wifiInfoService.wifiName}');
  developer.log('WiFi BSSID: ${wifiInfoService.wifiBSSID}');
  developer.log('WiFi IPv4: ${wifiInfoService.wifiIPv4}');
  developer.log('WiFi IPv6: ${wifiInfoService.wifiIPv6}');
  developer.log('WiFi Gateway IP: ${wifiInfoService.wifiGatewayIP}');
  developer.log('WiFi Broadcast: ${wifiInfoService.wifiBroadcast}');
  developer.log('WiFi Submask: ${wifiInfoService.wifiSubmask}');

  runApp(const MyApp());
}

Future<void> initServices() async {
  developer.log('Initializing services'); // 添加日志记录
  await Get.putAsync<AccountService>(() async => await AccountService().init());
  await Get.putAsync<DeviceService>(() async => await DeviceService().init());
  await Get.putAsync<PackageService>(() async => await PackageService().init());
  await Get.putAsync<SharedPreferencesService>(
      () async => await SharedPreferencesService().init());
  await Get.putAsync<GeoLocatorService>(
      () async => await GeoLocatorService().init());
  developer.log('Services initialized'); // 添加日志记录
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('Building MyApp widget'); // 添加日志记录
    return GetMaterialApp(
      title: 'City Pass',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: TPColors.grayscale50,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: TPColors.white,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: TPColors.primary500),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0.0,
          iconTheme: IconThemeData(size: 56),
          actionsIconTheme: IconThemeData(size: 56),
        ),
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (_) =>
              Assets.svg.iconLeftArrow.svg(width: 24, height: 24),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: TPRoute.holder,
      getPages: TPRoute.page,
    );
  }
}
