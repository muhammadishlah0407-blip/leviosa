import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/review_service.dart';

class ReviewSection extends StatefulWidget {
  final String laptopId;
  const ReviewSection({super.key, required this.laptopId});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final _controller = TextEditingController();
  final _nameController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;
  late Future<List<Map<String, dynamic>>> _futureReviews;

  @override
  void initState() {
    super.initState();
    _futureReviews = ReviewService.getReviews(widget.laptopId);
  }

  void _refreshReviews() {
    setState(() {
      _futureReviews = ReviewService.getReviews(widget.laptopId);
    });
  }

  Future<void> _submitReview() async {
    if (_rating == 0 || _controller.text.trim().isEmpty || _nameController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk mengirim ulasan!')),
      );
      return;
    }
    final inputName = _nameController.text.trim();
    try {
      final supabase = Supabase.instance.client;
      final profile = await supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      final avatarUrl = profile?['avatar_url'] ?? '';
      await ReviewService.addReview(
        laptopId: widget.laptopId.toString(),
        rating: _rating,
        review: _controller.text.trim(),
        userId: user.id,
        userName: inputName,
        avatarUrl: avatarUrl,
      );
      _controller.clear();
      _nameController.clear();
      setState(() {
        _rating = 0;
        _isSubmitting = false;
      });
      _refreshReviews();
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim ulasan: $e')),
      );
    }
  }

  Future<void> _editReviewDialog(Map<String, dynamic> review) async {
    final TextEditingController editController = TextEditingController(text: review['review'] ?? '');
    int editRating = review['rating'] ?? 0;
    bool isLoading = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Ulasan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) => IconButton(
                      icon: Icon(
                        i < editRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () => setState(() => editRating = i + 1),
                    )),
                  ),
                  TextField(
                    controller: editController,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: 'Edit komentar...'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          await ReviewService.updateReview(
                            reviewId: review['id'].toString(),
                            rating: editRating,
                            review: editController.text.trim(),
                          );
                          setState(() => isLoading = false);
                          Navigator.pop(context);
                          _refreshReviews();
                        },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteReview(String reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Ulasan'),
        content: const Text('Yakin ingin menghapus ulasan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      await ReviewService.deleteReview(reviewId: reviewId);
      _refreshReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    print('DEBUG laptopId fetch: [33m${widget.laptopId} (${widget.laptopId.runtimeType})[0m');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Ulasan Pengguna',
          style: TextStyle(
            color: Color(0xFF008FE5),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        if (user != null) ...[
          Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 14, left: 4, right: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tulis Ulasan Anda:', style: TextStyle(color: Color(0xFF008FE5), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    enabled: !_isSubmitting,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Nama Anda',
                      hintStyle: const TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) => IconButton(
                      icon: Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: _isSubmitting ? null : () => setState(() => _rating = i + 1),
                    )),
                  ),
                  TextField(
                    controller: _controller,
                    enabled: !_isSubmitting,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar... (minimal 1 kata)',
                      hintStyle: const TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008FE5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: _isSubmitting ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Kirim Ulasan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureReviews,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF008FE5)));
            }
            if (snapshot.hasError) {
              return const Text('Gagal memuat ulasan', style: TextStyle(color: Colors.red));
            }
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Belum ada ulasan', style: TextStyle(color: Colors.black38)),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reviews.map(
                (r) {
                  final isMyReview = user != null && r['user_id'] == user.id;
                  return ScaleOnTap(
                    onTap: null,
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        child: ListTile(
                          leading: (r['avatar_url'] != null && r['avatar_url'].toString().isNotEmpty)
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(r['avatar_url']),
                                  radius: 22,
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    (r['user_name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: Color(0xFF008FE5)),
                                  ),
                                ),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < (r['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r['user_name'] ?? 'User',
                                  style: const TextStyle(
                                    color: Color(0xFF008FE5),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isMyReview)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18, color: Color(0xFF008FE5)),
                                      tooltip: 'Edit',
                                      onPressed: () => _editReviewDialog(r),
                                      constraints: BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                                      tooltip: 'Hapus',
                                      onPressed: () => _deleteReview(r['id'].toString()),
                                      constraints: BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              if (r['review'] != null && r['review'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    r['review'],
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            );
          },
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
