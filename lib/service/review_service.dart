// Fitur review dinonaktifkan. Semua review hanya dummy statis di ReviewSection.

// ... existing code ...
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService {
  // Dummy review statis
  static List<Map<String, dynamic>> getDummyReviews() {
    return [
      {
        'user': {'display_name': 'Budi'},
        'rating': 5,
        'review': 'Laptop ini sangat bagus dan performanya mantap!',
        'created_at': '',
      },
      {
        'user': {'display_name': 'Siti'},
        'rating': 4,
        'review': 'Desain oke, baterai tahan lama.',
        'created_at': '',
      },
      {
        'user': {'display_name': 'Andi'},
        'rating': 3,
        'review': 'Cukup baik, tapi agak berat.',
        'created_at': '',
      },
    ];
  }

  static Future<List<Map<String, dynamic>>> getReviews(String laptopId) async {
    final supabase = Supabase.instance.client;
    final data = await supabase
        .from('reviews')
        .select()
        .eq('laptop_id', laptopId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<List<Map<String, dynamic>>> getReviewsByUser(String userId) async {
    final supabase = Supabase.instance.client;
    final data = await supabase
        .from('reviews')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> addReview({
    required String laptopId,
    required int rating,
    required String review,
    required String userId,
    required String userName,
    required String avatarUrl,
  }) async {
    final supabase = Supabase.instance.client;
    await supabase.from('reviews').insert({
      'laptop_id': laptopId,
      'rating': rating,
      'review': review,
      'user_id': userId,
      'user_name': userName,
      'avatar_url': avatarUrl,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> updateReview({
    required String reviewId,
    int? rating,
    String? review,
  }) async {
    final supabase = Supabase.instance.client;
    final updates = <String, dynamic>{};
    if (rating != null) updates['rating'] = rating;
    if (review != null) updates['review'] = review;
    if (updates.isEmpty) return;
    await supabase.from('reviews').update(updates).eq('id', reviewId);
  }

  static Future<void> deleteReview({
    required String reviewId,
  }) async {
    final supabase = Supabase.instance.client;
    await supabase.from('reviews').delete().eq('id', reviewId);
  }
} 