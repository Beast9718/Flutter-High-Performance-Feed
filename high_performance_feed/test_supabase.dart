import 'package:supabase/supabase.dart';
void main() async {
  final client = SupabaseClient('https://hnfscgitcelttdljypbo.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhuZnNjZ2l0Y2VsdHRkbGp5cGJvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3ODAyOTAzOCwiZXhwIjoyMDkzNjA1MDM4fQ.gvAriuXfFKbLJ-vWaYY-dV_IXTT5Gtoa7C33infun6A');
  try {
    await client.rpc('toggle_like', params: {'p_post_id': '2f66642b-8659-4dc3-8b3a-051c90375153', 'p_user_id': 'user_123'});
    print('success');
  } catch(e) {
    print('Error: ' + e.toString());
  }
}
