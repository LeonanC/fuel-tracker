
import 'package:json_annotation/json_annotation.dart';

part 'fuel_model.g.dart';

@JsonSerializable(explicitToJson: true)
class FuelModel {
  @JsonKey(name: 'pk_fuel', includeIfNull: false)
  final String? id;
  @JsonKey(name: 'fk_usuario')
  final String user;
  @JsonKey(name: 'fk_veiculo')
  final String vehicleId;
  @JsonKey(name: 'fk_tipo')
  final String fuelTypeId;
  @JsonKey(name: 'fk_posto')
  final String gasStationId;
  @JsonKey(name: 'data')
  final DateTime? entryDate;
  @JsonKey(name: 'velocimetro', toJson: _toDouble)
  final double odometerKm;
  @JsonKey(name: 'litros_volume', toJson: _toDouble)
  final double volumeLiters;
  @JsonKey(name: 'preco_litro', toJson: _toDouble)
  final double pricePerLiter;
  @JsonKey(name: 'custo_total', toJson: _toDouble)
  final double totalCost;
  @JsonKey(name: 'shared_with')
  final List<String> sharedWith;
  @JsonKey(name: 'is_full_tank', toJson: _toBool)
  final bool isFullTank;

  FuelModel({
    this.id,
    required this.user,
    required this.vehicleId,
    required this.fuelTypeId,
    required this.gasStationId,
    required this.entryDate,
    required this.odometerKm,
    required this.volumeLiters,
    required this.pricePerLiter,
    required this.totalCost,
    this.isFullTank = false,
    this.sharedWith = const [],
  });

  double calculateConsumption(FuelModel previousEntry){
    if(odometerKm <= previousEntry.odometerKm || volumeLiters <= 0) return 0.0;
    final double distanceTraveled = (odometerKm - previousEntry.odometerKm).toDouble();
    return distanceTraveled / volumeLiters;
  }

  static double? _toDouble(dynamic value){
    if(value == null) return null;
    if(value is num) return value.toDouble();
    if(value is String)  return double.tryParse(value);
    return null;
  }

  static bool? _toBool(dynamic value){
    if(value == null) return null;
    if(value is bool) return value;
    if(value is num) return value == 1;
    if(value is String){
      if(value == '1' || value.toLowerCase() == 'true') return true;
      if(value == '0' || value.toLowerCase() == 'false') return false;
    }
    return null;
  }

  factory FuelModel.fromJson(Map<String, dynamic> json) => _$FuelModelFromJson(json);

  Map<String, dynamic> toJson() => _$FuelModelToJson(this);
}