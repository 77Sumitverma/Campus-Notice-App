import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://qqbnlbtbiiiimjnpubuc.supabase.co'; // ← Replace this
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxYm5sYnRiaWlpaW1qbnB1YnVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5Njk3NTcsImV4cCI6MjA2NzU0NTc1N30.-OszgfcZy-89VAc0QJ3mza73_Wk5dAZ7cga9DquLBlw';            // ← Replace this

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  static SupabaseClient get client => Supabase.instance.client;
}
