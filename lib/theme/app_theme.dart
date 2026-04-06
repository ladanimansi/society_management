import 'package:flutter/material.dart';
import 'color.dart';

abstract class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          brightness: Brightness.light,
        ).copyWith(
          onSurface: AppColors.textColor,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textColor),
          bodyMedium: TextStyle(color: AppColors.textColor),
          bodySmall: TextStyle(color: AppColors.textColor),
          labelLarge: TextStyle(color: AppColors.textColor),
          titleMedium: TextStyle(color: AppColors.textColor),
          titleLarge: TextStyle(color: AppColors.textColor),
          headlineMedium: TextStyle(color: AppColors.textColor),
        ),
      );
}
