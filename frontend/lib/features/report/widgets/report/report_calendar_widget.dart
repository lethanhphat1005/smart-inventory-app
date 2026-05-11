import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class ReportCalendarWidget extends GetView<ReportController> {
  const ReportCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentFocusedDay = controller.focusedDay.value;
      final currentSelectedDay = controller.selectedDay.value;
      final _ = controller.allTransactions.length;

      final currentLocale =
          Get.locale?.languageCode == 'vi' ? 'vi_VN' : 'en_US';

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TableCalendar<TransactionModel>(
          locale: currentLocale,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: currentFocusedDay,
          currentDay: DateTime.now(),
          selectedDayPredicate: (day) =>
              controller.isSameDay(currentSelectedDay, day),
          onDaySelected: controller.onDaySelected,

          // Lấy danh sách event cho từng ngày
          eventLoader: controller.getTransactionsForDay,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            // Ẩn text style mặc định đi vì mình tự vẽ ở dưới rồi
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle),
            selectedDecoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            markerSize: 6,
          ),
          calendarBuilders: CalendarBuilders(
            // --- LOGIC MỚI: TỰ VẼ HEADER ĐỂ ÉP VIẾT HOA ---
            headerTitleBuilder: (context, day) {
              // Lấy chuỗi ngày tháng ("tháng 5 năm 2026" hoặc "May 2026")
              String text = DateFormat.yMMMM(currentLocale).format(day);

              // Ép viết hoa chữ cái đầu tiên -> "Tháng 5 năm 2026"
              if (text.isNotEmpty) {
                text = '${text[0].toUpperCase()}${text.substring(1)}';
              }

              return Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              );
            },

            markerBuilder: (context, day, events) {
              if (events.isEmpty) return const SizedBox();

              // Giới hạn hiển thị 3 chấm
              final displayEvents = events.take(3).toList();

              return Positioned(
                bottom: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: displayEvents.map((event) {
                    Color dotColor = AppColors.primaryText;
                    final typeLower = event.type.toLowerCase();

                    if (typeLower == 'import') {
                      dotColor = AppColors.stockIn;
                    } else if (typeLower == 'export') {
                      dotColor = AppColors.stockOut;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: dotColor, shape: BoxShape.circle),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
