import 'package:flutter/material.dart';
import '../model/Item.dart';
import '../model/News.dart';
import '../navigation/AppRoutes.dart';
import '../utils/DatabaseHelper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 1;
  final List<String> _tabs = ['Home', 'Business', 'Politics', 'Sports'];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final List<Item> _items = const [
    Item(
      id: 'item_1',
      title: 'Elon Musk becomes first person worth \$700 billion following pay package ruling',
      imageUrl: 'assets/cat.jpeg',
      isFeatured: true,
      source: 'REUTERS',
      date: '2025-12-21',
      body:
      'Dec 20 (Reuters) - Tesla CEO Elon Musk\'s net worth surged to \$749 billion '
          'late Friday after the Delaware Supreme Court reinstated Tesla stock options '
          'worth \$150 billion that were voided last year.\n\n'
          'Musk\'s 2018 pay package, once worth \$56 billion, was restored by the Delaware '
          'Supreme Court on Friday, two years after a lower court struck down the '
          'compensation deal as "unfathomable."\n\n'
          'Earlier this week, Musk became the first person ever to surpass \$600 billion '
          'in net worth on the heels of reports that his aerospace startup SpaceX was '
          'likely to go public.\n\n'
          'In November, Tesla shareholders separately approved a \$1 trillion pay plan '
          'for Musk, the largest corporate pay package in history.',
    ),
    Item(
      id: 'item_2',
      title: 'Gold price climbs above \$4,400 to hit record high',
      imageUrl: 'assets/cat.jpeg',
      source: 'BBC',
      date: '2025-12-20',
      body:
      'Gold prices have surged to a record high, climbing above \$4,400 per ounce '
          'amid global economic uncertainty and increased demand from central banks '
          'worldwide. Analysts say the rally is driven by fears of inflation and '
          'geopolitical tensions across multiple regions.',
    ),
    Item(
      id: 'item_3',
      title: "This billionaire tested China's limits. It cost him his freedom",
      imageUrl: 'assets/cat.jpeg',
      source: 'CNN',
      date: '2025-12-19',
      body:
      'A prominent Chinese billionaire who publicly challenged government policies '
          'has been detained by authorities, marking another chapter in Beijing\'s '
          'ongoing crackdown on private enterprise.',
    ),
    Item(
      id: 'item_4',
      title: 'Trump Media to merge with fusion energy firm in \$6bn deal',
      imageUrl: 'assets/cat.jpeg',
      source: 'The Guardian',
      date: '2025-12-18',
      body:
      'Trump Media & Technology Group has announced a \$6 billion merger with a '
          'fusion energy company, marking a significant pivot for the social media platform.',
    ),
    Item(
      id: 'item_5',
      title: 'AI likely to displace jobs, says Bank of England governor',
      imageUrl: 'assets/cat.jpeg',
      source: 'FT',
      date: '2025-12-17',
      body:
      'The Bank of England governor has warned that artificial intelligence is likely '
          'to displace a significant number of jobs, urging governments to prepare for '
          'widespread economic disruption.',
    ),
  ];

  // ── Favorites state ──────────────────────────────────────────────────────
  late Map<String, int> _favoritedIds; // Map itemId to database id

  @override
  void initState() {
    super.initState();
    _favoritedIds = {};
    _loadFavorites();
  }

  // Load favorites from database
  Future<void> _loadFavorites() async {
    final favorites = await _dbHelper.getFavorites();
    setState(() {
      _favoritedIds = {
        for (var fav in favorites)
          // Use title as the item identifier
          fav.title: fav.id ?? 0
      };
    });
  }

  // Toggle favorite status
  Future<void> _toggleFavorite(Item item) async {
    if (_favoritedIds.containsKey(item.title)) {
      // Remove favorite
      final dbId = _favoritedIds[item.title];
      if (dbId != null && dbId > 0) {
        await _dbHelper.deleteFavorite(dbId);
        setState(() {
          _favoritedIds.remove(item.title);
        });
      }
    } else {
      // Add favorite
      final news = News.fromItem(item);
      await _dbHelper.insertFavorite(news);
      // Reload to get the new ID
      await _loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildCategoryTabs(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: _items.length,
                separatorBuilder: (context, index) {
                  if (index == 0) return const SizedBox.shrink();
                  return const Divider(
                    height: 1, thickness: 0.5,
                    indent: 16, endIndent: 16,
                    color: Color(0xFFE0E0E0),
                  );
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  if (item.isFeatured) return _buildFeaturedItem(item);
                  return _buildRegularItem(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFCC0000), size: 28),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Expanded(
            child: Text(
              'The News Post',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold,
                color: Color(0xFFCC0000), fontStyle: FontStyle.italic,
              ),
            ),
          ),
          // Favorites icon
          IconButton(
            icon: const Icon(Icons.favorite_border,
                color: Color(0xFFCC0000), size: 26),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, AppRoutes.favoritesScreen);
              // Reload favorites when returning from favorites screen
              if (result == true) {
                await _loadFavorites();
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Category Tabs ────────────────────────────────────────────────────────
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFCC0000)
                      : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

   // ── Featured Item ────────────────────────────────────────────────────────
   Widget _buildFeaturedItem(Item item) {
     return GestureDetector(
       onTap: () async {
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
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             ClipRRect(
               borderRadius: BorderRadius.circular(12),
               child: SizedBox(
                 height: 220, width: double.infinity,
                 child: Image.asset(
                   item.imageUrl ?? '',
                   fit: BoxFit.cover,
                   errorBuilder: (_, __, ___) => Container(
                     color: const Color(0xFF1a1a2e),
                     child: const Center(
                       child: Icon(Icons.image, color: Colors.white54, size: 60),
                     ),
                   ),
                 ),
               ),
             ),
             const SizedBox(height: 10),
             Text(
               item.title,
               style: const TextStyle(
                 fontSize: 20, fontWeight: FontWeight.bold,
                 color: Colors.black, height: 1.3,
               ),
             ),
             const SizedBox(height: 8),
           ],
         ),
       ),
     );
   }

   // ── Regular Item ─────────────────────────────────────────────────────────
   Widget _buildRegularItem(Item item) {
     final isFavorited = _favoritedIds.containsKey(item.title);

     return InkWell(
       onTap: () async {
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
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
         child: Row(
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             // Thumbnail
             ClipRRect(
               borderRadius: BorderRadius.circular(8),
               child: SizedBox(
                 width: 110, height: 80,
                 child: Image.asset(
                   item.imageUrl ?? '',
                   fit: BoxFit.cover,
                   errorBuilder: (_, __, ___) => Container(
                     color: const Color(0xFFE0E0E0),
                     child: const Icon(Icons.image, color: Colors.grey),
                   ),
                 ),
               ),
             ),
             const SizedBox(width: 12),

             // Title
             Expanded(
               child: Text(
                 item.title,
                 style: const TextStyle(
                   fontSize: 15, fontWeight: FontWeight.w600,
                   color: Colors.black, height: 1.35,
                 ),
                 maxLines: 3,
                 overflow: TextOverflow.ellipsis,
               ),
             ),
             const SizedBox(width: 8),

             // ── Heart / Favorite button ──────────────────────────────
             GestureDetector(
               onTap: () => _toggleFavorite(item),
               child: Icon(
                 isFavorited ? Icons.favorite : Icons.favorite_border,
                 color: isFavorited ? const Color(0xFFCC0000) : Colors.grey,
                 size: 26,
               ),
             ),
           ],
         ),
       ),
     );
   }
}