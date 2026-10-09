// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FuelModel _$FuelModelFromJson(Map<String, dynamic> json) => FuelModel(
  id: json['pk_fuel'] as String?,
  user: json['fk_usuario'] as String,
  vehicleId: json['fk_veiculo'] as String,
  fuelTypeId: json['fk_tipo'] as String,
  gasStationId: json['fk_posto'] as String,
  entryDate: json['data'] == null
      ? null
      : DateTime.parse(json['data'] as String),
  odometerKm: (json['velocimetro'] as num).toDouble(),
  volumeLiters: (json['litros_volume'] as num).toDouble(),
  pricePerLiter: (json['preco_litro'] as num).toDouble(),
  totalCost: (json['custo_total'] as num).toDouble(),
  isFullTank: json['is_full_tank'] as bool? ?? false,
  sharedWith:
      (json['shared_with'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$FuelModelToJson(FuelModel instance) => <String, dynamic>{
  'pk_fuel': ?instance.id,
  'fk_usuario': instance.user,
  'fk_veiculo': instance.vehicleId,
  'fk_tipo': instance.fuelTypeId,
  'fk_posto': instance.gasStationId,
  'data': instance.entryDate?.toIso8601String(),
  'velocimetro': FuelModel._toDouble(instance.odometerKm),
  'litros_volume': FuelModel._toDouble(instance.volumeLiters),
  'preco_litro': FuelModel._toDouble(instance.pricePerLiter),
  'custo_total': FuelModel._toDouble(instance.totalCost),
  'shared_with': instance.sharedWith,
  'is_full_tank': FuelModel._toBool(instance.isFullTank),
};
