import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/controllers/navigation_controller.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/models/chatbot_audit_log_models.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_message_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'chatbot_audit_log_item.dart';

const _kPageSize = 5;

class ChatCardAuditLog extends StatefulWidget {
  final ChatMessage message;

  const ChatCardAuditLog({super.key, required this.message});

  @override
  State<ChatCardAuditLog> createState() => _ChatCardAuditLogState();
}

class _ChatCardAuditLogState extends State<ChatCardAuditLog> {
  late final List<AuditLogEntry> _logs;
  late final int _totalItems;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    final raw = widget.message.data;

    if (raw is Map<String, dynamic> && raw['items'] is List) {
      final items = raw['items'] as List<dynamic>;
      _logs = items
          .whereType<Map<String, dynamic>>()
          .map(AuditLogEntry.fromMap)
          .toList();
      _totalItems = (raw['totalItems'] as int?) ?? _logs.length;
    } else if (raw is List) {
      _logs = raw
          .whereType<Map<String, dynamic>>()
          .map(AuditLogEntry.fromMap)
          .toList();
      _totalItems = _logs.length;
    } else {
      _logs = [];
      _totalItems = 0;
    }
  }

  int get _totalPages => (_logs.length / _kPageSize).ceil().clamp(1, 9999);

  List<AuditLogEntry> get _currentSlice {
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
                Text(
                  TTexts.chatbotPromptAuditLog.tr.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.subText,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${TTexts.resultsFound.tr}: $start–$end / $_totalItems',
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

          // 3. Danh sách log (Gọi widget từ file kia)
          ..._currentSlice.map((log) => ChatbotAuditLogItem(log: log)),

          // 4. Phân trang
          if (_totalPages > 1) ...[
            const SizedBox(height: 4),
            _buildPagination(),
          ],

          // 5. Nút View Full List
          const SizedBox(height: 8),
          Center(
            child: InkWell(
              onTap: () {
                if (Get.isRegistered<ChatbotUiController>()) {
                  Get.find<ChatbotUiController>().closeChat();
                }
                if (Get.isRegistered<NavigationController>()) {
                  Get.find<NavigationController>().selectedIndex.value = 3;
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  TTexts.chatbotViewFullList.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
