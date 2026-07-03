import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 主色调 - 豆绿色系
  static const Color primary = Color(0xFF6B8E23);       // 橄榄绿
  static const Color primaryLight = Color(0xFF9ACD32);   // 黄绿
  static const Color primaryDark = Color(0xFF556B2F);    // 暗橄榄绿

  // 辅助色
  static const Color accent = Color(0xFFFF8C00);         // 橙色
  static const Color warning = Color(0xFFFF4500);        // 警告红
  static const Color success = Color(0xFF32CD32);        // 成功绿
  static const Color info = Color(0xFF4682B4);           // 信息蓝

  // 低量预警色
  static const Color lowStock = Color(0xFFFF6B6B);       // 浅红
  static const Color lowStockBg = Color(0xFFFFE4E1);     // 浅红背景

  // 卡片默认背景
  static const Color cardBg = Color(0xFFF5F5F5);
  static const Color cardBgDark = Color(0xFF2C2C2C);
}
