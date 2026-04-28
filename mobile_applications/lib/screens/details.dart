import 'package:flutter/material.dart';
import '../model/Item.dart';
import '../model/News.dart';
import '../utils/DatabaseHelper.dart';

class DetailsScreen extends StatefulWidget {
  final Item item;

  const DetailsScreen({super.key, required this.item});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late bool _isFavorited;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int? _favoriteDbId;
  bool _favoriteStatusChanged = false;  // ← Track if favorite was toggled

  @override
  void initState() {
    super.initState();
    _isFavorited = false;
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final favorites = await _dbHelper.getFavorites();
    // Check if the current item title is in favorites
    for (var fav in favorites) {
      if (fav.title == widget.item.title) {
        setState(() {
          _isFavorited = true;
          _favoriteDbId = fav.id;
        });
        return;
      }
    }
    setState(() {
      _isFavorited = false;
      _favoriteDbId = null;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorited && _favoriteDbId != null) {
      // Remove from database
      await _dbHelper.deleteFavorite(_favoriteDbId!);
      setState(() {
        _isFavorited = false;
        _favoriteDbId = null;
        _favoriteStatusChanged = true;  // ← Mark as changed
      });
    } else {
      // Add to database
      final news = News.fromItem(widget.item);
      final id = await _dbHelper.insertFavorite(news);
      setState(() {
        _isFavorited = true;
        _favoriteDbId = id;
        _favoriteStatusChanged = true;  // ← Mark as changed
      });
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorited ? 'Added to favorites' : 'Removed from favorites',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 800),
      ),
    );
    // ← REMOVED automatic pop - user will click back manually
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top Bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, _favoriteStatusChanged ? true : false),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.black87, size: 24),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'News Detail',
                      style: TextStyle(
                        fontSize: 16, color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Title ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold,
                          color: Colors.black, height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC0000),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isFavorited
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ── Source & Date ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${widget.item.source ?? 'Unknown'} | ${widget.item.date ?? ''}',
                  style: const TextStyle(
                    fontSize: 12, color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Hero Image ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 220, width: double.infinity,
                    child: Image.asset(
                      widget.item.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: const Color(0xFF1a1a2e),
                        child: const Center(
                          child: Icon(Icons.image,
                              color: Colors.white54, size: 60),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Body Text ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                child: Text(
                  widget.item.body ?? 'No additional details available.',
                  style: const TextStyle(
                    fontSize: 15, color: Colors.black87, height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

