import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker/core/models/fuel_model.dart';
import 'package:fuel_tracker/core/models/station_model.dart';
import 'package:fuel_tracker/core/models/type_gas.dart';
import 'package:fuel_tracker/core/models/vehicle_model.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:fuel_tracker/features/fuel/services/home_service.dart';
import 'package:fuel_tracker/features/fuel/services/offline_sync_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _homeService = HomeService();
  final OfflineSyncService _offlineSyncService = Get.find<OfflineSyncService>();
  final _utilsService = UtilsService();
  FuelModel? editingEntry;

  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;
  var isFullTank = false.obs;
  var selectedDate = DateTime.now().obs;
  var veiculos = <VehicleModel>[].obs;
  var postos = <StationModel>[].obs;
  var tipos = <TypeGas>[].obs;

  var selectedVeiculos = RxnString();
  var selectedPostos = RxnString();
  var selectedTipos = RxnString();

  var veiculosMap = <String, Map<String, dynamic>>{}.obs;
  var postosMap = <String, Map<String, dynamic>>{}.obs;
  var tiposMap = <String, Map<String, dynamic>>{}.obs;

  var precoAtual = 0.0.obs;
  bool _isCalculating = false;

  late MoneyMaskedTextController totalPrecoController;
  late MoneyMaskedTextController litrosController;
  late MoneyMaskedTextController precoPorLitroController;
  late TextEditingController kmController;

  @override
  void onInit() {
    super.onInit();
    initData();

    final Map<String, dynamic>? args = Get.arguments;
    final FuelModel? entry = args?['entry'];
    final double? lastOdometer = args?['lastOdometer'];
    inicializar(entry, lastOdometer);

    ever(selectedPostos, (_) => atualizarPrecoCombustivel());
    ever(selectedTipos, (_) => atualizarPrecoCombustivel());
  }

  Future<void> initData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _supabase.from('vehicles').select(),
        _supabase.from('postos').select(),
        _supabase.from('tipo_combustivel').select(),
      ]);
      final veiculoData = results[0] as List;
      veiculos.value = veiculoData
          .map((v) => VehicleModel.fromJson(Map<String, dynamic>.from(v)))
          .toList();
      veiculosMap.value = {for (var v in veiculoData) v['id'].toString(): v};

      final postoData = results[1] as List;
      postos.value = postoData
          .map((v) => StationModel.fromJson(Map<String, dynamic>.from(v)))
          .toList();
      postosMap.value = {for (var v in postoData) v['pk_posto'].toString(): v};

      final tipoData = results[2] as List;
      tipos.value = tipoData
          .map((v) => TypeGas.fromJson(Map<String, dynamic>.from(v)))
          .toList();
      tiposMap.value = {for (var v in tipoData) v['pk_tipo'].toString(): v};
    } finally {
      isLoading.value = false;
    }
  }

  void inicializar(FuelModel? entry, double? lastOdometer) {
    editingEntry = entry;
    

    precoPorLitroController = MoneyMaskedTextController(
      initialValue: entry?.pricePerLiter ?? 0.0,
      leftSymbol: 'R\$ ',
    );
    totalPrecoController = MoneyMaskedTextController(
      initialValue: entry?.totalCost ?? 0.0,
      leftSymbol: 'R\$ ',
    );
    litrosController = MoneyMaskedTextController(
      initialValue: entry?.volumeLiters ?? 0.0,
      leftSymbol: '',
      precision: 2,
    );

    kmController = TextEditingController(
      text: entry != null
          ? entry.odometerKm.toString()
          : (lastOdometer != null && lastOdometer > 0
                ? lastOdometer.toString()
                : ''),
    );

    isFullTank.value = entry?.isFullTank ?? true;

    litrosController.addListener(() => _calcularLitros(from: 'litros'));
    precoPorLitroController.addListener(() => _calcularLitros(from: 'preco'));
    totalPrecoController.addListener(() => _calcularLitros(from: 'total'));

    precoPorLitroController.addListener(() {
      precoAtual.value = precoPorLitroController.numberValue;
    });

    if (entry != null) {
      selectedTipos.value = entry.fuelTypeId;
      selectedVeiculos.value = entry.vehicleId;
      selectedPostos.value = entry.gasStationId;
      selectedDate.value = entry.entryDate!;
      isFullTank.value = entry.isFullTank;
    }
  }

  void atualizarPrecoCombustivel() {
    final postoId = selectedPostos.value;
    final tipoId = selectedTipos.value;

    if (postoId == null || tipoId == null || editingEntry != null) return;

    try {
      final posto = postos.firstWhereOrNull((p) => p.id == postoId);
      final tipo = tipos.firstWhereOrNull((t) => t.id == tipoId);

      if (posto != null && tipo != null) {
        double? preco = 0.0;
        final nome = tipo.name!.toLowerCase();
        if (nome.contains('gasolina')) {
          preco = double.tryParse(posto.precoGasolina.toString()) ?? 0.0;
        } else if (nome.contains('etanol')) {
          preco = double.tryParse(posto.precoEtanol.toString()) ?? 0.0;
        } else if (nome.contains('diesel')) {
          preco = double.tryParse(posto.precoDiesel.toString()) ?? 0.0;
        } else if (nome.contains('gnv')) {
          preco = double.tryParse(posto.precoGnv.toString()) ?? 0.0;
        }

        if (preco > 0) {
          precoPorLitroController.updateValue(preco);
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar preço do combustível: $e');
    }
  }

  void _calcularLitros({required String from}) {
    if (_isCalculating) return;
    _isCalculating = true;

    try {
      final double l = litrosController.numberValue;
      final double p = precoPorLitroController.numberValue;
      final double t = totalPrecoController.numberValue;

      if (from == 'litros' || from == 'preco') {
        if (l > 0 && p > 0) {
          totalPrecoController.updateValue(l * p);
        }
      } else if (from == 'total') {
        if (t > 0 && l > 0) {
          precoPorLitroController.updateValue(t / l);
        }
      }
    } finally {
      _isCalculating = false;
    }
  }

  Future<void> selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Selecionar a data de abastecimento',
      cancelText: 'Cancelar',
      confirmText: 'Próximo',
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate.value),
        helpText: 'Hora do abastecimento',
        cancelText: 'Cancelar',
        confirmText: 'Ok',
      );

      if (pickedTime != null) {
        selectedDate.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      } else {
        selectedDate.value = picked;
      }
    }
  }

  void atualizarHodometroPorVeiculo(String? vehicleId) {
    if (vehicleId == null) return;
    final v = veiculos.firstWhereOrNull((element) => element.id == vehicleId);
    if (v != null && editingEntry == null) {
      kmController.text = v.odometer.toString();
    }
  }

  Future<void> submit() async {
    if (selectedVeiculos.value == null ||
        selectedTipos.value == null ||
        selectedPostos.value == null) {
      _utilsService.showToast(
        message: "Selecione o veículo, posto e o tipo de combustível",
        isError: true,
      );
      return;
    }

    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw "Sessão expirada";

      final fuelData = {
        'fk_usuario': userId,
        'fk_veiculo': selectedVeiculos.value,
        'fk_tipo': selectedTipos.value,
        'fk_posto': selectedPostos.value,
        'data': selectedDate.value.toIso8601String(),
        'velocimetro': double.tryParse(kmController.text) ?? 0.0,
        'litros_volume': litrosController.numberValue,
        'preco_litro': precoPorLitroController.numberValue,
        'custo_total': totalPrecoController.numberValue,
        'is_full_tank': isFullTank.value,
      };

      if (editingEntry != null) {
        fuelData['pk_fuel'] = editingEntry!.id;
        final updatedModel = FuelModel.fromJson(fuelData);
        await updateFuel(updatedModel);
      } else {
        final newFuel = FuelModel.fromJson(fuelData);
        bool sucess = await _offlineSyncService.saveOrQueueFuelEntry(
          entry: newFuel,
          onlineSaveCallback: (entry) async {
            await saveFuel(entry.toJson());
            return true;
          },
        );

        if (sucess) {
          Get.back(result: true);
        }
      }
    } catch (e) {
      _utilsService.showToast(message: 'Erro: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateVehicleOdometer(
    String vehicleId,
    double newOdometer,
  ) async {
    try {
      final vehicleResponse = await _supabase
          .from('vehicles')
          .select('initial_odometer')
          .eq('id', vehicleId)
          .maybeSingle();

      if (vehicleResponse != null) {
        final currentOdometer =
            (vehicleResponse['initial_odometer'] as num?)?.toDouble() ?? 0.0;
        if (newOdometer > currentOdometer) {
          await _supabase
              .from('vehicles')
              .update({'initial_odometer': newOdometer})
              .eq('id', vehicleId);
        }
      }
    } catch (e) {
      debugPrint('Erro ao atualizar hodômetro do veículo: $e');
    }
  }

  Future<void> saveFuel(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      _homeService.saveFuel(data);

      final vehicleId = data['fk_veiculo']?.toString();
      final newOdometer = (data['velocimetro'] as num?)?.toDouble() ?? 0.0;

      if (vehicleId != null && newOdometer > 0) {
        await _updateVehicleOdometer(vehicleId, newOdometer);
      }

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

  Future<void> updateFuel(FuelModel data) async {
    try {
      isLoading.value = true;
      _homeService.updateFuel(data);

      if (data.vehicleId != null && data.odometerKm != null) {
        await _updateVehicleOdometer(data.vehicleId!, data.odometerKm!);
      }

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
    kmController.dispose();
    litrosController.dispose();
    precoPorLitroController.dispose();
    totalPrecoController.dispose();
    super.onClose();
  }
}
