// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_gas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypeGas _$TypeGasFromJson(Map<String, dynamic> json) => TypeGas(
  id: json['pk_tipo'] as String?,
  name: json['nome'] as String?,
  abbr: json['abbr'] as String?,
  octane: TypeGas._toDouble(json['octane_rating']),
);

Map<String, dynamic> _$TypeGasToJson(TypeGas instance) => <String, dynamic>{
  'pk_tipo': ?instance.id,
  'nome': instance.name,
  'abbr': instance.abbr,
  'octane_rating': instance.octane,
};
