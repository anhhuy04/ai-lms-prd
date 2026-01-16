
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://vazhgunhcjdwlkbslroc.supabase.co', // Replace with your Supabase URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZhemhndW5oY2pkd2xrYnNscm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUxMTI3NTksImV4cCI6MjA4MDY4ODc1OX0.D-O3FbXF46mVEga152RmumAkmqS54_A-L7tFa6UBi0c', // Replace with your Supabase Anon Key
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
