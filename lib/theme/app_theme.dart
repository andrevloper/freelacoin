// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primária — verde
  static const primary      = Color(0xFF16A34A);
  static const primaryLight = Color(0xFFDCFCE7);
  static const primaryDark  = Color(0xFF15803D);

  // Secundária — teal (pago/confirmado)
  static const secondary      = Color(0xFF0D9488);
  static const secondaryLight = Color(0xFFCCFBF1);

  // Accent — âmbar (pendente/atenção)
  static const accent      = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFEF3C7);

  // Neutros
  static const bg           = Color(0xFFFFFFFF);
  static const bg2          = Color(0xFFF4F7FA);
  static const bg3          = Color(0xFFEAEEF2);
  static const textPrimary  = Color(0xFF1A2332);
  static const textSecondary= Color(0xFF5A6A7A);
  static const border       = Color(0x1A1A2332);

  // Status de projeto
  static const pendingBg    = Color(0xFFF0F0F0);
  static const pendingFg    = Color(0xFF666666);
  static const inProgressBg = Color(0xFFDCFCE7);
  static const inProgressFg = Color(0xFF15803D);
  static const reviewBg     = Color(0xFFFEF3C7);
  static const reviewFg     = Color(0xFF92400E);
  static const deliveredBg  = Color(0xFFDBEAFE);
  static const deliveredFg  = Color(0xFF1D4ED8);
  static const paidBg       = Color(0xFFCCFBF1);
  static const paidFg       = Color(0xFF0F766E);
  static const cancelledBg  = Color(0xFFFCEBEB);
  static const cancelledFg  = Color(0xFFA32D2D);

  // Categorias de serviço
  static const catDev    = Color(0xFF6366F1);
  static const catDesign = Color(0xFFEC4899);
  static const catInfra  = Color(0xFF64748B);
  static const catConsult= Color(0xFF0D9488);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg2,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.bg,
      indicatorColor: AppColors.primaryLight,
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
        fontSize: 11,
        fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
        color: s.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary,
      )),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
        color: s.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary,
      )),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 0.8)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 0.8)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 0.8),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.bg3,
      selectedColor: AppColors.primaryLight,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(
        color: AppColors.border, thickness: 0.8, space: 0),
    fontFamily: 'Roboto',
  );

  static Color categoryColor(String cat) => switch (cat) {
        'Desenvolvimento'  => AppColors.catDev,
        'Design'           => AppColors.catDesign,
        'Infraestrutura'   => AppColors.catInfra,
        'Consultoria'      => AppColors.catConsult,
        _                  => AppColors.primary,
      };

  static (Color, Color) statusColors(String status) => switch (status) {
        'Em andamento' => (AppColors.inProgressBg, AppColors.inProgressFg),
        'Revisão'      => (AppColors.reviewBg,     AppColors.reviewFg),
        'Entregue'     => (AppColors.deliveredBg,  AppColors.deliveredFg),
        'Pago'         => (AppColors.paidBg,        AppColors.paidFg),
        'Cancelado'    => (AppColors.cancelledBg,  AppColors.cancelledFg),
        _              => (AppColors.pendingBg,     AppColors.pendingFg),
      };
}
