import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://qqbnlbtbiiiimjnpubuc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxYm5sYnRiaWlpaW1qbnB1YnVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5Njk3NTcsImV4cCI6MjA2NzU0NTc1N30.-OszgfcZy-89VAc0QJ3mza73_Wk5dAZ7cga9DquLBlw',
  );
}