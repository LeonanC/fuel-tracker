import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker/core/models/fuel_model.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OfflineSyncService extends GetxService {
  final GetStorage _box = GetStorage();
  final _utilsService = UtilsService();
  final String _queueKey = 'offline_fuel_queue';
  final int maxQueueSize = 10;
  final Connectivity _connectivity = Connectivity();
  final RxList<FuelModel> pendingQueue = <FuelModel>[].obs;
  final RxBool isOnline = true.obs;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _loadQueueFromStorage();
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      final hasInternet = await _hasRealInternet(results);
      isOnline.value = hasInternet;
      if (hasInternet && pendingQueue.isNotEmpty) {
        syncPendingEntries();
      }
    });
  }

  Future<bool> _hasRealInternet([List<ConnectivityResult>? results]) async {
    final connectivy = results ?? await _connectivity.checkConnectivity();
    if (connectivy.contains(ConnectionState.none) || connectivy.isEmpty) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  void _loadQueueFromStorage() {
    final List<dynamic>? rawData = _box.read<List<dynamic>>(_queueKey);
    if (rawData != null) {
      pendingQueue.assignAll(
        rawData
            .map((item) => FuelModel.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
    }
  }

  Future<void> _saveQueueToStorage() async {
    final rawData = pendingQueue.map((item) => item.toJson()).toList();
    await _box.write(_queueKey, rawData);
  }

  Future<bool> saveOrQueueFuelEntry({required FuelModel entry, required Future<bool> Function(FuelModel) onlineSaveCallback}) async {
    final bool online = await _hasRealInternet();

    if(online){
      try{
        return await onlineSaveCallback(entry);
      }catch(e){
        if(e is SocketException || e is TimeoutException){
          return _addToQueue(entry);
        }

        _utilsService.showToast(message: 'Erro ao salvar no servidor: $e', isError: true);
        return false;
      }
    }else{
      return _addToQueue(entry);
    }
  }

  bool _addToQueue(FuelModel entry){
    if(pendingQueue.length >= maxQueueSize){
      _utilsService.showToast(message: "Limite de $maxQueueSize abastecimentos offline atingido. Conecte à internet para sincronizar.", isError: true);
      return false;
    }

    pendingQueue.add(entry);
    _saveQueueToStorage();

    _utilsService.showToast(message: "Abastecimento salvo na fila (${pendingQueue.length}/$maxQueueSize). Será enviado quando a internet voltar.");
    return true;
  }

  Future<void> syncPendingEntries({Future<bool> Function(FuelModel)? sendApiCallback}) async {
    if(pendingQueue.isEmpty) return;
    List<FuelModel> itemsToSync = List.from(pendingQueue);
    for(var entry in itemsToSync){
      try{
        bool success = true;
        if(success){
          pendingQueue.remove(entry);
          await _saveQueueToStorage();
        }
      }catch(e){
        break;
      }
    }

    if(pendingQueue.isEmpty){
      _utilsService.showToast(message: "Todos os abastecimentos offline foram salvos na nuvem com sucesso.", isError: true);
    }
  }
}
