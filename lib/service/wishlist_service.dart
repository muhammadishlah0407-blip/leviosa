import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistService {
  final supabase = Supabase.instance.client;

  // Tambah laptop ke wishlist
  Future<void> addToWishlist({required String laptopId}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await supabase.from('wishlist').insert({
      'user_id': user.id,
      'laptop_id': laptopId,
    });
  }

  // Hapus laptop dari wishlist
  Future<void> removeFromWishlist({required String laptopId}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await supabase.from('wishlist').delete().match({
      'user_id': user.id,
      'laptop_id': laptopId,
    });
  }

  // Ambil semua wishlist user
  Future<List<String>> getWishlistLaptopIds() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final res = await supabase
        .from('wishlist')
        .select('laptop_id')
        .eq('user_id', user.id);
    return List<String>.from(res.map((e) => e['laptop_id']));
  }
}
