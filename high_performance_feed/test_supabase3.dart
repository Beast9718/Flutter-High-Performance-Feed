import 'package:supabase/supabase.dart';
void main() async {
  final client = SupabaseClient('https://hnfscgitcelttdljypbo.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhuZnNjZ2l0Y2VsdHRkbGp5cGJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMjkwMzgsImV4cCI6MjA5MzYwNTAzOH0.llDALFPg2ulysEoTPTsZgXm0MyzmKOZNV9qFyCzc_HE');
  try {
    final response = await client.from('users').select().limit(1);
    print(response);
  } catch(e) {
    print('Error: ' + e.toString());
  }
}
