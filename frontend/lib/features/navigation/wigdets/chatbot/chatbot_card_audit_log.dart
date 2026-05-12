import 'package:flutter/material.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_message_widget.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// ---------------------------------------------------------------------------
// Model nội bộ – map từ Map<String, dynamic> trả về Backend
// ---------------------------------------------------------------------------
class _AuditLogEntry {
  final String action; // 'CREATE' | 'UPDATE' | 'DELETE'
  final String target; // Tên sản phẩm / mã phiếu...
  final String userFullName; // ✅ Fix: luôn lấy từ data, không hardcode
  final String time;
  final String entityType; // 'Product' | 'Transaction' | 'Inventory'...

  const _AuditLogEntry({
    required this.action,
    required this.target,
    required this.userFullName,
    required this.time,
    required this.entityType,
  });

  factory _AuditLogEntry.fromMap(Map<String, dynamic> m) => _AuditLogEntry(
        action: (m['action']?.toString() ?? 'UNKNOWN').toUpperCase(),
        target: m['target']?.toString() ?? 'Dữ liệu không xác định',
        // ✅ Fix bug: ưu tiên userFullName, fallback user.fullName, rồi mới dùng placeholder
        userFullName: m['userFullName']?.toString() ??
            m['user']?['fullName']?.toString() ??
            'Nhân viên',
        time: m['time']?.toString() ?? '',
        entityType: m['entityType']?.toString() ?? '',
      );
}

// ---------------------------------------------------------------------------
// Cấu hình hiển thị theo action
// ---------------------------------------------------------------------------
class _ActionConfig {
  final Color color;
  final IconData icon;
  final String label;
  const _ActionConfig(this.color, this.icon, this.label);
}

const _kPageSize = 5;

// ---------------------------------------------------------------------------
// Widget chính
// ---------------------------------------------------------------------------
class ChatCardAuditLog extends StatefulWidget {
  final ChatMessage message;

  const ChatCardAuditLog({super.key, required this.message});

  @override
  State<ChatCardAuditLog> createState() => _ChatCardAuditLogState();
}

class _ChatCardAuditLogState extends State<ChatCardAuditLog> {
  late final List<_AuditLogEntry> _logs;
  late final int _totalItems;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    final raw = widget.message.data;

    // Backend có thể trả Map { items: [...], totalItems: N } hoặc trực tiếp List
    if (raw is Map<String, dynamic> && raw['items'] is List) {
      final items = raw['items'] as List<dynamic>;
      _logs = items
          .whereType<Map<String, dynamic>>()
          .map(_AuditLogEntry.fromMap)
          .toList();
      _totalItems = (raw['totalItems'] as int?) ?? _logs.length;
    } else if (raw is List) {
      _logs = raw
          .whereType<Map<String, dynamic>>()
          .map(_AuditLogEntry.fromMap)
          .toList();
      _totalItems = _logs.length;
    } else {
      _logs = [];
      _totalItems = 0;
    }
  }

  int get _totalPages => (_logs.length / _kPageSize).ceil().clamp(1, 9999);

  List<_AuditLogEntry> get _currentSlice {
    final start = _page * _kPageSize;
    final end = (start + _kPageSize).clamp(0, _logs.length);
    return _logs.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    if (_logs.isEmpty) return ChatbotMessage(message: widget.message);

    final start = _page * _kPageSize + 1;
    final end = ((_page + 1) * _kPageSize).clamp(0, _logs.length);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Bong bóng Tori
          Align(
            alignment: Alignment.centerLeft,
            child: ChatbotMessage(message: widget.message),
          ),
          const SizedBox(height: 8),

          // 2. Header: nhãn + "hiển thị x–y / N"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'NHẬT KÝ THAO TÁC',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.subText,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'hiển thị $start–$end / $_totalItems',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.subText,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // 3. Danh sách log
          ..._currentSlice.map(_buildLogCard),

          // 4. Phân trang (chỉ hiện khi có > 1 trang)
          if (_totalPages > 1) ...[
            const SizedBox(height: 4),
            _buildPagination(),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Một thẻ log
  // -------------------------------------------------------------------------
  Widget _buildLogCard(_AuditLogEntry log) {
    final cfg = _actionConfig(log.action);
    final entityLabel = _entityLabel(log.entityType);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon tròn bo nhẹ
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cfg.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(cfg.icon, color: cfg.color, size: 17),
          ),
          const SizedBox(width: 10),

          // Nội dung giữa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên target
                Text(
                  log.target,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),

                // Người thao tác + entityType chip
                Row(
                  children: [
                    const Icon(Iconsax.user,
                        size: 11, color: AppColors.subText),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        log.userFullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    if (entityLabel.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _EntityChip(label: entityLabel),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Cột phải: badge + thời gian
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ActionBadge(label: cfg.label, color: cfg.color),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Iconsax.clock, size: 11, color: Colors.grey.shade400),
                  const SizedBox(width: 3),
                  Text(
                    log.time,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Phân trang
  // -------------------------------------------------------------------------
  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Trang ${_page + 1} / $_totalPages',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.subText,
            fontFamily: 'Poppins',
          ),
        ),
        Row(
          children: [
            _PageButton(
              icon: Iconsax.arrow_left_2,
              enabled: _page > 0,
              onTap: () => setState(() => _page--),
            ),
            const SizedBox(width: 6),
            _PageButton(
              icon: Iconsax.arrow_right_3,
              enabled: _page < _totalPages - 1,
              onTap: () => setState(() => _page++),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
  _ActionConfig _actionConfig(String action) {
    switch (action) {
      case 'CREATE':
        return const _ActionConfig(
            AppColors.stockIn, Iconsax.add_circle, 'Tạo mới');
      case 'UPDATE':
        return const _ActionConfig(
            AppColors.primary, Iconsax.edit_2, 'Cập nhật');
      case 'DELETE':
        return const _ActionConfig(AppColors.stockOut, Iconsax.trash, 'Xóa');
      default:
        return const _ActionConfig(
            Colors.grey, Iconsax.info_circle, 'Thao tác');
    }
  }

  String _entityLabel(String entityType) {
    const map = {
      'Product': 'Sản phẩm',
      'ProductPackage': 'Gói SP',
      'Inventory': 'Kho hàng',
      'Transaction': 'Giao dịch',
      'Category': 'Danh mục',
      'User': 'Nhân viên',
    };
    return map[entityType] ?? entityType;
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ActionBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _ActionBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _EntityChip extends StatelessWidget {
  final String label;
  const _EntityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.subText,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black.withOpacity(0.1)),
          ),
          child: Icon(icon, size: 15, color: AppColors.primaryText),
        ),
      ),
    );
  }
}
