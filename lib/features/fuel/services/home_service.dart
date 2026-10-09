import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker/core/models/fuel_model.dart';
import 'package:fuel_tracker/core/models/station_model.dart';
import 'package:fuel_tracker/core/models/type_gas.dart';
import 'package:fuel_tracker/core/models/vehicle_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<File> _getCacheFile(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/cache_$name.json');
  }

  Future<void> saveLocalCache(String name, dynamic data) async {
    try{
      final file = await _getCacheFile(name);
      await file.writeAsString(jsonEncode(data));
    }catch(e){
      debugPrint('Erro ao salvar cache ($name)');
    }
  }

  Future<Map<String, dynamic>?> loadLocalCache() async {
    try{
      final veiculosFile = await _getCacheFile('vehicles');
      final postosFile = await _getCacheFile('postos');
      final tiposFile = await _getCacheFile('tipo_combustivel');
      final fuelsFile = await _getCacheFile('fuelings');

      if(!veiculosFile.existsSync() || !postosFile.existsSync() || !tiposFile.existsSync()){
        return null;
      }

      final veiculosRaw = jsonDecode(await veiculosFile.readAsString()) as List;
      final postosRaw = jsonDecode(await postosFile.readAsString()) as List;
      final tiposRaw = jsonDecode(await tiposFile.readAsString()) as List;
      List fuelsRaw = [];
      if(await fuelsFile.exists()){
        fuelsRaw = jsonDecode(await fuelsFile.readAsString()) as List;
      }
      

      return {
        'veiculos': veiculosRaw.map((v) => VehicleModel.fromJson(Map<String, dynamic>.from(v))).toList(),
        'postos': postosRaw.map((v) => StationModel.fromJson(Map<String, dynamic>.from(v))).toList(),
        'tipos': tiposRaw.map((v) => TypeGas.fromJson(Map<String, dynamic>.from(v))).toList(),
        'fuelEntries': fuelsRaw.map((v) => FuelModel.fromJson(Map<String, dynamic>.from(v))).toList(),
        'veiculosRaw': veiculosRaw,
        'postosRaw': postosRaw,
        'tiposRaw': tiposRaw,
      };
      
    }catch(e){
      debugPrint('Erro ao carregar cache local: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> fetchStaticData() async {
    final results = await Future.wait([
      _supabase.from('vehicles').select(),
      _supabase.from('postos').select(),
      _supabase.from('tipo_combustivel').select(),
    ]);

    await saveLocalCache('vehicles', results[0]);
    await saveLocalCache('postos', results[1]);
    await saveLocalCache('tipo_combustivel', results[2]);

    final veiculos = (results[0] as List)
      .map((v) => VehicleModel.fromJson(Map<String, dynamic>.from(v)))
      .toList();

    final postos = (results[1] as List)
      .map((p) => StationModel.fromJson(Map<String, dynamic>.from(p)))
      .toList();

    final tipos = (results[2] as List)
      .map((t) => TypeGas.fromJson(Map<String, dynamic>.from(t)))
      .toList();

    return {
      'veiculos': veiculos,
      'postos': postos,
      'tipos': tipos,
      'veiculosRaw': results[0] as List,
      'postosRaw': results[1] as List,
      'tiposRaw': results[2] as List,
    };
  }

  Stream<List<Map<String, dynamic>>>? getFuelStream(){
    final userUID = _supabase.auth.currentUser?.id;
    if(userUID == null) return null;

    return _supabase
    .from('fuelings')
    .stream(primaryKey: ['pk_fuel'])
    .eq('fk_usuario', userUID)
    .order('data', ascending: false);
  }

  Future<bool> saveFuel(Map<String, dynamic> data) async {
    try{
      await _supabase.from('fuelings').insert(data);
      return true;
    }catch(e){
      await _enqueueOfflineAction('INSERT', 'abastecimentos', data);
      return false;
    }
  }
  
  Future<bool> updateFuel(FuelModel data) async {
    if(data.id == null) return false;
    try{
      await _supabase.from('fuelings').update(data.toJson()).eq('pk_fuel', data.id!);
      return true;
    }catch(e){
      await _enqueueOfflineAction('UPDATE', 'abastecimentos', data.toJson());
      return false;
    }
  }
  
  Future<bool> deleteFuel(String id) async {
    try{
      await _supabase.from('fuelings').delete().eq('pk_fuel', id);
      return true;
    }catch(e){
      await _enqueueOfflineAction('DELETE', 'abastecimentos', {'pk_fuel': id});
      return false;
    }
  }

  
  
  Future<File> get _queueFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/sync_queue.json');
  }

  Future<void> _enqueueOfflineAction(String action, String table, Map<String, dynamic> data) async {
    try{
      final file = await _queueFile;
      List queue = [];
      if(await file.exists()){
        queue = jsonDecode(await file.readAsString());
      }
      queue.add({
        'action': action,
        'table': table,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      await file.writeAsString(jsonEncode(queue));
    }catch(e){
      debugPrint('Erro ao adicionar item na file offline: $e');
    }
  }

  Future<void> syncPendingQueue() async {
    try{
      final file = await _queueFile;
      if(!await file.exists()) return;
      List queue = jsonDecode(await file.readAsString());
      if(queue.isEmpty) return;
      List remainingQueue = [];

      for(var item in queue){
        try{
          String action = item['action'];
          String table = item['table'];
          Map<String, dynamic> data = Map<String, dynamic>.from(item['data']);

          if(action == 'INSERT'){
            await _supabase.from(table).insert(data);
          } else if(action == 'UPDATE'){
            String pk = data.containsKey('pk_fuel') ? 'pk_fuel' : 'id';
            await _supabase.from(table).update(data).eq(pk, data[pk]);
          }else if(action == 'DELETE'){
            String pk = data.containsKey('pk_fuel') ? 'pk_fuel' : 'id';
            await _supabase.from(table).delete().eq(pk, data[pk]);
          }
        }catch(e){
          remainingQueue.add(item);
        }
      }

      if(remainingQueue.isEmpty){
        await file.delete();
      }else{
        await file.writeAsString(jsonEncode(remainingQueue));
      }
    }catch(e){
      debugPrint('Erro ao processar sincronização offline: $e');
    }
  }

  Stream<List<Map<String, dynamic>>>? getVehicleStream(){
    final userUID = _supabase.auth.currentUser?.id;
    if(userUID == null) return null;

    return _supabase
      .from('vehicles')
      .stream(primaryKey: ['id'])
      .eq('user_id', userUID);
  }

  Future<void> updateUserVehicle(String userId, String vehicleId) async {
    await _supabase.from('usuarios').update({'fk_vehicle': vehicleId}).eq('id', userId);

  }

  Future<void> deleteVehicle(String vehicleId) async {
    try{
      await _supabase.from('usuarios').update({'fk_vehicle': null}).eq('fk_vehicle', vehicleId);
      await _supabase.from('vehicles').delete().eq('id', vehicleId);
    }catch(e){
      print('Erro ao deletar veículo: $e');
      rethrow;
    }
  }
}