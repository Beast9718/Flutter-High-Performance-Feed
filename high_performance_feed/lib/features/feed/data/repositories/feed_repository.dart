import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class FeedRepository {
  final SupabaseClient _supabaseClient;

  FeedRepository(this._supabaseClient);

 
  Future<List<PostModel>> fetchPosts({required int offset, int limit = 10}) async {
    try {
      final response = await _supabaseClient
          .from('posts')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      debugPrint('[FeedRepository] Raw row count: ${response.length}');
      if (response.isNotEmpty) {
        debugPrint('[FeedRepository] First row keys: ${response.first.keys.toList()}');
        debugPrint('[FeedRepository] First row: ${response.first}');
      }

      return response.map((json) {
        try {
          return PostModel.fromJson(json);
        } catch (e) {
          debugPrint('[FeedRepository] Parse error on row: $json\nError: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      debugPrint('[FeedRepository] Fetch error: $e');
      throw Exception('Failed to fetch posts: $e');
    }
  }
}
