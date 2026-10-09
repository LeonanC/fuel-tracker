
import 'package:json_annotation/json_annotation.dart';

part 'vehicle_model.g.dart';

@JsonSerializable(explicitToJson: true)
class VehicleModel {
  @JsonKey(name: 'id', includeIfNull: false)
  String? id;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'license_plate')
  String? licensePlate;

  @JsonKey(name: 'fuel_type')
  String? fuelType;

  @JsonKey(name: 'imagem')
  String? imagem;

  @JsonKey(name: 'tank_capacity_liters', fromJson: _toDouble)
  double? tankCapacityLiters;
  
  @JsonKey(name: 'initial_odometer', fromJson: _toDouble)
  double? odometer;

  VehicleModel({
    this.id,
    this.name,
    this.licensePlate,
    this.fuelType,
    this.imagem,
    this.tankCapacityLiters,
    this.odometer,
  });

  static double? _toDouble(dynamic value){
    if(value == null) return null;
    if(value is num) return value.toDouble();
    if(value is String)  return double.tryParse(value);
    return null;
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) => _$VehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);
}