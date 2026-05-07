# Phase 3 TODO — High Performance Feed App

## 0. Project Setup
- [x] Create Flutter project
- [x] Add dependencies:
  - flutter_riverpod
  - supabase_flutter
  - cached_network_image
  - dio/http
  - shimmer (optional)
- [x] Configure Supabase initialization
- [x] Create constants file:
  - supabaseUrl
  - supabaseAnonKey
  - hardcoded user_id = "user_123"

---

# 1. Folder Architecture

## [x] Create clean architecture folders

lib/
├── core/
│   ├── constants/
│   ├── utils/
│   ├── theme/
│   └── services/
│
├── features/
│   └── feed/
│       ├── data/
│       │   ├── models/
│       │   ├── repositories/
│       │   └── datasource/
│       │
│       ├── presentation/
│       │   ├── screens/
│       │   ├── widgets/
│       │   └── providers/
│       │
│       └── domain/
│
└── main.dart

---

# 2. Data Layer

## Models
- [x] Create PostModel
  - id
  - createdAt
  - mediaThumbUrl
  - mediaMobileUrl
  - mediaRawUrl
  - likeCount
  - isLiked

## Repository
- [x] Create FeedRepository
- [x] Fetch paginated posts from Supabase
- [x] Limit = 10
- [x] Implement pull-to-refresh support

## Supabase Queries
- [x] Fetch posts ordered by created_at DESC
- [x] Add pagination with range()

Example:
.from('posts')
.select()
.order('created_at', ascending: false)
.range(start, end)

---

# 3. Riverpod State Management

## Providers
- [x] Supabase client provider
- [x] Feed repository provider
- [x] Feed notifier provider
- [x] Like state provider
- [x] Pagination loading provider

## Feed State
- [x] loading
- [x] posts
- [x] hasMore
- [x] error
- [x] nextPage

## Features
- [x] Initial fetch
- [x] Infinite scrolling
- [x] Pull-to-refresh
- [x] Optimistic likes
- [x] Offline revert handling

---

# 4. Infinite Feed UI

## Feed Screen
- [x] Use CustomScrollView or ListView.builder
- [x] Attach ScrollController
- [x] Detect near-bottom scrolling
- [x] Fetch next page automatically
- [x] Add RefreshIndicator

## Loading UI
- [x] Bottom loader
- [x] Skeleton loading cards
- [x] Empty state
- [x] Error state

---

# 5. GPU Protection (IMPORTANT)

## Post Card
- [x] Create complex UI card
- [x] Add heavy BoxShadow
- [x] Add gradients/border radius

## Performance Optimization
- [x] Wrap EACH card with RepaintBoundary
- [ ] Verify in Flutter DevTools
- [x] Ensure shadows are raster cached

Example:
RepaintBoundary(
  child: PostCard(),
)

---

# 6. RAM Optimization (IMPORTANT)

## Thumbnail Loading
- [x] Feed MUST use media_thumb_url ONLY

## Memory Protection
- [x] Use cacheWidth or memCacheWidth
- [x] Match decoded image size to UI size

Example:
Image.network(
  post.mediaThumbUrl,
  cacheWidth: 300,
)

OR

CachedNetworkImage(
  memCacheWidth: 300,
)

## Verify
- [ ] Check memory usage in DevTools
- [x] Avoid loading 1080p images in feed

---

# 7. Hero Animation + Tiered Loading

## Navigation
- [x] Add Hero animation from feed -> detail screen

## Detail Screen
- [x] Immediately show cached thumbnail
- [x] Fetch media_mobile_url asynchronously
- [x] Fade in high-quality image

## Animation
- [x] Use AnimatedOpacity or FadeTransition

## High Resolution Download
- [x] Add "Download High-Res" button
- [x] Fetch media_raw_url ONLY on click
- [x] Show loading indicator

---

# 8. Optimistic Like System

## UI Behaviour
- [x] Heart turns red instantly
- [x] Like count updates instantly

## Riverpod Mutation
- [x] Mutate local state first
- [x] Fire async RPC in background

RPC:
supabase.rpc(
  'toggle_like',
  params: {
    'p_post_id': postId,
    'p_user_id': userId,
  },
)

---

# 9. Spam Clicker Protection (IMPORTANT)

## Problem
User may click 15 times in 2 seconds

## Solution
- [x] Implement debounce/throttle
- [x] Keep UI instant
- [x] Prevent excessive RPC calls

Possible approach:
- Store pending like operation
- Cancel previous debounce timer
- Send only latest state to backend

---

# 10. Offline Revert Handling

## Behaviour
- [x] UI updates immediately
- [x] RPC fails silently
- [x] Revert UI state on failure
- [x] Show SnackBar

Example:
try {
  await rpcCall();
} catch (_) {
  revertLike();
  showSnackBar();
}

---

# 11. Performance Verification

## Flutter DevTools Checks
- [x] Verify RepaintBoundary repaint regions
- [x] Verify raster cache usage
- [x] Verify smooth scrolling
- [x] Verify no frame drops
- [x] Verify memory usage stability

## Jank Testing
- [x] Rapid scrolling test
- [x] Large image dataset test
- [x] Spam clicking test

---

# 12. Deliverables

## GitHub
- [ ] Push complete project
- [ ] Remove secrets from git
- [ ] Add proper .gitignore

## README
- [ ] Explain Riverpod architecture
- [ ] Explain optimistic UI
- [ ] Explain RepaintBoundary usage
- [ ] Explain memCacheWidth optimization

## Screen Recording
- [ ] Infinite scroll demo
- [ ] Hero animation demo
- [ ] Optimistic like success demo
- [ ] Offline revert demo

---

# 13. Bonus Improvements (Optional)

- [ ] Image prefetching
- [x] Skeleton shimmer
- [ ] Retry failed requests
- [ ] Connectivity listener
- [ ] Adaptive layouts
- [x] Dark mode
- [ ] Cached pagination
- [ ] Unit tests
- [ ] Widget tests