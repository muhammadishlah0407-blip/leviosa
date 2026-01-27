import 'package:flutter/material.dart';
// import wishlist service jika ingin tombol wishlist
// import 'package:leviosa/service/wishlist_service.dart';

class DetailLaptopDialog extends StatelessWidget {
  final dynamic laptop; // Gunakan model Laptop jika sudah diimport
  const DetailLaptopDialog({super.key, required this.laptop});

  @override
  Widget build(BuildContext context) {
    // Penanganan specs agar selalu List<String> tanpa error
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    laptop.image,
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
                laptop.name,
                style: const TextStyle(
                  color: Color(0xFF008FE5),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                laptop.brand,
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
                    children: specs.isEmpty
                        ? [const Text('Tidak ada spesifikasi', style: TextStyle(color: Colors.black87, fontSize: 15))]
                        : specs.map<Widget>((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text('• $s', style: const TextStyle(color: Colors.black87, fontSize: 15)),
                          )).toList(),
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
                      onPressed: () {
                        // TODO: Tambah/hapus wishlist
                      },
                      icon: Icon(Icons.favorite_border, color: Colors.white),
                      label: Text('Tambah Wishlist'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
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
            ],
          ),
        ),
      ),
    );
  }
} 