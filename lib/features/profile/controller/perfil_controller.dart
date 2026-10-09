import 'package:fuel_tracker/core/network/app_router.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilController extends GetxController {
  final supabase = Supabase.instance.client;
  final _utilsService = UtilsService();

  var isLoading = false.obs;
  var userName = ''.obs;
  var userFoto = ''.obs;
  var userEmail = ''.obs;
  var userPhone = ''.obs;
  var memberSince = ''.obs;

  var vehicleName = ''.obs;
  var vehiclePlate = ''.obs;
  var vehicleTankCapacity = ''.obs;
  var vehicleImage = ''.obs;
  var vehicleOdometer = ''.obs;
  var vehicleFuelType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;

      if (user != null) {
        userEmail.value = user.email ?? '';

        final profileData = await supabase
            .from('usuarios')
            .select('nome, telefone, foto_url, criado_em, fk_vehicle')
            .eq('id', user.id)
            .maybeSingle();

        if (profileData != null) {
          userName.value = profileData['nome'] ?? 'Utilizador';
          userPhone.value = profileData['telefone'] ?? 'Não registrado';
          userFoto.value = profileData['foto_url'] ?? 'Sem Imagem';
          memberSince.value = profileData['criado_em'] != null
              ? profileData['criado_em'].toString().substring(0, 10)
              : '2026';

          final vehicleId = profileData['fk_vehicle'];

          if (vehicleId != null) {
            final vehicleData = await supabase
                .from('vehicles')
                .select(
                  'name, license_plate, tank_capacity_liters, imagem, initial_odometer, fuel_type',
                )
                .eq('user_id', user.id)
                .limit(1)
                .maybeSingle();

            if (vehicleData != null) {
              vehicleName.value = vehicleData['name'] ?? 'N/A';
              vehiclePlate.value = vehicleData['license_plate'] ?? 'N/A';
              vehicleTankCapacity.value =
                  vehicleData['tank_capacity_liters']?.toString() ?? '0';
              vehicleImage.value = vehicleData['imagem'] ?? '';
              vehicleOdometer.value =
                  vehicleData['initial_odometer']?.toString() ?? '0';

              final fuelTypeId = vehicleData['fuel_type'];
              if (fuelTypeId != null) {
                try {
                  final fuelData = await supabase
                      .from('tipo_combustivel')
                      .select('nome')
                      .eq('pk_tipo', fuelTypeId)
                      .maybeSingle();

                  if (fuelData != null) {
                    vehicleFuelType.value =
                        fuelData['name'] ?? fuelData['nome'] ?? 'Gasolina';
                  } else {
                    vehicleFuelType.value = 'Gasolina';
                  }
                } catch (e) {
                  vehicleFuelType.value = 'Não especificado';
                }
              } else {
                vehicleName.value = 'Nenhum veículo';
                vehiclePlate.value = 'N/A';
                vehicleTankCapacity.value = '0';
                vehicleImage.value = '0';
                vehicleOdometer.value = '0';
                vehicleFuelType.value = 'N/A';
              }
            }
          }
        }
      }
    } catch (e) {
      _utilsService.showToast(
        message: "Erro ao carregar perfil: $e",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(String newName, String newPhone) async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase
            .from('usuarios')
            .update({'nome': newName, 'telefone': newPhone})
            .eq('id', user.id);

        userName.value = newName;
        userPhone.value = newPhone;

        _utilsService.showToast(
          message: 'Perfil atualizado com sucesso!',
          isError: false,
        );
      }
    } catch (e) {
      _utilsService.showToast(
        message: 'Erro ao atualizar perfil: $e',
        isError: true,
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;

      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        _utilsService.showToast(
          message: 'Palavra-passe alterada com sucesso!',
          isError: false,
        );
      }
    } catch (e) {
      _utilsService.showToast(
        message: 'Erro ao alterar palavra-passe: $e',
        isError: true,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      Get.offAllNamed(PagesRoutes.signInRoute);
    } catch (e) {
      _utilsService.showToast(
        message: "Erro ao terminar sessão: $e",
        isError: true,
      );
    }
  }
}
