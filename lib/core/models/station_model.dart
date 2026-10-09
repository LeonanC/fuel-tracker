
import 'package:json_annotation/json_annotation.dart';

part 'station_model.g.dart';

@JsonSerializable()
class StationModel {
  @JsonKey(name: 'pk_posto', includeIfNull: false)
  String? id;
  @JsonKey(name: 'nome')
  String? name;
  @JsonKey(name: 'endereco')
  String? endereco;
  @JsonKey(name: 'brand')
  String? brand;
  @JsonKey(name: 'latitude', fromJson: _toDouble)
  double? latitude;
  @JsonKey(name: 'longitude', fromJson: _toDouble)
  double? longitude;
  @JsonKey(name: 'preco_gasolina', fromJson: _toDouble)
  double? precoGasolina;
  @JsonKey(name: 'preco_etanol', fromJson: _toDouble)
  double? precoEtanol;
  @JsonKey(name: 'preco_diesel', fromJson: _toDouble)
  double? precoDiesel;
  @JsonKey(name: 'preco_gnv', fromJson: _toDouble)
  double? precoGnv;
  @JsonKey(name: 'has_convenient_store', fromJson: _toBool)
  bool? hasConvenientStore;
  @JsonKey(name: 'is_24_hours', fromJson: _toBool)
  bool? is24Hours;

  StationModel({
    this.id,
    this.name,
    this.endereco,
    this.brand,
    this.latitude,
    this.longitude,
    this.precoGasolina = 0.0,
    this.precoEtanol = 0.0,
    this.precoDiesel = 0.0,
    this.precoGnv = 0.0,
    this.hasConvenientStore,
    this.is24Hours,
  });

  static double? _toDouble(dynamic value){
    if(value == null) return null;
    if(value is num) return value.toDouble();
    if(value is String)  return double.tryParse(value);
    return null;
  }

  static bool? _toBool(dynamic value){
    if(value == null) return null;
    if(value is bool) return value;
    if(value is num) return value != 0;
    if(value is String){
      if(value.toLowerCase() == 'true' || value == '1') return true;
      if(value.toLowerCase() == 'false' || value == '0') return false;
    }
    return null;
  }

  factory StationModel.fromJson(Map<String, dynamic> json) => _$StationModelFromJson(json);

  Map<String, dynamic> toJson() => _$StationModelToJson(this);
}