import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/post_model.dart';
import '../providers/feed_provider.dart';
import '../widgets/like_button.dart';
import '../../../../core/constants/app_constants.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  bool _mobileLoaded = false;
  bool _isDownloading = false;
  bool _rawLoaded = false;

  @override
  Widget build(BuildContext context) {
    
    final feedState = ref.watch(feedNotifierProvider);
    final livePost = feedState.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Tier 1: Cached thumbnail via Hero — shown immediately
                Hero(
                  tag: 'post_thumb_${livePost.id}',
                  child: CachedNetworkImage(
                    imageUrl: livePost.mediaThumbUrl,
                    memCacheWidth: 400,
                    fit: BoxFit.cover,
                  ),
                ),

             
                CachedNetworkImage(
                  imageUrl: livePost.mediaMobileUrl,
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) {
                    if (!_mobileLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _mobileLoaded = true);
                      });
                    }
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: _mobileLoaded ? 1.0 : 0.0,
                      child: Image(image: imageProvider, fit: BoxFit.cover),
                    );
                  },
                  placeholder: (p1, p2) => const SizedBox.shrink(),
                  errorWidget: (p1, p2, p3) => const SizedBox.shrink(),
                ),

                if (_rawLoaded)
                  CachedNetworkImage(
                    imageUrl: livePost.mediaRawUrl,
                    fit: BoxFit.cover,
                    imageBuilder: (context, imageProvider) => AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: 1.0,
                      child: Image(image: imageProvider, fit: BoxFit.cover),
                    ),
                    placeholder: (p1, p2) => const SizedBox.shrink(),
                    errorWidget: (p1, p2, p3) => const SizedBox.shrink(),
                  ),

                
                Positioned(
                  top: kToolbarHeight + 20,
                  right: 16,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _rawLoaded
                          ? Colors.amber.withValues(alpha: 0.9)
                          : _mobileLoaded
                              ? Colors.green.withValues(alpha: 0.9)
                              : Colors.grey.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _rawLoaded ? 'RAW' : _mobileLoaded ? 'HD' : 'THUMB',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1E)],
              ),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Post meta
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.white54, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      livePost.createdAt.toLocal().toString().split(' ')[0],
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const Spacer(),
                   
                    LikeButton(
                      isLiked: livePost.isLiked,
                      likeCount: livePost.likeCount,
                      onTap: () => ref
                          .read(feedNotifierProvider.notifier)
                          .toggleLike(livePost.id, AppConstants.currentUserId),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _rawLoaded ? Icons.check_circle : Icons.download_outlined),
                  label: Text(
                    _rawLoaded
                        ? 'High-Res Loaded'
                        : _isDownloading
                            ? 'Loading...'
                            : 'Download High-Res',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed:
                      (_isDownloading || _rawLoaded) ? null : _downloadHighRes,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadHighRes() async {
    setState(() => _isDownloading = true);

    
    await precacheImage(
      CachedNetworkImageProvider(widget.post.mediaRawUrl),
      context,
    );

    if (mounted) {
      setState(() {
        _isDownloading = false;
        _rawLoaded = true;
      });
    }
  }
}

