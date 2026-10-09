// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
  id: json['id'] as String?,
  name: json['name'] as String?,
  licensePlate: json['license_plate'] as String?,
  fuelType: json['fuel_type'] as String?,
  imagem: json['imagem'] as String?,
  tankCapacityLiters: VehicleModel._toDouble(json['tank_capacity_liters']),
  odometer: VehicleModel._toDouble(json['initial_odometer']),
);

Map<String, dynamic> _$VehicleModelToJson(VehicleModel instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': instance.name,
      'license_plate': instance.licensePlate,
      'fuel_type': instance.fuelType,
      'imagem': instance.imagem,
      'tank_capacity_liters': instance.tankCapacityLiters,
      'initial_odometer': instance.odometer,
    };
