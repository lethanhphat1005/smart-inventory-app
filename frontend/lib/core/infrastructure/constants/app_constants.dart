import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'http://10.0.2.2:54321';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';

  static String get serverClientId => dotenv.env['SERVER_CLIENT_ID'] ?? "";

  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 45000;
}
