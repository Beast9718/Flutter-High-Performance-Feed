import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/feed_repository.dart';


final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});


final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return FeedRepository(supabase);
});


class PaginationLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void update(bool value) => state = value;
}

final paginationLoadingProvider = NotifierProvider<PaginationLoadingNotifier, bool>(PaginationLoadingNotifier.new);


class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int nextPage;

  FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.nextPage = 0,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? nextPage,
    bool clearError = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      nextPage: nextPage ?? this.nextPage,
    );
  }
}


class FeedNotifier extends Notifier<FeedState> {

  final Map<String, Timer> _debounceTimers = {};
  final Map<String, bool> _pendingLikeState = {};

  @override
  FeedState build() {

    ref.onDispose(() {
      for (final t in _debounceTimers.values) {
        t.cancel();
      }
    });
    Future.microtask(() => fetchInitialPosts());
    return FeedState();
  }

  Future<void> fetchInitialPosts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repository = ref.read(feedRepositoryProvider);
      final posts = await repository.fetchPosts(offset: 0);
      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasMore: posts.isNotEmpty, 
        nextPage: posts.length < 10 ? 0 : 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchMorePosts() async {
    if (state.isLoading || !state.hasMore || ref.read(paginationLoadingProvider)) return;
    
   
    ref.read(paginationLoadingProvider.notifier).update(true);
    
    try {
      final repository = ref.read(feedRepositoryProvider);
      var posts = await repository.fetchPosts(offset: state.nextPage * 10);
      var nextPageIndex = state.nextPage + 1;

      if (posts.isEmpty && state.posts.isNotEmpty) {
        posts = await repository.fetchPosts(offset: 0);
        nextPageIndex = 1;
      } else if (posts.length < 10) {
        nextPageIndex = 0; 
      }

      state = state.copyWith(
        posts: [...state.posts, ...posts],
        hasMore: true,
        nextPage: nextPageIndex,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      ref.read(paginationLoadingProvider.notifier).update(false);
    }
  }

  Future<void> refresh() async {
    await fetchInitialPosts();
  }

  
  void toggleLike(String postId, String userId) {

    final postIndex = state.posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];

  
    final currentLiked = _pendingLikeState.containsKey(postId)
        ? _pendingLikeState[postId]!
        : post.isLiked;
    final newLiked = !currentLiked;
    final newLikeCount = newLiked ? post.likeCount + 1 : post.likeCount - 1;

    _pendingLikeState[postId] = newLiked;

    final updatedPost =
        post.copyWith(isLiked: newLiked, likeCount: newLikeCount);
   
    final updatedPosts = state.posts.map((p) => p.id == postId ? updatedPost : p).toList();
    
    state = state.copyWith(posts: updatedPosts);

  
    _debounceTimers[postId]?.cancel();

    
    _debounceTimers[postId] = Timer(
      const Duration(milliseconds: 600),
      () => _flushLikeRpc(postId, userId, postIndex, post),
    );

  }

  Future<void> _flushLikeRpc(
    String postId,
    String userId,
    int postIndex,
    PostModel originalPost, 
  ) async {
    final targetLiked = _pendingLikeState[postId];
    _pendingLikeState.remove(postId);
    _debounceTimers.remove(postId);

    if (targetLiked == null) return;

    if (targetLiked == originalPost.isLiked) return;

    try {
      await ref.read(supabaseClientProvider).rpc('toggle_like', params: {
        'p_post_id': postId,
        'p_user_id': userId,
      });
    } catch (e) {
  
      final revertedPosts = state.posts.map((p) => p.id == postId ? originalPost : p).toList();
      state = state.copyWith(
        posts: revertedPosts,
        error: 'Failed to update like. Changes reverted.',
      );
    }
  }
}

final feedNotifierProvider = NotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);


