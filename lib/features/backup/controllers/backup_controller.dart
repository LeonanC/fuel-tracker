import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:fuel_tracker/features/backup/service/backup_service.dart';
import 'package:get/get.dart';

class BackupController extends GetxController {
  final BackupService _backupService = BackupService();
  final UtilsService _utilsService = UtilsService();
  final RxBool isLoading = false.obs;

  Future<void> exportBackupPDF() async {
    isLoading.value = true;
    try{
      bool success = await _backupService.exportarBackupPDF();

      if(success){
        _utilsService.showToast(message: 'Relatório PDF gerado com sucesso!');
      }else{
        _utilsService.showToast(message: 'Não foi possível gerar o arquivo PDF.', isError: true);
      }
    }catch(e){
      _utilsService.showToast(message: 'Erro ao gerar o PDF: $e', isError: true);
    }finally{
      isLoading.value = false;
    }
  }
  
  Future<void> exportBackup() async {
    isLoading.value = true;
    try{
      bool success = await _backupService.exportarBackup();

      if(success){
        _utilsService.showToast(message: 'Relatório gerado com sucesso!');
      }else{
        _utilsService.showToast(message: 'Não foi possível gerar o arquivo JSON.', isError: true);
      }
    }catch(e){
      _utilsService.showToast(message: 'Erro ao gerar o JSON: $e', isError: true);
    }finally{
      isLoading.value = false;
    }
  }
  
  Future<void> importBackup() async {
    isLoading.value = true;
    try{
      bool success = await _backupService.importarBackup();

      if(success){
        _utilsService.showToast(message: 'Dados restaurados com sucesso!');
      }else{
        _utilsService.showToast(message: 'Falha ao restaurar dados. Verifique o arquivo.', isError: true);
      }
    }catch(e){
      _utilsService.showToast(message: 'Erro ao gerar o PDF: $e', isError: true);
    }finally{
      isLoading.value = false;
    }
  }

}