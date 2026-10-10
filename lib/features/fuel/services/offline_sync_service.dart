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
  VoidCallback? onReconnected;

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
      bool hasConnectionsSignal = results.any(
        (r) => r != ConnectivityResult.none,
      );
      if (hasConnectionsSignal) {
        isOnline.value = true;

        if (onReconnected != null) {
          onReconnected!();
        }

        if (pendingQueue.isNotEmpty) {
          await syncPendingEntries();
        }
      } else {
        isOnline.value = false;
      }
    });
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

  Future<bool> saveOrQueueFuelEntry({
    required FuelModel entry,
    required Future<bool> Function(FuelModel) onlineSaveCallback,
  }) async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final bool hasSignal = connectivityResults.any(
      (r) => r != ConnectivityResult.none,
    );

    if (hasSignal) {
      try {
        return await onlineSaveCallback(entry);
      } catch (e) {
        return _addToQueue(entry);
      }
    } else {
      return _addToQueue(entry);
    }
  }

  bool _addToQueue(FuelModel entry) {
    if (pendingQueue.length >= maxQueueSize) {
      _utilsService.showToast(
        message: "Limite de $maxQueueSize abastecimentos offline atingido.",
        isError: true,
      );
      return false;
    }

    pendingQueue.add(entry);
    _saveQueueToStorage();
    _utilsService.showToast(
      message: "Salvo localmento. Será enviado quando a internet voltar.",
    );
    return true;
  }

  Future<void> syncPendingEntries({
    Future<bool> Function(FuelModel)? sendApiCallback,
  }) async {

    if (pendingQueue.isEmpty) return;
    if(sendApiCallback == null) return;
    
    List<FuelModel> itemsToSync = List.from(pendingQueue);
    int successCount = 0;

    for (var entry in itemsToSync) {
      try {
        bool success = await sendApiCallback(entry);
        if (success) {
          pendingQueue.remove(entry);
          successCount++;
        } else {}
      } catch (e) {
        if (e is SocketException || e is TimeoutException) {
          break;
        }
        break;
      }
    }

    await _saveQueueToStorage();

    if (successCount > 0) {
      _utilsService.showToast(
        message:
            "$successCount abastecimento(s) offline sincronizado(s) com sucesso!",
      );
    }
  }
}
