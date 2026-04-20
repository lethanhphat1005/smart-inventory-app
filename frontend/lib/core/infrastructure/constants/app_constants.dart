class AppConstants {
  // Dùng String.fromEnvironment thay cho dotenv
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'http://192.168.1.93:3000',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    // defaultValue: 'http://192.168.1.93:3000',
    defaultValue: 'http://10.0.2.2:54321',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Thời gian chờ API (Timeout)
  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 15000;
}
