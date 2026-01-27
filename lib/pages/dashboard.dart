import 'package:flutter/material.dart';
import 'package:leviosa/pages/profil.dart';
import 'package:leviosa/pages/laptop_catalog.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'wishlist_page.dart';
import 'package:leviosa/service/laptop_local_service.dart';
import 'laptop_detail_page.dart';
import 'package:leviosa/pages/brand_sales_chart.dart';
import 'dart:async';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Laptop> gamingX1List = [];
  Laptop? businessPro;
  Laptop? creatorStudio;
  bool _isCardLoading = true;

  // Untuk sales chart per brand
  List<String> brands = [
    'Asus',
    'Acer',
    'Lenovo',
    'HP',
    'Dell',
    'MSI',
    'Apple',
  ];
  Map<String, List<int>> salesData = {};
  int currentBrandIndex = 0;
  bool isSalesLoading = false;
  String? salesErrorMsg;
  Timer? _brandTimer;

  int _selectedIndex = 0;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _fetchFeaturedLaptops();
    fetchAllBrandSales();
    _startBrandAutoSwitch();
  }

  void _startBrandAutoSwitch() {
    _brandTimer?.cancel();
    _brandTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        currentBrandIndex = (currentBrandIndex + 1) % brands.length;
      });
    });
  }

  @override
  void dispose() {
    _brandTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchAllBrandSales() async {
    if (!mounted) return;
    setState(() {
      isSalesLoading = true;
      salesErrorMsg = null;
    });
    try {
      Map<String, List<int>> temp = {};
      for (final brand in brands) {
        // Menggunakan data lokal untuk menghindari masalah CSP
        temp[brand] = getLocalSalesData(brand);
          }
      if (!mounted) return;
      setState(() {
        salesData = temp;
        isSalesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        salesErrorMsg = 'Gagal mengambil data: $e';
        isSalesLoading = false;
      });
    }
  }

  List<int> getLocalSalesData(String brand) {
    // Data sales lokal untuk setiap brand
    final Map<String, List<int>> localData = {
      'Asus': [85, 92, 78, 95, 88, 91],
      'Acer': [72, 85, 90, 83, 87, 79],
      'Lenovo': [88, 95, 82, 89, 93, 86],
      'HP': [75, 88, 92, 85, 90, 83],
      'Dell': [90, 87, 94, 88, 85, 92],
      'MSI': [82, 89, 85, 91, 87, 94],
      'Apple': [95, 98, 92, 96, 94, 97],
    };
    
    return localData[brand] ?? List.generate(
      6,
      (i) => 80 + (i * 10) + (brand.codeUnitAt(0) % 20),
    );
  }

  Future<void> _fetchFeaturedLaptops() async {
    final all = await LaptopLocalService.loadAllLaptops();

    // Gaming Series X1: 2 laptop rating tertinggi
    final gaming = LaptopLocalService.filterByCategory(
      all,
      LaptopLocalService.gamingKeywords,
    );
    gaming.sort((a, b) => b.rating.compareTo(a.rating));
    gamingX1List = gaming.take(2).toList();

    // Business Pro: workstation/bisnis rating tertinggi
    final business = LaptopLocalService.filterByCategory(
      all,
      LaptopLocalService.workstationKeywords,
    );
    business.sort((a, b) => b.rating.compareTo(a.rating));
    businessPro = business.isNotEmpty ? business.first : null;

    // Creator Studio: ultrabook/creator rating tertinggi
    final creator = LaptopLocalService.filterByCategory(
      all,
      LaptopLocalService.ultrabookKeywords,
    );
    creator.sort((a, b) => b.rating.compareTo(a.rating));
    creatorStudio = creator.isNotEmpty ? creator.first : null;

    if (!mounted) return;
    setState(() {
      _isCardLoading = false;
      _pages = [
        _HomeShowcaseContent(
          businessPro: businessPro,
          creatorStudio: creatorStudio,
          gamingX1List: gamingX1List,
        ),
        LaptopCatalog(),
        WishlistPage(),
        Profil(),
        BrandSalesChartPage(),
      ];
    });
  }

  Future<Map<String, String?>> getUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return {'name': '-', 'email': '-', 'avatar_url': ''};
    }
    final supabase = Supabase.instance.client;
    final profile =
        await supabase
            .from('profiles')
            .select('display_name, email, avatar_url')
            .eq('id', user.id)
            .maybeSingle();
    final name = profile?['display_name'] as String? ?? '-';
    final email = profile?['email'] as String? ?? '-';
    final avatarUrl = profile?['avatar_url'] as String? ?? '';
    return {'name': name, 'email': email, 'avatar_url': avatarUrl};
  }

  Future<List<Laptop>> getLaptopsByCategory(String category) async {
    final data = await LaptopLocalService.loadAllLaptops();
    if (category == 'Gaming') {
      return LaptopLocalService.filterByCategory(
        data,
        LaptopLocalService.gamingKeywords,
      );
    } else if (category == 'Ultrabook') {
      return LaptopLocalService.filterByCategory(
        data,
        LaptopLocalService.ultrabookKeywords,
      );
    } else if (category == 'Workstation') {
      return LaptopLocalService.filterByCategory(
        data,
        LaptopLocalService.workstationKeywords,
      );
    }
    return [];
  }

  void _onNavTap(int i) {
    setState(() => _selectedIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        body: (_pages.isEmpty || _isCardLoading)
            ? const Center(child: CircularProgressIndicator())
            : _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF008FE5),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.laptop), label: 'Katalog'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          ],
        ),
      ),
    );
  }
}

class _HomeShowcaseContent extends StatefulWidget {
  final Laptop? businessPro;
  final Laptop? creatorStudio;
  final List<Laptop> gamingX1List;
  const _HomeShowcaseContent({this.businessPro, this.creatorStudio, required this.gamingX1List, Key? key}) : super(key: key);
  @override
  State<_HomeShowcaseContent> createState() => _HomeShowcaseContentState();
}

class _HomeShowcaseContentState extends State<_HomeShowcaseContent> {
  static Map<String, String?>? _cachedProfile;
  List<Map<String, dynamic>> ads = [];
  bool isAdsLoading = true;
  String? avatarUrl;
  String? displayName;
  int _currentAdIndex = 0;
  PageController? _adPageController;
  Timer? _adAutoSlideTimer;

  // Data chart dummy (bisa diambil dari BrandSalesChart/service)
  final List<String> brands = [
    'Asus', 'Acer', 'Lenovo', 'HP', 'Dell', 'MSI', 'Apple',
  ];
  final Map<String, List<int>> salesData = {
    'Asus': [85, 92, 78, 95, 88, 91],
    'Acer': [72, 85, 90, 83, 87, 79],
    'Lenovo': [88, 95, 82, 89, 93, 86],
    'HP': [75, 88, 92, 85, 90, 83],
    'Dell': [90, 87, 94, 88, 85, 92],
    'MSI': [82, 89, 85, 91, 87, 94],
    'Apple': [95, 98, 92, 96, 94, 97],
  };
  int currentBrandIndex = 0;

  final List<Map<String, dynamic>> dummyAds = [
    {
      'title': 'Lenovo Legion Pro 7i',
      'description': 'Laptop gaming performa tinggi, diskon spesial! ',
      'thumbnail': 'assets/images/Lenovo Legion Pro 7i.jpg',
      'price': '38.000.000',
    },
    {
      'title': 'Asus ROG Zephyrus G14',
      'description': 'Laptop tipis, ringan, dan powerful untuk creator.',
      'thumbnail': 'assets/images/ROG-Zephyrus-G14-Thumbnail.jpg',
      'price': '32.000.000',
    },
    {
      'title': 'Apple MacBook Air M4',
      'description': 'Laptop premium, baterai tahan lama, desain elegan.',
      'thumbnail': 'assets/images/Apple Macbook Air M4.jpg',
      'price': '28.000.000',
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchAds();
    fetchProfile();
    _adPageController = PageController();
    _startAdAutoSlide();
  }

  Future<void> fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        avatarUrl = null;
        displayName = null;
      });
      return;
    }
    if (_cachedProfile != null) {
      setState(() {
        avatarUrl = _cachedProfile!['avatar_url'] ?? '';
        displayName = _cachedProfile!['display_name'] ?? '';
      });
      // tetap fetch di background untuk update jika ada perubahan
    }
    final supabase = Supabase.instance.client;
    final profile = await supabase
        .from('profiles')
        .select('display_name, avatar_url')
        .eq('id', user.id)
        .maybeSingle();
    _cachedProfile = {
      'avatar_url': profile?['avatar_url'] ?? '',
      'display_name': profile?['display_name'] ?? '',
    };
    setState(() {
      avatarUrl = _cachedProfile!['avatar_url'] ?? '';
      displayName = _cachedProfile!['display_name'] ?? '';
    });
  }

  Future<void> fetchAds() async {
    setState(() { isAdsLoading = true; });
    // Ganti: Tidak usah fetch ke internet, langsung pakai dummyAds
    await Future.delayed(const Duration(milliseconds: 500)); // simulasi loading
    setState(() { ads = dummyAds; isAdsLoading = false; });
  }

  void _startAdAutoSlide() {
    _adAutoSlideTimer?.cancel();
    _adAutoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || ads.isEmpty || _adPageController == null) return;
      int nextPage = (_currentAdIndex + 1) % ads.length;
      _adPageController!.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _adAutoSlideTimer?.cancel();
    _adPageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        // HEADER STICKY
        Material(
          elevation: 4,
          color: const Color(0xFF008FE5),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          child: Container(
            width: double.infinity,
            height: 80,
            padding: const EdgeInsets.only(top: 36, left: 24, right: 20, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Leviosa Showcase',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1.1,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const Profil()),
                    );
                  },
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(avatarUrl!),
                          radius: 22,
                        )
                      : const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 22,
                          child: Icon(Icons.person, color: Color(0xFF008FE5), size: 28),
                        ),
                ),
              ],
            ),
          ),
        ),
        // KONTEN SCROLLABLE
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Welcome langsung di bawah header
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 18, bottom: 18),
                    width: width * 0.92,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF008FE5), Color(0xFF43C6AC)]),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Welcome to the Future', style: TextStyle(color: Colors.white70, fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Leviosa Showcase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                              SizedBox(height: 6),
                              Text('Discover Next-Gen Computing Power', style: TextStyle(color: Colors.white, fontSize: 15)),
                            ],
                          ),
                        ),
                        const Icon(Icons.laptop_mac, color: Colors.white, size: 54),
                      ],
                    ),
                  ),
                ),
                // Banner/Carousel dari API iklan
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 160,
                      color: Colors.grey[100],
                      child: isAdsLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Stack(
                              children: [
                                PageView.builder(
                                  controller: _adPageController,
                                  itemCount: ads.length,
                                  onPageChanged: (i) {
                                    setState(() => _currentAdIndex = i);
                                  },
                                  itemBuilder: (context, i) {
                                    final ad = ads[i];
                                    return ad['thumbnail'].toString().startsWith('assets/')
                                        ? Image.asset(ad['thumbnail'], fit: BoxFit.cover)
                                        : Image.network(ad['thumbnail'], fit: BoxFit.cover);
                                  },
                                ),
                                // Indicator bulat di bawah
                                Positioned(
                                  bottom: 12,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(ads.length, (i) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: _currentAdIndex == i ? 18 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _currentAdIndex == i ? Colors.blueAccent : Colors.white70,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                // Featured Laptops (gabungan dua produk dalam satu card)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFED4264), Color(0xFF185A9D)]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.sports_esports, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Gaming Series X1 - Price Comparison', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: List.generate(widget.gamingX1List.length, (i) {
                            final laptop = widget.gamingX1List[i];
                            return Expanded(
                              child: ScaleOnTap(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LaptopDetailPage(laptop: laptop),
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: i == 0 ? Colors.white.withOpacity(0.18) : Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(i == 0 ? 'Best Value' : 'Cheaper', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                    const Icon(Icons.laptop, color: Colors.white, size: 38),
                                    const SizedBox(height: 8),
                                    Text(
                                      laptop.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Rp ${laptop.price}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                // Business Pro & Creator Studio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: ScaleOnTap(
                          onTap: () {
                            if (widget.businessPro != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LaptopDetailPage(laptop: widget.businessPro!),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[800],
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.business_center, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text('Business Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Lenovo ThinkPad X1 Carbon Gen 13 Aura Edition',
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                const Text('Starting Rp 28.000.000', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: ScaleOnTap(
                          onTap: () {
                            if (widget.creatorStudio != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LaptopDetailPage(laptop: widget.creatorStudio!),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.pink[400],
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.palette, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text('Creator Studio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Apple MacBook Air 13-Inch (2025, M4)',
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                const Text('Starting Rp 20.000.000', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Shop by Category
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                  child: Text('Shop by Category', style: TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CategoryCard(
                          icon: Icons.sports_esports,
                          label: 'Gaming',
                          color: const Color(0xFFED4264),
                          width: 90,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LaptopCatalog(initialSearch: 'gaming'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _CategoryCard(
                          icon: Icons.laptop_mac,
                          label: 'Ultrabook',
                          color: const Color(0xFF43CEA2),
                          width: 90,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LaptopCatalog(initialSearch: 'ultrabook'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _CategoryCard(
                          icon: Icons.business_center,
                          label: 'Workstation',
                          color: const Color(0xFF008FE5),
                          width: 90,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LaptopCatalog(initialSearch: 'workstation'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 18),
                      ],
                    ),
                  ),
                ),
                // Sales Analytics (BarChart modern)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Text('', style: TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: ScaleOnTap(
                    onTap: null,
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _buildBarChart(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    // BarChart modern, biru, clean
    final barGroups = List.generate(brands.length, (i) {
      final sales = salesData[brands[i]] ?? [0, 0, 0, 0, 0, 0];
      final total = sales.reduce((a, b) => a + b);
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: total.toDouble(),
            color: const Color(0xFF008FE5),
            width: 22,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: salesData.values.expand((e) => e).reduce((a, b) => a > b ? a : b) * brands.length * 1.0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueAccent,
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                children: [
                  TextSpan(
                    text: 'Total: ',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  TextSpan(
                    text: rod.toY.toInt().toString(),
                    style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.black38, fontSize: 12)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= brands.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(brands[value.toInt()], style: const TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.bold, fontSize: 13)),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 100, getDrawingHorizontalLine: (value) => FlLine(color: Color(0xFFE3F2FD), strokeWidth: 1)),
        barGroups: barGroups,
      ),
    );
  }
}

typedef CategoryTap = void Function();
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final CategoryTap? onTap;
  final double width;
  const _CategoryCard({required this.icon, required this.label, required this.color, this.onTap, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ScaleOnTap(
        onTap: onTap,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for circuit pattern
class CircuitPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: (0.1 * 255))
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final path = Path();

    // Horizontal lines
    for (int i = 0; i < 4; i++) {
      double y = (size.height / 5) * (i + 1);
      path.moveTo(0, y);
      path.lineTo(size.width * 0.4, y);
      path.moveTo(size.width * 0.6, y);
      path.lineTo(size.width, y);
    }

    // Vertical lines
    for (int i = 0; i < 3; i++) {
      double x = (size.width / 4) * (i + 1);
      path.moveTo(x, 0);
      path.lineTo(x, size.height * 0.5);
      path.moveTo(x, size.height * 0.5);
      path.lineTo(x, size.height);
    }

    canvas.drawPath(path, paint);

    // Draw small circles at intersections
    final circlePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: (0.2 * 255))
          ..style = PaintingStyle.fill;

    for (int i = 1; i <= 3; i++) {
      for (int j = 1; j <= 3; j++) {
        canvas.drawCircle(
          Offset((size.width / 4) * i, (size.height / 4) * j),
          2,
          circlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CategoryLaptopCatalog extends StatelessWidget {
  final String title;
  final List<Laptop> laptops;

  const CategoryLaptopCatalog({
    Key? key,
    required this.title,
    required this.laptops,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0F172A),
      body:
          laptops.isEmpty
              ? const Center(
                child: Text(
                  'Tidak ada laptop di kategori ini',
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: laptops.length,
                itemBuilder: (context, index) {
                  final laptop = laptops[index];
                  return Card(
                    color: const Color(0xFF1E293B),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            laptop.image.isNotEmpty
                                ? (laptop.image.startsWith('http')
                                    ? Image.network(
                                      laptop.image,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                color: Colors.white24,
                                                size: 60,
                                              ),
                                    )
                                    : Image.asset(
                                      laptop.image,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                color: Colors.white24,
                                                size: 60,
                                              ),
                                    ))
                                : const Icon(
                                  Icons.laptop,
                                  color: Colors.white,
                                  size: 60,
                                ),
                      ),
                      title: Text(
                        laptop.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            laptop.brand,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            laptop.price,
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LaptopDetailPage(laptop: laptop),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}

// Tambahkan widget menu ala DANA
typedef MenuTap = void Function();

class _DanaMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final MenuTap onTap;
  const _DanaMenuButton({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: const Color(0xFF008FE5), size: 26),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF008FE5), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// Widget reusable untuk efek scale saat tap/hold
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
