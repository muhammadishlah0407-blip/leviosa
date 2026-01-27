import 'package:flutter/material.dart';
import 'package:leviosa/service/laptop_local_service.dart';

class KategoriPage extends StatelessWidget {
  final String kategori;
  const KategoriPage(this.kategori, {super.key});

  List<Laptop> filterByCategory(List<Laptop> all, String kategori) {
    List<String> keywords = [];
    if (kategori == 'Gaming') {
      keywords = LaptopLocalService.gamingKeywords;
    } else if (kategori == 'Ultrabook') {
      keywords = LaptopLocalService.ultrabookKeywords;
    } else if (kategori == 'Workstation') {
      keywords = LaptopLocalService.workstationKeywords;
    }
    return all.where((l) => keywords.any((kw) => l.name.toLowerCase().contains(kw) || l.brand.toLowerCase().contains(kw) || l.specs.toLowerCase().contains(kw))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      'Gaming', 'Ultrabook', '2-in-1', 'Business', 'Student', 'Multimedia', 'Chromebook', 'Workstation', 'Entry Level', 'Premium'
    ];
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
                'Kategori Laptop',
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
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final category = categories[i];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 5,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.pushNamed(context, '/catalog', arguments: {'category': category});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category, color: const Color(0xFF008FE5), size: 44),
                            const SizedBox(height: 12),
                            Text(
                              category,
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