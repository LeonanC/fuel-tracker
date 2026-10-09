// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  name: json['nome'] as String?,
  email: json['email'] as String?,
  phone: json['telefone'] as String?,
  fotoUrl: json['foto_url'] as String?,
  vehicle: json['fk_vehicle'] as String?,
  password: json['password'] as String?,
  token: json['token'] as String?,
  id: json['id'] as String?,
  xp: UserModel._xpFromJson(json['xp']),
)..isSpecial = json['is_special_user'] as bool?;

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'nome': instance.name,
  'email': instance.email,
  'telefone': instance.phone,
  'foto_url': instance.fotoUrl,
  'fk_vehicle': instance.vehicle,
  'is_special_user': instance.isSpecial,
  'password': instance.password,
  'token': instance.token,
  'id': instance.id,
  'xp': instance.xp,
};
