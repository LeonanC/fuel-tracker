import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class UtilsService {
  final storage = const FlutterSecureStorage();

  Future<void> saveLocalCache({required String key, required String data}) async {
    await storage.write(key: key, value: data);
  }

  Future<String?> getLocalData({required String key}) async {
    return await storage.read(key: key);
  }

  Future<void> removeLocalData({required String key}) async {
    await storage.delete(key: key);
  }

  String formatarDateTime(DateTime dateTime) {
    DateFormat dateFormat = DateFormat.yMd('pt_BR').add_Hm();
    return dateFormat.format(dateTime.toLocal());
  }

  String formatarCurrency(double valor){
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(valor);
  }

  String formatarConsumo(double kmL){
    return "${kmL.toStringAsFixed(2)} km/L";
  }
  
  String formatarVolume(double vol){
    return "${vol.toStringAsFixed(2)} L";
  }

  String formatarDistancia(double km){
    return "${km.toStringAsFixed(2)} km";
  }

  Uint8List decodeQrCodeImage(String value){
    String base64String = value.split(',').last;
    return base64.decode(base64String);
  }

  void showToast({required String message, bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: isError ? Colors.red : Colors.white,
      textColor: isError ? Colors.white : Colors.black,
      fontSize: 14,
    );
  }
}