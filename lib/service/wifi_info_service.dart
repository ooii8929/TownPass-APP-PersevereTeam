import 'package:network_info_plus/network_info_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class WifiInfoService extends GetxService {
  final NetworkInfo _networkInfo = NetworkInfo();

  String? _wifiName;
  String? _wifiBSSID;
  String? _wifiIPv4;
  String? _wifiIPv6;
  String? _wifiGatewayIP;
  String? _wifiBroadcast;
  String? _wifiSubmask;

  String? get wifiName => _wifiName;
  String? get wifiBSSID => _wifiBSSID;
  String? get wifiIPv4 => _wifiIPv4;
  String? get wifiIPv6 => _wifiIPv6;
  String? get wifiGatewayIP => _wifiGatewayIP;
  String? get wifiBroadcast => _wifiBroadcast;
  String? get wifiSubmask => _wifiSubmask;

  Future<WifiInfoService> init() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        if (await Permission.locationWhenInUse.request().isGranted) {
          _wifiName = await _networkInfo.getWifiName();
          _wifiBSSID = await _networkInfo.getWifiBSSID();
        } else {
          _wifiName = 'Unauthorized to get Wifi Name';
          _wifiBSSID = 'Unauthorized to get Wifi BSSID';
        }
      } else {
        _wifiName = await _networkInfo.getWifiName();
        _wifiBSSID = await _networkInfo.getWifiBSSID();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi Name or BSSID', error: e);
      _wifiName = 'Failed to get Wifi Name';
      _wifiBSSID = 'Failed to get Wifi BSSID';
    }

    try {
      _wifiIPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      _wifiIPv4 = 'Failed to get Wifi IPv4';
    }

    try {
      _wifiIPv6 = await _networkInfo.getWifiIPv6();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv6', error: e);
      _wifiIPv6 = 'Failed to get Wifi IPv6';
    }

    try {
      _wifiSubmask = await _networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask address', error: e);
      _wifiSubmask = 'Failed to get Wifi submask address';
    }

    try {
      _wifiBroadcast = await _networkInfo.getWifiBroadcast();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi broadcast', error: e);
      _wifiBroadcast = 'Failed to get Wifi broadcast';
    }

    try {
      _wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi gateway address', error: e);
      _wifiGatewayIP = 'Failed to get Wifi gateway address';
    }

    return this;
  }
}
