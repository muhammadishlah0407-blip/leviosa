import 'package:flutter/material.dart';
import 'package:leviosa/service/laptop_local_service.dart';
import 'package:leviosa/pages/laptop_detail_page.dart';

class LaptopCatalog extends StatefulWidget {
  final String? initialSearch;
  const LaptopCatalog({super.key, this.initialSearch});

  @override
  State<LaptopCatalog> createState() => _LaptopCatalogState();
}

class _LaptopCatalogState extends State<LaptopCatalog> {
  String searchQuery = '';
  late TextEditingController _controller;
  List<Laptop> _allLaptops = [];
  bool _isLoading = true;
  int _maxDisplay = 30;

  @override
  void initState() {
    super.initState();
    searchQuery = widget.initialSearch ?? '';
    _controller = TextEditingController(text: searchQuery);
    _fetchLaptops();
  }

  Future<void> _fetchLaptops() async {
    setState(() => _isLoading = true);
    final data = await LaptopLocalService.loadAllLaptops();
      setState(() {
      _allLaptops = data;
      _isLoading = false;
      });
  }

  List<Laptop> get filteredLaptops {
    // Jika initialSearch adalah kategori, gunakan filterByCategory
    final q = searchQuery.toLowerCase();
    if (q == 'gaming') {
      return LaptopLocalService.filterByCategory(_allLaptops, LaptopLocalService.gamingKeywords);
    } else if (q == 'ultrabook') {
      return LaptopLocalService.filterByCategory(_allLaptops, LaptopLocalService.ultrabookKeywords);
    } else if (q == 'workstation') {
      return LaptopLocalService.filterByCategory(_allLaptops, LaptopLocalService.workstationKeywords);
    }
    // Jika bukan kategori, filter string biasa
    if (searchQuery.isEmpty) return _allLaptops;
    return _allLaptops.where((laptop) =>
      laptop.name.toLowerCase().contains(q) ||
      laptop.brand.toLowerCase().contains(q) ||
      laptop.specs.toLowerCase().contains(q)
    ).toList();
  }

  List<Laptop> get displayLaptops => filteredLaptops.take(_maxDisplay).toList();
  bool get canLoadMore => _maxDisplay < filteredLaptops.length;

  void _loadMore() {
    setState(() {
      _maxDisplay += 30;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  'Katalog Laptop',
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF008FE5)))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: 'Cari laptop... (nama/brand/spek)',
                              hintStyle: const TextStyle(color: Colors.black38),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF008FE5)),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                            ),
                            onChanged: (val) => setState(() {
                              searchQuery = val;
                              _maxDisplay = 30; // reset saat search
                            }),
                          ),
                        ),
                        Expanded(
                          child: displayLaptops.isEmpty
                              ? const Center(child: Text('Tidak ada laptop ditemukan', style: TextStyle(color: Colors.black38, fontSize: 16)))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  itemCount: displayLaptops.length,
                                  itemBuilder: (context, i) => _buildLaptopCard(displayLaptops[i]),
                                ),
                        ),
                        if (canLoadMore)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: ElevatedButton(
                              onPressed: _loadMore,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008FE5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              child: const Text('Tampilkan Lebih Banyak'),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaptopCard(Laptop laptop) {
    return ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LaptopDetailPage(laptop: laptop)),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  laptop.image,
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
                    Text(laptop.name, style: const TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(laptop.brand, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(laptop.price, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF008FE5), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const ScaleOnTap({super.key, required this.child, this.onTap});

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
