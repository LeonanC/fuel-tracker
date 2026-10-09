import 'dart:io';

import 'package:fuel_tracker/core/models/user_model.dart';
import 'package:fuel_tracker/core/models/vehicle_model.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:fuel_tracker/features/vehicles/controllers/vehicle_controller.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;
  final _supabase = Supabase.instance.client;
  final _utilsService = UtilsService();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  Rxn<VehicleModel> get currentVehicle {
    if (Get.isRegistered<VehicleController>()) {
      return Get.find<VehicleController>().selectedVehicle;
    }
    return Rxn<VehicleModel>();
  }

  var appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
    _updateUser(_supabase.auth.currentUser);

    _supabase.auth.onAuthStateChange.listen((data) {
      _updateUser(data.session?.user);
    });
  }

  void _updateUser(User? supabaseUser) {
    if (supabaseUser == null) {
      currentUser.value = null;
    } else {
      currentUser.value = UserModel.fromSupabaseUser(supabaseUser);
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = 'v${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (_) {
      appVersion.value = '1.0.0';
    }
  }

  bool get isAuthenticated => currentUser.value != null;

  Future<bool> signUpWithProfile({
    required String email,
    required String password,
    required String name,
    required String phone,
    File? imageFile,
    String? vehicleId,
  }) async {
    try {
      isLoading.value = true;

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'nome': name, 'telefone': phone},
      );

      final User? user = response.user;
      if (user == null) {
        throw Exception("Não foi possível criar o utilizador.");
      }
      
      if (_supabase.auth.currentSession == null) {
        await _supabase.auth.signInWithPassword(email: email, password: password);
      }

      String? fotoUrl;
      if (imageFile != null) {
        final filePath = 'perfis/avatar_${user.id}.jpg';
        await _supabase.storage
            .from('fotos_perfil')
            .upload(
              filePath,
              imageFile,
              fileOptions: const FileOptions(upsert: true),
            );
        fotoUrl = _supabase.storage.from('fotos_perfil').getPublicUrl(filePath);
      }

      await _supabase
          .from('usuarios')
          .update({
            'email': email,
            'nome': name,
            'telefone': phone,
            if (fotoUrl != null) 'foto_url': fotoUrl,
            if(vehicleId != null) 'fk_vehicle': vehicleId,
            'criado_em': DateTime.now().toIso8601String(),
            'xp': 0,
            'is_special_user': false,
          })
          .eq('id', user.id);

      _utilsService.showToast(message: 'Cadastro realizado com sucesso!');
      return true;
    } on AuthException catch (e) {
      _utilsService.showToast(message: "Erro no Cadastro: ${e.message}");
      return false;
    } catch (e) {
      _utilsService.showToast(
        message: "Ocorreu um erro inesperado ao salvar o perfil",
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if(response.user != null){
        _updateUser(response.user);
      }
      
      return response.user != null;
    } on AuthException catch (e) {
      _utilsService.showToast(message: "Erro no Login: '${e.message}");
      return false;
    } catch (e) {
      _utilsService.showToast(message: "Ocorreu um erro inesperado.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _supabase.auth.signOut();
    } catch (e) {
      _utilsService.showToast(message: 'Não foi possível encerrar a sessão.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      await _supabase.auth.resetPasswordForEmail(email);
      _utilsService.showToast(
        message: 'E-mail de recuperação enviado com sucesso!',
      );
      Get.back();
    } on AuthException catch (e) {
      _utilsService.showToast(message: 'Erro: ${e.message}', isError: true);
    } catch (e) {
      _utilsService.showToast(
        message: 'Não foi possível enviar o e-mail de recuperação.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
