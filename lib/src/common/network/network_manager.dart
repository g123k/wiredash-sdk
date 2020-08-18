import 'dart:convert';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:package_info/package_info.dart';
import 'package:wiredash/src/common/network/api_client.dart';

class NetworkManager {
  NetworkManager(this._apiClient);

  final ApiClient _apiClient;

  static const String _feedbackPath = 'feedback';

  static const String _parameterDeviceInfo = 'deviceInfo';
  static const String _parameterEmail = 'email';
  static const String _parameterPayload = 'payload';
  static const String _parameterUser = 'user';

  static const String _parameterPackageAppName = 'package_app_name';
  static const String _parameterPackageVersion = 'package_version';
  static const String _parameterPackageBuildNumber = 'package_build_number';
  static const String _parameterPackageName = 'package_name';

  static const String _parameterDeviceProduct = 'device_product';
  static const String _parameterDeviceModel = 'device_model';
  static const String _parameterDeviceBrand = 'device_brand';
  static const String _parameterDevicePhysicalDevice = 'device_physical_device';
  static const String _parameterDeviceVersion = 'device_version';

  static const String _parameterFeedbackMessage = 'message';
  static const String _parameterFeedbackScreenshot = 'file';
  static const String _parameterFeedbackType = 'type';

  Future<void> sendFeedback({
    @required Map<String, dynamic> deviceInfo,
    String email,
    @required String message,
    Map<String, dynamic> payload,
    Uint8List picture,
    @required String type,
    String user,
  }) async {
    MultipartFile screenshotFile;

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;

    if (picture != null) {
      screenshotFile = MultipartFile.fromBytes(
        _parameterFeedbackScreenshot,
        picture,
        filename: 'file',
        contentType: MediaType('image', 'png'),
      );
    }

    await _apiClient.post(
      urlPath: _feedbackPath,
      arguments: {
        _parameterDeviceInfo: json.encode(deviceInfo),
        if (email != null) _parameterEmail: email,
        _parameterFeedbackMessage: message,
        if (payload != null) _parameterPayload: json.encode(payload),
        _parameterFeedbackType: type,
        if (user != null) _parameterUser: user,
        _parameterPackageAppName: packageInfo?.appName,
        _parameterPackageVersion: packageInfo?.version,
        _parameterPackageBuildNumber: packageInfo?.buildNumber,
        _parameterPackageName: packageInfo?.packageName,
        _parameterDeviceProduct: androidInfo?.product ?? iosInfo?.model,
        _parameterDeviceModel: androidInfo?.model ?? iosInfo?.localizedModel,
        _parameterDeviceBrand: androidInfo?.brand ?? 'Apple',
        _parameterDevicePhysicalDevice:
            (androidInfo?.isPhysicalDevice ?? iosInfo?.isPhysicalDevice)
                ?.toString(),
        _parameterDeviceVersion:
            androidInfo?.version?.sdkInt?.toString() ?? iosInfo?.systemVersion,
      },
      files: [screenshotFile],
    );
  }
}
