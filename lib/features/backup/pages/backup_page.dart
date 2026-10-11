import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/features/backup/controllers/backup_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class BackupPage extends GetView<BackupController> {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('Gerenciamento de Dados', theme),
                SizedBox(height: 12.h),
                _buildBackupTile(
                  theme: theme,
                  icon: RemixIcons.file_pdf_line,
                  title: 'Exportar Backup em PDF',
                  subtitle:
                      'Gere um arquivo PDF com todos os seus dados. Você pode salvar no Google Drive ou enviar por e-mail.',
                  onTap: () => controller.exportBackupPDF(),
                ),
                SizedBox(height: 14.h),
                _buildBackupTile(
                  theme: theme,
                  icon: RemixIcons.upload_cloud_line,
                  title: 'Exportar Backup',
                  subtitle:
                      'Gere um arquivo JSON com todos os seus dados. Você pode salvar no Google Drive ou enviar por e-mail.',
                  onTap: () => controller.exportBackup(),
                ),
                SizedBox(height: 14.h),
                _buildBackupTile(
                  theme: theme,
                  icon: RemixIcons.download_cloud_line,
                  title: 'Restaurar Backup',
                  subtitle:
                      'Selecione um arquivo .json de backup gerado anteriormente para restaurar seu histórico no aplicativo.',
                  onTap: () => controller.importBackup(),
                ),
              ]),
            ),
          ),
          SliverPadding(padding: EdgeInsets.only(bottom: 32.h)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 60.h,
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 50.w, bottom: 16.h),
        title: Text(
          'Backup & Restauração',
          style: GoogleFonts.lexend(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildBackupTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 22.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.lexend(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: GoogleFonts.lexend(
                            fontSize: 12.sp,
                            color: colorScheme.onSurface.withOpacity(0.6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Icon(
                    RemixIcons.arrow_right_s_line,
                    color: colorScheme.onSurface.withOpacity(0.3),
                    size: 18.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
