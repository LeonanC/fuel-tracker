import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {

  @JsonKey(name: 'nome')
  String? name;
  @JsonKey(name: 'email')
  String? email;
  @JsonKey(name: 'telefone')
  String? phone;
  @JsonKey(name: 'foto_url')
  String? fotoUrl;
  @JsonKey(name: 'fk_vehicle')
  String? vehicle;
  @JsonKey(name: 'is_special_user')
  bool? isSpecial;
  String? password;
  String? token;
  String? id;
  @JsonKey(fromJson: _xpFromJson)
  double? xp;

  @JsonKey(includeFromJson: false, includeToJson: false)
  File? fileImage;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get nome => name;
  set nome(String? value) => name = value;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get telefone => phone;
  set telefone(String? value) => phone = value;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get fkVehicle => vehicle;
  set fkVehicle(String? value) => vehicle = value;

  UserModel({
    this.name,
    this.email,
    this.phone,
    this.fotoUrl,
    this.vehicle,
    this.password,
    this.token,
    this.id,
    this.xp,
    this.fileImage,
  });

  factory UserModel.fromSupabaseUser(User user){
    final meta = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email,
      name: meta['nome'] ?? meta['full_name'] ?? user.email?.split('@').first,
      fotoUrl: meta['imagem'] ?? meta['avatar_url'],
      phone: user.phone,
    );
  }

  static double? _xpFromJson(dynamic value){
    if(value is num) return value.toDouble();
    return null;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
