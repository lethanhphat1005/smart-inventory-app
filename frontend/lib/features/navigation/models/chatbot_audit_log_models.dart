import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AuditLogEntry {
  final String action;
  final String target;
  final String userFullName;
  final String time;
  final String entityType;

  const AuditLogEntry({
    required this.action,
    required this.target,
    required this.userFullName,
    required this.time,
    required this.entityType,
  });

  factory AuditLogEntry.fromMap(Map<String, dynamic> m) => AuditLogEntry(
        action: (m['action']?.toString() ?? 'UNKNOWN').toUpperCase(),
        target: m['target']?.toString() ?? TTexts.unknownProduct.tr,
        userFullName: m['userFullName']?.toString() ??
            m['user']?['fullName']?.toString() ??
            TTexts.userLabel.tr,
        time: m['time']?.toString() ?? '',
        entityType: m['entityType']?.toString() ?? '',
      );
}

class AuditLogActionConfig {
  final Color color;
  final IconData icon;
  final String label;

  const AuditLogActionConfig(this.color, this.icon, this.label);
}

class AuditLogHelper {
  static AuditLogActionConfig getActionConfig(String action) {
    switch (action) {
      case 'CREATE':
        return const AuditLogActionConfig(AppColors.stockIn, Iconsax.add_circle,
            'Tạo mới'); // Có thể thay bằng TTexts.xxx.tr sau này
      case 'UPDATE':
        return const AuditLogActionConfig(
            AppColors.primary, Iconsax.edit_2, 'Cập nhật');
      case 'DELETE':
        return const AuditLogActionConfig(
            AppColors.stockOut, Iconsax.trash, 'Xóa');
      default:
        return const AuditLogActionConfig(
            Colors.grey, Iconsax.info_circle, 'Thao tác');
    }
  }

  static String getEntityLabel(String entityType) {
    const map = {
      'Product': 'Product',
      'ProductPackage': 'Package',
      'Inventory': 'Inventory',
      'Transaction': 'Transaction',
      'Category': 'Category',
      'User': 'Staff',
    };
    return map[entityType] ?? entityType;
  }
}
