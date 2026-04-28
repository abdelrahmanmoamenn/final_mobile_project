import 'package:flutter/material.dart';
import '../model/Item.dart';
import '../model/News.dart';
import '../navigation/AppRoutes.dart';
import '../utils/DatabaseHelper.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onFavoritesChanged;

  const FavoritesScreen({
    super.key,
    this.onFavoritesChanged,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<News> _favorites;
  bool _isLoading = true;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _dbHelper.getFavorites();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(int favoriteId) async {
    await _dbHelper.deleteFavorite(favoriteId);
    setState(() {
      _favorites.removeWhere((item) => item.id == favoriteId);
    });
    // Notify home screen of changes
    widget.onFavoritesChanged?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.black87, size: 24),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'My Favorites',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCC0000),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
            // ── Content ───────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _favorites.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border,
                                  size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No favorites yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add articles to your favorites',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                       : ListView.separated(
                           padding: const EdgeInsets.symmetric(vertical: 8),
                           itemCount: _favorites.length,
                           separatorBuilder: (context, index) => const Divider(
                             height: 1,
                             thickness: 0.5,
                             indent: 16,
                             endIndent: 16,
                             color: Color(0xFFE0E0E0),
                           ),
                           itemBuilder: (context, index) {
                             final favorite = _favorites[index];
                             return _buildFavoriteItem(favorite);
                           },
                         ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(News favorite) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entire item content wrapped in InkWell for full tap detection
          Expanded(
            child: InkWell(
              onTap: () async {
                // Navigate to details screen with the Item converted from News
                final item = favorite.toItem();
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.detailScreen,
                  arguments: item,
                );
                // If details screen made changes, reload favorites
                if (result == true) {
                  await _loadFavorites();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: favorite.imageUrl != null
                            ? Image.asset(
                                favorite.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              )
                            : const Icon(Icons.bookmark, color: Colors.grey, size: 40),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            favorite.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            favorite.source ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Remove button - outside the InkWell
          GestureDetector(
            onTap: () {
              if (favorite.id != null) {
                _removeFavorite(favorite.id!);
              }
            },
            child: const Icon(
              Icons.favorite,
              color: Color(0xFFCC0000),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

