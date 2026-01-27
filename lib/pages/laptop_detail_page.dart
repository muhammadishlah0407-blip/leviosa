import 'package:flutter/material.dart';
import 'package:leviosa/pages/review_section.dart';
import 'package:leviosa/service/wishlist_service.dart';


class LaptopDetailPage extends StatefulWidget {
  final dynamic laptop;
  const LaptopDetailPage({super.key, required this.laptop});

  @override
  State<LaptopDetailPage> createState() => _LaptopDetailPageState();
}

class _LaptopDetailPageState extends State<LaptopDetailPage> {
  bool isWishlisted = false;
  final WishlistService _wishlistService = WishlistService();

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    final ids = await _wishlistService.getWishlistLaptopIds();
    setState(() {
      isWishlisted = ids.contains(widget.laptop.id);
    });
  }

  Future<void> _toggleWishlist() async {
    if (isWishlisted) {
      await _wishlistService.removeFromWishlist(laptopId: widget.laptop.id);
    } else {
      await _wishlistService.addToWishlist(laptopId: widget.laptop.id);
    }
    setState(() {
      isWishlisted = !isWishlisted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isWishlisted ? 'Ditambahkan ke wishlist' : 'Dihapus dari wishlist'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final laptop = widget.laptop;
    final List<String> specs;
    if (laptop.specs == null) {
      specs = [];
    } else if (laptop.specs is String) {
      specs = (laptop.specs as String)
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (laptop.specs is List) {
      specs = (laptop.specs as List)
          .where((s) => s != null)
          .map((s) => s.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      specs = [];
    }
    return Scaffold(
      backgroundColor: Colors.white,
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
                'Detail Laptop',
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 7,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              laptop.image ?? '',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 180,
                                color: Colors.blue[50],
                                child: const Icon(Icons.laptop, size: 60, color: Color(0xFF008FE5)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          laptop.name ?? '-',
                          style: const TextStyle(
                            color: Color(0xFF008FE5),
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          laptop.brand ?? '-',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          color: Colors.blue[50],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Spesifikasi', style: TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(laptop.specs ?? '-', style: const TextStyle(color: Colors.black87)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.green[700], size: 22),
                            const SizedBox(width: 4),
                            Text(
                              laptop.price != null ? 'Rp${laptop.price}' : '-',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _toggleWishlist,
                                icon: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                                label: Text(isWishlisted ? 'Hapus Wishlist' : 'Tambah Wishlist'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isWishlisted ? Colors.redAccent : const Color(0xFF008FE5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close, color: Colors.white),
                                label: const Text('Tutup'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[400],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ReviewSection(laptopId: laptop.id),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 