import 'package:flutter/material.dart';
import 'package:leviosa/service/laptop_local_service.dart';
import 'package:leviosa/service/wishlist_service.dart';
import 'package:leviosa/pages/laptop_detail_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final WishlistService wishlistService = WishlistService();
  List<Laptop> wishlistLaptops = [];
  bool isLoading = true;
  Set<String> deletingItems = {};
  bool isError = false;
  String? errorMsg;
  bool notLoggedIn = false;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    setState(() {
      isLoading = true;
      isError = false;
      errorMsg = null;
      notLoggedIn = false;
    });
    try {
      final allLaptops = await LaptopLocalService.loadAllLaptops();
      final wishlistIds = await wishlistService.getWishlistLaptopIds();
      final items = allLaptops.where((l) => wishlistIds.contains(l.id)).toList();
      setState(() {
        wishlistLaptops = items;
        isLoading = false;
      });
    } on Exception catch (e) {
      if (e.toString().contains('not logged in')) {
        setState(() {
          notLoggedIn = true;
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          errorMsg = e.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> removeFromWishlist(String laptopId) async {
    setState(() => deletingItems.add(laptopId));
    await wishlistService.removeFromWishlist(laptopId: laptopId);
    setState(() {
      wishlistLaptops.removeWhere((item) => item.id == laptopId);
      deletingItems.remove(laptopId);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laptop berhasil dihapus dari wishlist'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteConfirmation(Laptop item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'Hapus dari Wishlist',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${item.name}" dari wishlist?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                removeFromWishlist(item.id);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF008FE5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(top: 36, left: 20, right: 20, bottom: 18),
              child: const SafeArea(
                child: Text(
                  'Wishlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF008FE5)))
                  : notLoggedIn
                      ? Center(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                            icon: const Icon(Icons.login, color: Colors.white),
                            label: const Text('Login untuk melihat wishlist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF008FE5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : isError
                          ? Center(child: Text(errorMsg ?? 'Terjadi error', style: const TextStyle(color: Colors.red, fontSize: 16)))
                          : wishlistLaptops.isEmpty
                              ? _buildEmptyState()
                              : _buildWishlistContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: Colors.blue[100],
          ),
          const SizedBox(height: 20),
          const Text(
            'Wishlist Kosong',
            style: TextStyle(
              color: Color(0xFF008FE5),
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ayo cari laptop favoritmu!',
            style: TextStyle(color: Colors.black38, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistContent() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: wishlistLaptops.length,
      itemBuilder: (context, i) => ScaleOnTap(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LaptopDetailPage(laptop: wishlistLaptops[i]),
            ),
          );
        },
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    wishlistLaptops[i].image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, color: Colors.grey[300], size: 70),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(wishlistLaptops[i].name, style: const TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(wishlistLaptops[i].brand, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(wishlistLaptops[i].price, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
                deletingItems.contains(wishlistLaptops[i].id)
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF008FE5)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                        onPressed: () => _showDeleteConfirmation(wishlistLaptops[i]),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const ScaleOnTap({Key? key, required this.child, this.onTap}) : super(key: key);

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.96);
  void _onTapUp(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
