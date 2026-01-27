import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/review_service.dart';
import '../service/laptop_local_service.dart';
import '../pages/laptop_detail_page.dart';

class UserReviewPage extends StatefulWidget {
  const UserReviewPage({super.key});

  @override
  State<UserReviewPage> createState() => _UserReviewPageState();
}

class _UserReviewPageState extends State<UserReviewPage> {
  late Future<List<Map<String, dynamic>>> _futureReviews;
  Map<String, Laptop> _laptopMap = {};

  @override
  void initState() {
    super.initState();
    _futureReviews = _fetchUserReviews();
  }

  Future<List<Map<String, dynamic>>> _fetchUserReviews() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];
    final reviews = await ReviewService.getReviewsByUser(user.id);
    // Ambil semua laptop yang diulas
    final allLaptops = await LaptopLocalService.loadAllLaptops();
    _laptopMap = {for (var l in allLaptops) l.id: l};
    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Ulasan Saya',
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureReviews,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF008FE5)));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Gagal memuat ulasan', style: TextStyle(color: Colors.red)));
                }
                final reviews = snapshot.data ?? [];
                if (reviews.isEmpty) {
                  return const Center(child: Text('Belum ada ulasan yang kamu buat.', style: TextStyle(color: Colors.black38)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: reviews.length,
                  itemBuilder: (context, i) {
                    final r = reviews[i];
                    final laptop = _laptopMap[r['laptop_id']?.toString() ?? ''];
                    return GestureDetector(
                      onTap: laptop != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LaptopDetailPage(laptop: laptop),
                                ),
                              );
                            }
                          : null,
                      child: Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ...List.generate(5, (j) => Icon(
                                    j < (r['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  )),
                                  const SizedBox(width: 10),
                                  if (laptop != null)
                                    Flexible(
                                      child: Text(
                                        laptop.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF008FE5)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                              if (r['review'] != null && r['review'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                                  child: Text(r['review'], style: const TextStyle(color: Colors.black87)),
                                ),
                              if (r['created_at'] != null)
                                Text(
                                  _formatDate(r['created_at']),
                                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
    } catch (_) {
      return iso;
    }
  }
} 