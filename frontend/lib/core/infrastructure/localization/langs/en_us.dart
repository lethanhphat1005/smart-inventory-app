import 'package:frontend/core/infrastructure/localization/langs/en/en_auth.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_core.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_home.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_inventory.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_notification.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_reorder_suggestion.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_report.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_search.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_transaction.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_system.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_workspace.dart';
import 'package:frontend/core/infrastructure/localization/langs/en/en_profile.dart';

final Map<String, String> enUS = {
  ...enCore,
  ...enSearch,
  ...enAuth,
  ...enWorkspace,
  ...enHome,
  ...enInventory,
  ...enTransaction,
  ...enReport,
  ...enProfile,
  ...enNotification,
  ...enSystem,
  ...enReorderSuggestion,
};
