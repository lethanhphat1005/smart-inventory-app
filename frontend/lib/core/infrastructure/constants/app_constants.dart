class AppConstants {
  // Dùng String.fromEnvironment thay cho dotenv
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'http://10.0.2.2:3000',
    defaultValue: 'http://192.168.1.8:3000',
  );

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sdxvmeenhbxripgfdceb.supabase.co',
    // defaultValue: 'http://10.0.2.2:54321',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkeHZtZWVuaGJ4cmlwZ2ZkY2ViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3NjE0MDQsImV4cCI6MjA5MjMzNzQwNH0.AyKhE88IvD3GF9bSL54pcF1U9YbQKpVFdMrjt2lStPA',
    // defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Thời gian chờ API (Timeout)
  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 15000;
}
