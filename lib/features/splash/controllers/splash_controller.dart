import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:fuel_tracker/core/network/app_router.dart';
import 'package:fuel_tracker/features/auth/controllers/auth_controller.dart';
import 'package:fuel_tracker/features/fuel/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashController extends GetxController {
  final _supabase = Supabase.instance.client;

  var progresso = 0.obs;
  var statusMensagem = 'Ligando ignição...'.obs;
  var temErro = false.obs;

  Timer? _timer;
  bool _dadosCarregados = false;
  bool _navegou = false;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    inicializarApp();
  }

  void _iniciarProgressoSimulado() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (progresso.value < 95) {
        progresso.value++;
      }
    });
  }

  Future<void> inicializarApp() async {
    try {
      _iniciarProgressoSimulado();

      statusMensagem.value = "Autenticando motorista...";
      await Future.delayed(const Duration(milliseconds: 50));
      final session = _supabase.auth.currentSession;

      if (session == null) {
        statusMensagem.value = "Usuário não identificado. Indo para login...";
        await Future.delayed(const Duration(milliseconds: 50));
        _concluirEChamarNavegacao(forcar100: true);
        return;
      }

      statusMensagem.value = "Carregando dados registrados...";
      await Get.find<HomeController>().fetchData();

      statusMensagem.value = "Sincronizando postos e veículos...";
      await Future.delayed(const Duration(milliseconds: 50));

      _concluirEChamarNavegacao(forcar100: true);
    } catch (e) {
      _timer?.cancel();
      temErro.value = true;
      statusMensagem.value = "Erro ao sincronizar: $e";
    }
  }

  void _concluirEChamarNavegacao({bool forcar100 = false}) {
    if (_navegou) return;
    _navegou = true;
    _timer?.cancel();

    if (forcar100) {
      progresso.value = 100;
    }

    statusMensagem.value = "Boa Viagem, motorista!";

    Future.delayed(const Duration(milliseconds: 50), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final session = _supabase.auth.currentSession;
        if (session != null || _authController.isAuthenticated) {
          Get.offAllNamed(PagesRoutes.mainRoute);
        } else {
          Get.offAllNamed(PagesRoutes.signInRoute);
        }
      });
    });
  }

  void tentarNovamente() {
    temErro.value = false;
    progresso.value = 0;
    _dadosCarregados = false;
    _navegou = false;
    statusMensagem.value = "Reiniciando sistema...";
    inicializarApp();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
