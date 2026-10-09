import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsController extends GetxController {
  var selectedLocale = Get.locale.obs;
  var isDarkMode = true.obs;
  var language = 'pt_BR'.obs;
  var appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppInfo();
  }

  void _loadAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = "${packageInfo.version} (${packageInfo.buildNumber})";
  }


  void changeLanguage(Locale locale) {
    Get.updateLocale(locale);
    selectedLocale.value = locale;
  }

  String getLanguageName(Locale locale){
    switch(locale.languageCode){
      case 'pt':
        return 'st_lang_pt'.tr;
      case 'en':
        return 'st_lang_en'.tr;
      case 'es':
        return 'st_lang_es'.tr;
      case 'fr':
        return 'st_lang_fr'.tr;
      case 'de':
        return 'st_lang_de'.tr;
      case 'it':
        return 'st_lang_it'.tr;
      case 'ja':
        return 'st_lang_ja'.tr;
      case 'zh':
        return 'st_lang_zh'.tr;
      case 'ko':
        return 'st_lang_ko'.tr;
      default:
        return locale.languageCode;
    }
  }

}