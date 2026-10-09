import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuel_tracker/core/models/vehicle_model.dart';
import 'package:fuel_tracker/core/network/app_router.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:fuel_tracker/features/auth/controllers/auth_controller.dart';
import 'package:fuel_tracker/features/fuel/services/home_service.dart';
import 'package:get/get.dart';

class VehicleController extends GetxController {
  final authController = Get.find<AuthController>();
  final HomeService _homeService = HomeService();
  final _utilsService = UtilsService();
  var userVehicles = <VehicleModel>[].obs;
  var isLoading = false.obs;
  var selectedVehicle = Rxn<VehicleModel>();
  StreamSubscription? _vehicleStreamSubscription;
  

  @override
  void onInit() {
    super.onInit();
    initVehicleStream();
  }

  void initVehicleStream(){
    _vehicleStreamSubscription?.cancel();
    final stream = _homeService.getVehicleStream();
    if(stream == null) {
      isLoading.value = false;
      return;
    }

    _vehicleStreamSubscription = stream.listen((snapshot){
      userVehicles.value = snapshot.map((v) => VehicleModel.fromJson(v)).toList();
      isLoading.value = false;
    }, onError: (error){
      isLoading.value = false;
      _utilsService.showToast(message: 'Erro ao carregar veículos: $error', isError: true);
    });
  }

  Future<void> setSelectedVehicle(String vehicleId) async {
    try{
      final currentUser = authController.currentUser.value;
      if(currentUser?.id == null) return;

      currentUser!.vehicle = vehicleId;
      authController.currentUser.refresh();
      await _homeService.updateUserVehicle(currentUser.id!, vehicleId);
      _utilsService.showToast(message: 'Veículo principal atualizado!');
    }catch(e){
      _utilsService.showToast(message: 'Não foi possível alterar o veículo: $e', isError: true);
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try{
      isLoading.value = true;
      await _homeService.deleteVehicle(vehicleId);
      userVehicles.removeWhere((v) => v.id == vehicleId);
      if(authController.currentUser.value?.vehicle == vehicleId){
        authController.currentUser.value!.vehicle = null;
        authController.currentUser.refresh();
      }
      _utilsService.showToast(message: 'Veículo excluído com sucesso!');
    }catch(e){
      _utilsService.showToast(message: 'Não foi possível excluir o veículo: $e', isError: true);
    }finally{
      isLoading.value = false;
    }
  }

  void navigateToAdd(BuildContext context) async {
    final result = await Get.toNamed(PagesRoutes.addVehicleRoute);
    if(result == true){
      _utilsService.showToast(message: 'Veículo cadastrado com sucesso!');
    }
  }
}