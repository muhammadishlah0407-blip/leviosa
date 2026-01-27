import 'package:flutter/material.dart';

class BrandPage extends StatelessWidget {
  // List brand populer (bisa diubah sesuai kebutuhan)
  static const List<String> brands = [
    'Acer', 'Asus', 'Lenovo', 'HP', 'Dell', 'Apple', 'MSI', 'Samsung', 'Toshiba', 'Axioo'
  ];

  const BrandPage({super.key});

  void _onBrandTap(BuildContext context, String brand) {
    // Navigasi ke halaman katalog dengan filter brand
    Navigator.pushNamed(context, '/catalog', arguments: {'brand': brand});
  }

  @override
  Widget build(BuildContext context) {
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
                'Brand Laptop',
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
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: brands.length,
                itemBuilder: (context, i) {
                  final brand = brands[i];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 5,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _onBrandTap(context, brand),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.laptop_mac, color: const Color(0xFF008FE5), size: 44),
                            const SizedBox(height: 12),
                            Text(
                              brand,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF008FE5),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
} 