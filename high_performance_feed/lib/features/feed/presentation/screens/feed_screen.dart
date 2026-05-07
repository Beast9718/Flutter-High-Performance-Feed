import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/post_skeleton.dart';
import '../screens/post_detail_screen.dart';
import '../../../../core/constants/app_constants.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedNotifierProvider.notifier).fetchMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedNotifierProvider);
    final isPaginationLoading = ref.watch(paginationLoadingProvider);

  
    ref.listen<FeedState>(feedNotifierProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error && next.posts.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('EXPLORE'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedNotifierProvider.notifier).refresh(),
        child: _buildBody(feedState, isPaginationLoading),
      ),
    );
  }

  Widget _buildBody(FeedState feedState, bool isPaginationLoading) {
    if (feedState.isLoading && feedState.posts.isEmpty) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => const PostSkeleton(),
      );
    }

    if (feedState.error != null && feedState.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(feedState.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(feedNotifierProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (feedState.posts.isEmpty) {
      return const Center(child: Text('No posts available.'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: feedState.posts.length + (isPaginationLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == feedState.posts.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final post = feedState.posts[index];
        return RepaintBoundary(
          child: PostCard(
            post: post,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(post: post),
              ),
            ),
            onLike: () {
              ref.read(feedNotifierProvider.notifier).toggleLike(
                    post.id,
                    AppConstants.currentUserId,
                  );
            },
          ),
        );
      },
    );
  }
}
