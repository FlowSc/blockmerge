/// Supabase client configuration.
///
/// The anon key is a public client key by design — security is
/// enforced by Row Level Security (RLS) policies on the database.
abstract final class SupabaseConfig {
  static const String url = 'https://nvqynkfrhlujfdkqocyd.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im52cXlua2ZyaGx1amZka3FvY3lkIiwi'
      'cm9sZSI6ImFub24iLCJpYXQiOjE3NzA3OTEwMDksImV4cCI6MjA4NjM2NzAwOX0.'
      'M7LukXqjDY24fAy_yso31NwA-Y-zj15ToaxqlsxcBA8';
}
