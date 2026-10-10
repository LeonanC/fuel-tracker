import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuel_tracker/core/models/fuel_model.dart';
import 'package:fuel_tracker/core/models/station_model.dart';
import 'package:fuel_tracker/core/models/type_gas.dart';
import 'package:fuel_tracker/core/models/vehicle_model.dart';
import 'package:fuel_tracker/core/network/app_router.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:fuel_tracker/features/fuel/services/home_service.dart';
import 'package:fuel_tracker/features/fuel/services/offline_sync_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final OfflineSyncService _offlineSyncService = Get.find<OfflineSyncService>();
  final HomeService _homeService = HomeService();
  final _utilsService = UtilsService();

  var veiculos = <VehicleModel>[].obs;
  var fuelEntries = <FuelModel>[].obs;
  var postos = <StationModel>[].obs;
  var tipos = <TypeGas>[].obs;

  var veiculosMap = <String, Map<String, dynamic>>{}.obs;
  var postosMap = <String, Map<String, dynamic>>{}.obs;
  var tiposMap = <String, Map<String, dynamic>>{}.obs;

  var isLoading = false.obs;
  var isOfflineMode = false.obs;
  var searchText = ''.obs;

  final suppliesList = <FuelModel>[].obs;

  var selectedVehicleId = RxnString();
  var selectedTipoId = RxnString();
  var selectedPostoId = RxnString();

  StreamSubscription? _fuelStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    loadCacheAndFetchData();
  }

  Future<void> loadCacheAndFetchData() async {
    final cacheData = await _homeService.loadLocalCache();
    if (cacheData != null) {
      _applyDataToState(cacheData);
      if (cacheData.containsKey('fuelEntries')) {
        fuelEntries.value = cacheData['fuelEntries'];
      }
    }

    await _homeService.syncPendingQueue();
    await fetchStaticData();
    initFuelStream();
  }

  void _applyDataToState(Map<String, dynamic> data) {
    veiculos.value = data['veiculos'];
    postos.value = data['postos'];
    tipos.value = data['tipos'];

    veiculosMap.value = {
      for (var v in data['veiculosRaw']) v['id'].toString(): v,
    };
    postosMap.value = {
      for (var p in data['postosRaw']) p['pk_posto'].toString(): p,
    };
    tiposMap.value = {
      for (var t in data['tiposRaw']) t['pk_tipo'].toString(): t,
    };
  }

  Future<void> fetchStaticData() async {
    try {
      isLoading.value = true;
      final data = await _homeService.fetchStaticData();
      if (data != null) {
        _applyDataToState(data);
      }
      isOfflineMode.value = false;
    } catch (e) {
      isOfflineMode.value = true;
      _utilsService.showToast(message: 'Modo Offline ativado');
    } finally {
      isLoading.value = false;
    }
  }

  void initFuelStream() {
    _fuelStreamSubscription?.cancel();

    try {
      final stream = _homeService.getFuelStream();
      if (stream == null) return;

      _fuelStreamSubscription = stream.listen(
        (snapshot) {
          fuelEntries.value = snapshot
              .map((f) => FuelModel.fromJson(f))
              .toList();
          _homeService.saveLocalCache('fuelings', snapshot);
          isOfflineMode.value = false;
        },
        onError: (error) {
          isOfflineMode.value = true;
        },
      );
    } catch (e) {
      isOfflineMode.value = true;
    }
  }

  Future<bool> saveFuel(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final newFuel = FuelModel.fromJson(data);
      fuelEntries.insert(0, newFuel);
      _persistFuelEntriesLocally();

      bool success = await _offlineSyncService.saveOrQueueFuelEntry(
        entry: newFuel,
        onlineSaveCallback: (entry) async {
          return await _homeService.saveFuel(data);
        },
      );

      if (success) {
        _utilsService.showToast(
          message: 'Abastecimento registrado com sucesso!',
        );
      }
      return success;
    } catch (e) {
      _utilsService.showToast(
        message: 'Falha ao processar registro.',
        isError: true,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFuel(FuelModel data) async {
    try {
      if (data.id == null) return;
      isLoading.value = true;

      int index = fuelEntries.indexWhere((e) => e.id == data.id);
      if (index != -1) {
        fuelEntries[index] = data;
        fuelEntries.refresh();
        _persistFuelEntriesLocally();
      }

      bool successOnline = await _homeService.updateFuel(data);
      if (successOnline) {
        _utilsService.showToast(message: 'Abastecimento atualizado!');
      } else {
        _utilsService.showToast(
          message: 'A alteração será enviado ao reconectar.',
          isError: true,
        );
      }
    } catch (e) {
      _utilsService.showToast(
        message: 'Falha ao processar registro.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFuel(String id) async {
    try {
      fuelEntries.removeWhere((element) => element.id == id);
      _persistFuelEntriesLocally();

      bool successOnline = await _homeService.deleteFuel(id);
      if (successOnline) {
        _utilsService.showToast(message: 'Abastecimento removido!');
      } else {
        _utilsService.showToast(
          message: 'A delação será enviado ao reconectar.',
          isError: true,
        );
      }
    } catch (e) {
      _utilsService.showToast(
        message: 'Falha ao processar registro.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _persistFuelEntriesLocally() {
    final rawList = fuelEntries.map((e) => e.toJson()).toList();
    _homeService.saveLocalCache('fuelings', rawList);
  }

  List<FuelModel> get filteredFuelEntries {
    List<FuelModel> list = fuelEntries;

    if (selectedVehicleId.value != null &&
        selectedVehicleId.value!.isNotEmpty) {
      list = list.where((e) => e.vehicleId == selectedVehicleId.value).toList();
    }
    if (selectedTipoId.value != null && selectedTipoId.value!.isNotEmpty) {
      list = list.where((e) => e.fuelTypeId == selectedTipoId.value).toList();
    }
    if (selectedPostoId.value != null && selectedPostoId.value!.isNotEmpty) {
      list = list
          .where((e) => e.gasStationId == selectedPostoId.value)
          .toList();
    }

    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      list = list.where((e) {
        final dadosVeiculo = veiculosMap[e.vehicleId];
        final veiculo = dadosVeiculo?['name']?.toString().toLowerCase() ?? '';

        final dadosPosto = postosMap[e.gasStationId];
        final posto = dadosPosto?['nome']?.toString().toLowerCase() ?? '';

        final dadosTipo = tiposMap[e.fuelTypeId];
        final tipo = dadosTipo?['nome']?.toString().toLowerCase() ?? '';

        return posto.contains(query) ||
            veiculo.contains(query) ||
            tipo.contains(query);
      }).toList();
    }
    return list;
  }

  Future<void> fetchData() async {
    await fetchStaticData();
    initFuelStream();
  }

  void navigateToAddEntry(BuildContext context) async {
    final result = await Get.toNamed(
      PagesRoutes.fuelRoute,
      arguments: {'lastOdometer': odometerAnterior},
    );
    if (result == true) {
      fetchData();
      _utilsService.showToast(message: "Abastecimento registrado!");
    }
  }

  void navigateToEditEntry(BuildContext context, FuelModel entry) async {
    final result = await Get.toNamed(
      PagesRoutes.fuelRoute,
      arguments: {'lastOdometer': odometerAnterior, 'entry': entry},
    );
    if (result == true) {
      fetchData();
      _utilsService.showToast(message: "Abastecimento atualizado!");
    }
  }

  double get odometerAnterior {
    final entries = filteredFuelEntries;
    if (entries.length >= 2) {
      return entries[1].odometerKm;
    }

    final veiculo = veiculos.firstWhereOrNull(
      (v) => v.id == selectedVehicleId.value,
    );
    return veiculo?.odometer ?? 0.0;
  }

  double get mediaConsumoGeral {
    final entries = filteredFuelEntries;
    if (entries.length < 2) return 0.0;

    final sortedEntries = List<FuelModel>.from(entries)
      ..sort((a, b) => (a.odometerKm).compareTo(b.odometerKm));

    double kmTotalRodado =
        (sortedEntries.last.odometerKm) - (sortedEntries.first.odometerKm);
    if (kmTotalRodado <= 0) return 0.0;

    double litrosTotais = 0.0;
    for (int i = 0; i < sortedEntries.length - 1; i++) {
      litrosTotais += sortedEntries[i].volumeLiters;
    }

    if (litrosTotais <= 0) return 0.0;

    return kmTotalRodado / litrosTotais;
  }

  double get custoPorKm {
    final entries = filteredFuelEntries;
    if (entries.length < 2) return 0.0;

    final sortedEntries = List<FuelModel>.from(entries)
      ..sort((a, b) => (a.odometerKm).compareTo(b.odometerKm));

    double kmTotalRodado = (sortedEntries.last.odometerKm) - (sortedEntries.first.odometerKm);
    if(kmTotalRodado <= 0) return 0.0;

    double custoTotal = 0.0;
    for(int i = 1; i < sortedEntries.length; i++){
      custoTotal += sortedEntries[i].totalCost;
    }
    if(custoTotal <= 0) return 0.0;
    
    return custoTotal / kmTotalRodado;
  }

  @override
  void onClose() {
    _fuelStreamSubscription?.cancel();
    super.onClose();
  }
}
