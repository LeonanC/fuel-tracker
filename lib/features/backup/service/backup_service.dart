import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackupService {
  final _supabase = Supabase.instance.client;
  final _utilsService = UtilsService();

  Future<bool> exportarBackupPDF() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final userEmail = _supabase.auth.currentUser?.email ?? 'Usuário';
      if (userId == null) throw Exception("Usuário não autenticado.");

      final vehicle = await _supabase
          .from('vehicles')
          .select()
          .eq('user_id', userId);
      final fuels = await _supabase
          .from('fuelings')
          .select()
          .eq('fk_usuario', userId);
      final maintenances = await _supabase
          .from('maintenances')
          .select()
          .eq('fk_usuario', userId);

      double totalGastoAbastecimento = 0;
      for (var f in fuels) {
        totalGastoAbastecimento += (f['custo_total'] ?? f['preco_litro'] ?? 0)
            .toDouble();
      }
      double totalGastoManutencao = 0;
      for (var f in fuels) {
        totalGastoManutencao += (f['custo_total'] ?? f['valor'] ?? 0)
            .toDouble();
      }
      double totalGastoGeral = totalGastoAbastecimento + totalGastoManutencao;

      double totalLitros = 0;
      for (var f in fuels) {
        var litros = f['litros_volume'] ?? 0;
        totalLitros += (litros is num)
            ? litros.toDouble()
            : (double.tryParse(litros.toString()) ?? 0.0);
      }

      double precoMedioLitro = totalLitros > 0
          ? (totalGastoAbastecimento / totalLitros)
          : 0;

      final pdf = pw.Document();
      final primaryColor = PdfColor.fromHex('#0F172A');
      final accentColor = PdfColor.fromHex('#0284C7');
      final lightBg = PdfColor.fromHex('#F8FAFC');
      final textColor = PdfColor.fromHex('#334155');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: pw.EdgeInsets.only(top: 20),
              child: pw.Text(
                'Página ${context.pageNumber} de ${context.pagesCount}',
                style: pw.TextStyle(color: PdfColors.grey600, fontSize: 9),
              ),
            );
          },
          build: (pw.Context context) {
            return [
              pw.Container(
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Fuel Tracker',
                          style: pw.TextStyle(
                            color: PdfColors.cyan300,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Relatório Gerencial e Backup de Dados',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Emissão',
                          style: pw.TextStyle(
                            color: PdfColors.grey400,
                            fontSize: 8,
                          ),
                        ),
                        pw.Text(
                          DateTime.now().toString().split('.')[0],
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Titular: $userEmail',
                          style: pw.TextStyle(color: textColor, fontSize: 10),
                        ),
                        pw.Text(
                          'ID Usuário: $userId',
                          style: pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Visão Geral de Dados',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                        fontSize: 14,
                      ),
                    ),
                    pw.Row(
                      children: [
                        _buildStatCard(
                          'Veículos',
                          '${vehicle.length}',
                          accentColor,
                        ),
                        pw.SizedBox(width: 10),
                        _buildStatCard(
                          'Abastecimentos',
                          '${fuels.length}',
                          PdfColors.green700,
                        ),
                        pw.SizedBox(width: 10),
                        _buildStatCard(
                          'Manutenções',
                          '${maintenances.length}',
                          PdfColors.orange800,
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Veículos Cadastrados',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                        fontSize: 13,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    vehicle.isEmpty
                        ? pw.Text(
                            'Nenhum veículo cadastrado.',
                            style: pw.TextStyle(fontSize: 10),
                          )
                        : pw.Table.fromTextArray(
                            headers: [
                              'Nome',
                              'Placa',
                              'Tanque',
                              'Tipo de Combustível',
                              'Odômetro',
                            ],
                            data: vehicle
                                .map(
                                  (v) => [
                                    v['name'],
                                    v['license_plate'] ?? '-',
                                    '${v['tank_capacity_liters'] ?? '-'}',
                                    v['fuel_type'] ?? '-',
                                    '${v['initial_odometer'] ?? '-'}',
                                  ],
                                )
                                .toList(),
                            headerStyle: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                              fontSize: 10,
                            ),
                            headerDecoration: pw.BoxDecoration(
                              color: accentColor,
                            ),
                            rowDecoration: pw.BoxDecoration(
                              color: PdfColors.grey100,
                            ),
                            cellStyle: pw.TextStyle(fontSize: 9),
                          ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Resumo Financeiro e Registros',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                        fontSize: 13,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Table.fromTextArray(
                      headers: [
                        'Categoria / Indicador',
                        'Total de Lançamentos',
                        'Gasto Total Estimado',
                      ],
                      data: [
                        [
                          'Abastecimentos de Combustível',
                          '${fuels.length}',
                          _utilsService.formatarCurrency(
                            totalGastoAbastecimento,
                          ),
                        ],
                        [
                          'Serviços e Manutenções',
                          '${maintenances.length}',
                          _utilsService.formatarCurrency(totalGastoManutencao),
                        ],
                        [
                          'Média de Preço / Litro',
                          '${_utilsService.formatarVolume(totalLitros)} abastecidos',
                          '${_utilsService.formatarCurrency(precoMedioLitro)} / L',
                        ],
                        [
                          'Total Geral de Custos',
                          '${fuels.length + maintenances.length} registros',
                          _utilsService.formatarCurrency(totalGastoGeral),
                        ],
                      ],
                      headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        fontSize: 10,
                      ),
                      headerDecoration: pw.BoxDecoration(color: primaryColor),
                      rowDecoration: pw.BoxDecoration(color: PdfColors.grey50),
                      cellStyle: pw.TextStyle(fontSize: 9),
                    ),
                    pw.SizedBox(height: 30),
                    pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                    pw.Center(
                      child: pw.Text(
                        'Este documento serve como relatório de conferência e histórico dos seus dados no Fuel Tracker.',
                        style: pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      final pdfBytes = await pdf.save();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name:
            'relatorio_fuel_tracker_(${DateTime.now().millisecondsSinceEpoch}.pdf)',
      );

      return true;
    } catch (e) {
      debugPrint('Erro ao carregar cache local: $e');
      return false;
    }
  }

  static pw.Widget _buildStatCard(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: pw.EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: color, width: 1.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> exportarBackup() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("Usuário não autenticado.");

      final vehicle = await _supabase
          .from('vehicles')
          .select()
          .eq('user_id', userId);
      final fuels = await _supabase
          .from('fuelings')
          .select()
          .eq('fk_usuario', userId);
      final maintenances = await _supabase
          .from('maintenances')
          .select()
          .eq('fk_usuario', userId);

      final backupData = {
        'version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'user_id': userId,
        'data': {
          'vehicles': vehicle,
          'fuelings': fuels,
          'maintenances': maintenances,
        },
      };

      final jsonString = jsonEncode(backupData);
      final tempDir = await getTemporaryDirectory();
      final fileName =
          "backup_fuel_tracker_${DateTime.now().millisecondsSinceEpoch}.json";
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);
      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: 'Seu backup do Fuel Tracker');

      return true;
    } catch (e) {
      debugPrint('Erro ao exportar backup: $e');
      return false;
    }
  }

  Future<bool> importarBackup() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("Usuário não autenticado.");

      List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if(result.isEmpty || result.single.path == null){
        return false;
      }

      final PlatformFile pickedFile = result.single;

      File file = File(pickedFile.path!);
      String jsonContent = await file.readAsString();
      Map<String, dynamic> backupData = jsonDecode(jsonContent);

      if(!backupData.containsKey('data')){
        throw Exception('Formato de arquivo de backup inválido.');
      }

      final data = backupData['data'];

      final veiculosList = data['vehicles'] ?? data['veiculos'];
      if(veiculosList != null && (veiculosList as List).isNotEmpty){
        final List<Map<String, dynamic>> veiculos = List<Map<String, dynamic>>.from(veiculosList);
        for(var v in veiculos){
          v['user_id'] = userId;
        }
        await _supabase.from('vehicles').upsert(veiculos);
      }

      if(data['fuelings'] != null && (data['fuelings'] as List).isNotEmpty){
        final List<Map<String, dynamic>> abastecimentos = List<Map<String, dynamic>>.from(data['fuelings']);
        for(var v in abastecimentos){
          v['user_id'] = userId;
        }
        await _supabase.from('fuelings').upsert(abastecimentos);
      }

      if(data['maintenances'] != null && (data['maintenances'] as List).isNotEmpty){
        final List<Map<String, dynamic>> maintenances = List<Map<String, dynamic>>.from(data['maintenances']);
        for(var v in maintenances){
          v['user_id'] = userId;
        }
        await _supabase.from('maintenances').upsert(maintenances);
      }



      return true;
    } catch (e) {
      debugPrint('Erro ao importar backup: $e');
      return false;
    }
  }
}
