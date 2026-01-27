import 'package:flutter/material.dart';
import 'package:leviosa/pages/edit_profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:leviosa/service/wishlist_service.dart';
import 'package:leviosa/pages/wishlist_page.dart';
import 'package:leviosa/pages/user_review_page.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  static Map<String, String?>? _cachedProfile;
  late Future<Map<String, String?>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = getUserProfile();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = getUserProfile();
    });
  }

  Future<Map<String, String?>> getUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return {'name': '-', 'email': '-', 'bio': '-', 'avatar_url': ''};
    }
    if (_cachedProfile != null) {
      // return cache lebih dulu
      return _cachedProfile!;
    }
    final supabase = Supabase.instance.client;
    final profile = await supabase
        .from('profiles')
        .select('display_name, email, bio, avatar_url')
        .eq('id', user.id)
        .maybeSingle();
    _cachedProfile = {
      'name': profile?['display_name'] ?? '-',
      'email': profile?['email'] ?? '-',
      'bio': profile?['bio'] ?? '-',
      'avatar_url': profile?['avatar_url'] ?? '',
    };
    return _cachedProfile!;
  }

  Future<Map<String, int>> getUserStats() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return {'wishlist': 0, 'rating': 0, 'ulasan': 0};
    }

    try {
      // Ambil jumlah wishlist
      final wishlistService = WishlistService();
      final wishlistIds = await wishlistService.getWishlistLaptopIds();
      final wishlistCount = wishlistIds.length;

      // Untuk saat ini, rating dan ulasan masih menggunakan data dummy
      // karena tabel reviews belum diimplementasikan di database
      // TODO: Implementasikan tabel reviews di Supabase untuk data yang sebenarnya
      int ratingCount = 0;
      int ulasanCount = 0;

      // Coba ambil data dari tabel reviews jika ada
      try {
        final supabase = Supabase.instance.client;
        final reviewsResult = await supabase
            .from('reviews')
            .select('rating, review')
            .eq('user_id', user.id);

        ratingCount = reviewsResult.length;
        ulasanCount = reviewsResult
            .where((r) => r['review'] != null && r['review'].toString().isNotEmpty)
            .length;
      } catch (e) {
        // Jika tabel reviews belum ada, gunakan 0
        ratingCount = 0;
        ulasanCount = 0;
      }

      return {
        'wishlist': wishlistCount,
        'rating': ratingCount,
        'ulasan': ulasanCount,
      };
    } catch (e) {
      // Jika ada error, kembalikan 0 untuk semua statistik
      return {'wishlist': 0, 'rating': 0, 'ulasan': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: user == null
          ? Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008FE5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : FutureBuilder<Map<String, String?>> (
              future: getUserProfile(),
              builder: (context, snapshot) {
                final data = snapshot.data ?? {};
                final displayName = data['name'] ?? '-';
                final avatarUrl = data['avatar_url'] ?? '';
                final email = data['email'] ?? '-';
                return Column(
                  children: [
                    // HEADER DANA STYLE
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF008FE5),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('Personal', style: TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              CircleAvatar(
                                radius: 44,
                                backgroundColor: Colors.white,
                                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl.isEmpty
                                    ? const Icon(Icons.person, size: 54, color: Color(0xFF008FE5))
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                              if ((data['bio'] ?? '').isNotEmpty && data['bio'] != '-')
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0, left: 24, right: 24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.format_quote, color: Colors.white70, size: 22),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            data['bio']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontStyle: FontStyle.italic,
                                              height: 1.4,
                                            ),
                                            textAlign: TextAlign.left,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: 160,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => EditProfilePage()),
                                    );
                                    if (result != null) {
                                      setState(() {
                                        _cachedProfile = Map<String, String?>.from(result);
                                        _profileFuture = Future.value(_cachedProfile);
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  label: const Text('Edit Profil'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF008FE5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // BOX PUTIH STATISTIK
                    FutureBuilder<Map<String, int>>(
                      future: getUserStats(),
                      builder: (context, statSnapshot) {
                        final stats = statSnapshot.data ?? {'wishlist': 0, 'ulasan': 0};
                        return Container(
                          margin: const EdgeInsets.only(top: 18, left: 18, right: 18, bottom: 0),
                          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const UserReviewPage()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Column(
                                  children: [
                                    const Icon(Icons.reviews, color: Color(0xFF008FE5), size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      stats['ulasan']?.toString() ?? '0',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF008FE5)),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text('Review', style: TextStyle(color: Colors.black54, fontSize: 15)),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1.5,
                                height: 48,
                                color: Colors.grey[200],
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const WishlistPage()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Column(
                                  children: [
                                    const Icon(Icons.favorite, color: Color(0xFFED4264), size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      stats['wishlist']?.toString() ?? '0',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFED4264)),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text('Wishlist', style: TextStyle(color: Colors.black54, fontSize: 15)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF008FE5), width: 2),
                            foregroundColor: const Color(0xFF008FE5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('KELUAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildStatColumn(
    String title,
    String count, {
    IconData? icon,
    Color? color,
  }) {
    return Column(
      children: [
        if (icon != null) Icon(icon, color: color ?? Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 15, color: Colors.white70),
        ),
      ],
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
