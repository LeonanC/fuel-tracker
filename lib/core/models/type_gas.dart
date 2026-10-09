
import 'package:json_annotation/json_annotation.dart';

part 'type_gas.g.dart';

@JsonSerializable()
class TypeGas {
  @JsonKey(name: 'pk_tipo', includeIfNull: false)
  String? id;
  @JsonKey(name: 'nome')
  String? name;
  @JsonKey(name: 'abbr')
  String? abbr;
  @JsonKey(name: 'octane_rating', fromJson: _toDouble)
  double? octane;

  TypeGas({
    this.id,
    this.name,
    this.abbr,
    this.octane,
  });

  static double? _toDouble(dynamic value){
    if(value == null) return null;
    if(value is num) return value.toDouble();
    if(value is String)  return double.tryParse(value);
    return null;
  }

  factory TypeGas.fromJson(Map<String, dynamic> json) => _$TypeGasFromJson(json);

  Map<String, dynamic> toJson() => _$TypeGasToJson(this);
}