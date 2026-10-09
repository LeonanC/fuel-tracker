// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StationModel _$StationModelFromJson(Map<String, dynamic> json) => StationModel(
  id: json['pk_posto'] as String?,
  name: json['nome'] as String?,
  endereco: json['endereco'] as String?,
  brand: json['brand'] as String?,
  latitude: StationModel._toDouble(json['latitude']),
  longitude: StationModel._toDouble(json['longitude']),
  precoGasolina: json['preco_gasolina'] == null
      ? 0.0
      : StationModel._toDouble(json['preco_gasolina']),
  precoEtanol: json['preco_etanol'] == null
      ? 0.0
      : StationModel._toDouble(json['preco_etanol']),
  precoDiesel: json['preco_diesel'] == null
      ? 0.0
      : StationModel._toDouble(json['preco_diesel']),
  precoGnv: json['preco_gnv'] == null
      ? 0.0
      : StationModel._toDouble(json['preco_gnv']),
  hasConvenientStore: StationModel._toBool(json['has_convenient_store']),
  is24Hours: StationModel._toBool(json['is_24_hours']),
);

Map<String, dynamic> _$StationModelToJson(StationModel instance) =>
    <String, dynamic>{
      'pk_posto': ?instance.id,
      'nome': instance.name,
      'endereco': instance.endereco,
      'brand': instance.brand,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'preco_gasolina': instance.precoGasolina,
      'preco_etanol': instance.precoEtanol,
      'preco_diesel': instance.precoDiesel,
      'preco_gnv': instance.precoGnv,
      'has_convenient_store': instance.hasConvenientStore,
      'is_24_hours': instance.is24Hours,
    };
