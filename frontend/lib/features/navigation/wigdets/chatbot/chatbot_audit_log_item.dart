import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/models/chatbot_audit_log_models.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChatbotAuditLogItem extends StatelessWidget {
  final AuditLogEntry log;

  const ChatbotAuditLogItem({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final cfg = AuditLogHelper.getActionConfig(log.action);
    final entityLabel = AuditLogHelper.getEntityLabel(log.entityType);

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
}

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
