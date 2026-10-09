import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutController extends GetxController {
  final supabase = Supabase.instance.client;
  final _utilsService = UtilsService();

  var appVersion = '10.4.0'.obs;
  var isCheckingForUpdate = false.obs;
  var downloadProgress = 0.0.obs;
  var isDownloading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
  }

  Future<void> checkForUpdate() async {
    try {
      isCheckingForUpdate.value = true;
      final supabaseData = await supabase
          .from('app_config')
          .select('latest_version, apk_url, force_update, changelog')
          .order('created_at', ascending: false)
          .maybeSingle();

      if (supabaseData != null) {
        final String latestVersion = supabaseData['latest_version'] ?? '';
        final String apkUrl = supabaseData['apk_url'] ?? '';
        final String changelog = supabaseData['changelog'] ?? '';

        if (_isUpdateAvailable(appVersion.value, latestVersion)) {
          _showUpdateDialog(latestVersion, apkUrl, changelog);
          return;
        } else {
          _utilsService.showToast(
            message: 'ab_updateServiceCheckForUpdates'.tr,
            isError: true,
          );
        }
      } else {
        _utilsService.showToast(
          message: 'ab_error_title_desc'.tr,
          isError: true,
        );
      }
    } catch (e) {
      _utilsService.showToast(
        message: '${'ab_error_title_desc'.tr}: $e',
        isError: true,
      );
    } finally {
      isCheckingForUpdate.value = false;
    }
  }

  bool _isUpdateAvailable(String current, String latest) {
    if (current.isEmpty || latest.isEmpty) return false;

    List<int> currentParts = current
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    List<int> latestParts = latest
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    int maxLength = currentParts.length > latestParts.length
        ? currentParts.length
        : latestParts.length;

    for(int i = 0; i < maxLength; i++){
      int currentVersionPart = i < currentParts.length ? currentParts[i] : 0;
      int latestVersionPart = i < latestParts.length ? latestParts[i] : 0;

      if(latestVersionPart > currentVersionPart) return true;
      if(latestVersionPart < currentVersionPart) return false;
    }

    return false;
  }

  void _showUpdateDialog(String newVersion, String url, String message){
    Get.defaultDialog(
      title: "ab_update_available".tr,
      middleText: message.isNotEmpty
        ? message
        : "${'ab_new_version'.tr} $newVersion",
      textConfirm: 'ab_update_now'.tr,
      textCancel: 'ab_later'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        if(Platform.isAndroid && url.endsWith('.apk')){
          await _downloadAndInstallApk(url);
        }else{
          final uri = Uri.parse(url);
          if(await canLaunchUrl(uri)){
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          Get.back();
        }
      },
    );
  }

  Future<void> _downloadAndInstallApk(String url) async {
    try{
      isDownloading.value = true;
      downloadProgress.value = 0.0;

      Directory tempDir = await getTemporaryDirectory();
      String savePath = '${tempDir.path}/update.apk';

      Dio dio = Dio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total){
          if(total != -1){
            downloadProgress.value = received / total;
          }
        }
      );

      isDownloading.value = false;
      Get.back();

      final result = await OpenFilex.open(savePath);

      if(result.type != ResultType.done){
        _utilsService.showToast(message: "Erro ao abrir o instalador: ${result.message}", isError: true);
      }
    }catch(e){
      isDownloading.value = false;
      Get.back();
      _utilsService.showToast(message: "Erro no download da atualização: $e", isError: true);
    }
  }

  void setChecking(bool value){
    isCheckingForUpdate.value = value;
  }
}
