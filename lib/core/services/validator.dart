import 'package:get/get.dart';

String? nameValidator(String? nome){
  if(nome == null || nome.isEmpty){
    return 'Digite seu nome!';
  }
  final nomes = nome.split(' ');
  if(nomes.length == 1) return 'Digite seu nome completo!';
  return null;
}

String? phoneValidator(String? phone){
  if(phone == null || phone.isEmpty){
    return 'Digite um celular!';
  }

  if(phone.length < 14 || !phone.isPhoneNumber) {
    return 'Digite um número válido!';
  }
  return null;
}

String? emailValidator(String? email){
  if(email == null || email.isEmpty){
    return 'Digite seu email';
  }
  if(!email.isEmail) return 'Digite um email válido!';
  return null;
}

String? passwordValidator(password){
  if(password == null || password.isEmpty){
    return 'Digite sua senha!';
  }
  if(password.length < 7) {
    return 'Digite uma senha com pelo menos 7 caracteres.';
  }
  return null;
}