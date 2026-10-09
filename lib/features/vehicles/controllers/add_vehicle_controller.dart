import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker/core/models/type_gas.dart';
import 'package:fuel_tracker/core/models/vehicle_model.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:fuel_tracker/features/fuel/services/offline_sync_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddVehicleController extends GetxController {
  final _supabase = Supabase.instance.client;
  final OfflineSyncService _offlineSyncService = Get.find<OfflineSyncService>();
  final _utilsService = UtilsService();
  VehicleModel? editingEntry;

  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController licenseController;
  late TextEditingController imagemController;
  late MoneyMaskedTextController tankCapacityController;
  late MoneyMaskedTextController initialOdometerController;
  var tipos = <TypeGas>[].obs;
  var selectedTipos = RxnString();
  var isLoading = false.obs;
  var tiposMap = <String, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    initData();
    final Map<String, dynamic>? args = Get.arguments;
    final VehicleModel? entry = args?['entry'];
    inicializar(entry);
  }

  Future<void> initData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _supabase.from('tipo_combustivel').select(),
      ]);

      final tipoData = results[0] as List;
      tipos.value = tipoData
          .map((v) => TypeGas.fromJson(Map<String, dynamic>.from(v)))
          .toList();
      tiposMap.value = {for (var v in tipoData) v['pk_tipo'].toString(): v};
    } finally {
      isLoading.value = false;
    }
  }

  void inicializar(VehicleModel? entry) {
    editingEntry = entry;

    nameController = TextEditingController(text: entry?.name);
    licenseController = TextEditingController(text: entry?.licensePlate);
    imagemController = TextEditingController(text: entry?.imagem);

    tankCapacityController = MoneyMaskedTextController(
      initialValue: entry?.tankCapacityLiters ?? 0.0,
      rightSymbol: 'L',
    );

    initialOdometerController = MoneyMaskedTextController(
      initialValue: entry?.odometer ?? 0.0,
      rightSymbol: 'Km',
    );

    if (entry != null) {
      selectedTipos.value = entry.fuelType;
    }
  }

  Future<void> submit() async {
    if (selectedTipos.value == null) {
      _utilsService.showToast(
        message: "Selecione o tipo de combustível",
        isError: true,
      );
      return;
    }

    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw "Sessão expirada";

      final vehicleData = {
        'user_id': userId,
        'name': nameController.text,
        'license_plate': licenseController.text,        
        'fuel_type': selectedTipos.value,
        'imagem': imagemController.text,
        'tank_capacity_liters': tankCapacityController.numberValue,
        'initial_odometer': initialOdometerController.numberValue,
      };

      if (editingEntry != null) {
        vehicleData['id'] = editingEntry!.id;
        final updatedModel = VehicleModel.fromJson(vehicleData);
        await updateVehicle(updatedModel);
      } else {
        await saveVehicle(vehicleData);
      }
    } catch (e) {
      _utilsService.showToast(message: 'Erro: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveVehicle(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _supabase.from('vehicles').insert(data);
      Get.back(result: true);
    } catch (e) {
      _utilsService.showToast(
        message: 'Falha ao salvar no banco',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateVehicle(VehicleModel data) async {
    try {
      if (data.id == null) return;
      isLoading.value = true;
      await _supabase.from('vehicles').update(data.toJson()).eq('id', data.id!);
      Get.back(result: true);
    } catch (e) {
      _utilsService.showToast(
        message: 'Falha ao salvar no banco',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    licenseController.dispose();
    imagemController.dispose();
    tankCapacityController.dispose();
    initialOdometerController.dispose();
    super.onClose();
  }
}
