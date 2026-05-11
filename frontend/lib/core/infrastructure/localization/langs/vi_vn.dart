import 'package:frontend/core/infrastructure/localization/langs/global_langs.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_auth.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_barcode.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_chatbot.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_export.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_home.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_inventory.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_notification.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_profile.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_reoder_suggestion.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_report.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_search.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_system.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_transaction.dart';
import 'package:frontend/core/infrastructure/localization/langs/vi/vi_workspace.dart';
import 'vi/vi_core.dart';

final Map<String, String> viVN = {
  ...viCore,
  ...viSearch,
  ...viAuth,
  ...viWorkspace,
  ...viHome,
  ...viInventory,
  ...viTransaction,
  ...viReport,
  ...viProfile,
  ...viNotification,
  ...viSystem,
  ...viReorderSuggestion,
  ...viExport,
  ...viBarcode,
  ...viChatbot,
  ...globalLangs,
};
