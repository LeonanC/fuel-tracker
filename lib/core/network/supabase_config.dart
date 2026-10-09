import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://feucepbyhclaumteibkd.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZldWNlcGJ5aGNsYXVtdGVpYmtkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY4MDQyOTMsImV4cCI6MjA5MjM4MDI5M30.Z5xbnS3swuDBGai3Z4Hv1oJhr0QfcEEfq8v9s-x6ypA',
    );
  }
}
