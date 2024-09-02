import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/service/account_service.dart';
import 'package:town_pass/service/device_service.dart';
import 'package:town_pass/service/geo_locator_service.dart';
import 'package:town_pass/service/package_service.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/service/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:town_pass/service/speech_to_text.dart'; // 請確保導入路徑正確

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(
  //   widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  // );

  developer.log('Application started');

  await initServices();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // 初始化 SpeechToTextService 並進行簡單測試
  developer.log('Initializing SpeechToTextService');
  final speechToTextService =
      await Get.putAsync(() => SpeechToTextService().init());
  developer.log('SpeechToTextService initialized');

  // 測試 speech-to-text 功能
  if (speechToTextService.hasSpeech) {
    developer.log('Speech recognition is available');
    developer.log('Current locale: ${speechToTextService.currentLocaleId}');
    developer.log(
        'Available locales: ${speechToTextService.localeNames.map((locale) => locale.localeId).join(", ")}');

    // 嘗試開始監聽（注意：這只是一個示例，實際應用中應該在用戶界面中觸發）
    await speechToTextService.startListening();
    await Future.delayed(Duration(seconds: 5)); // 等待5秒
    await speechToTextService.stopListening();

    developer.log('Last recognized words: ${speechToTextService.lastWords}');
    developer.log('Last error (if any): ${speechToTextService.lastError}');
    developer.log('Last status: ${speechToTextService.lastStatus}');
  } else {
    developer.log('Speech recognition is not available on this device');
  }

  runApp(const MyApp());
}

Future<void> initServices() async {
  await Get.putAsync<AccountService>(() async => await AccountService().init());
  await Get.putAsync<DeviceService>(() async => await DeviceService().init());
  await Get.putAsync<PackageService>(() async => await PackageService().init());
  await Get.putAsync<SharedPreferencesService>(
      () async => await SharedPreferencesService().init());
  await Get.putAsync<GeoLocatorService>(
      () async => await GeoLocatorService().init());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
