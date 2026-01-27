import 'dart:convert';
import 'package:flutter/services.dart';

class Laptop {
  final String id;
  final String name;
  final String brand;
  final String price;
  final String image;
  final String specs;
  final double rating;
  final int reviews;
  final String description;

  Laptop({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.image,
    required this.specs,
    required this.rating,
    required this.reviews,
    required this.description,
  });

  factory Laptop.fromJson(Map<String, dynamic> json) {
    return Laptop(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: json['price'] ?? '',
      image: json['image'] ?? '',
      specs: json['specs'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: (json['reviews'] ?? 0).toInt(),
      description: json['description'] ?? '',
    );
  }
}

class LaptopLocalService {
  static Future<List<Laptop>> loadAllLaptops() async {
    final String jsonString = await rootBundle.loadString(
      'assets/laptops.json',
    );
    final List<dynamic> data = json.decode(jsonString);
    return data.map((e) => Laptop.fromJson(e)).toList();
  }

  static List<String> gamingKeywords = [
    'gaming',
    'rog',
    'predator',
    'legion',
    'alienware',
    'tuf',
    'omen',
    'strix',
    'msi',
  ];
  static List<String> ultrabookKeywords = [
    'ultrabook',
    'xps',
    'macbook',
    'zenbook',
    'swift',
    'gram',
    'spectre',
    'thin',
  ];
  static List<String> workstationKeywords = [
    'thinkpad',
    'workstation',
    'precision',
    'zbook',
    'elitebook',
    'probook',
  ];

  // Filter laptop berdasarkan kategori
  static List<Laptop> filterByCategory(
    List<Laptop> laptops,
    List<String> keywords,
  ) {
    return laptops
        .where(
          (laptop) => keywords.any(
            (kw) =>
                laptop.name.toLowerCase().contains(kw) ||
                laptop.brand.toLowerCase().contains(kw) ||
                laptop.specs.toLowerCase().contains(kw),
          ),
        )
        .toList();
  }

  // Filter laptop berdasarkan brand
  static List<Laptop> filterByBrand(List<Laptop> laptops, String brand) {
    return laptops
        .where((laptop) => laptop.brand.toLowerCase() == brand.toLowerCase())
        .toList();
  }

  // Search laptop berdasarkan nama, brand, atau spesifikasi
  static List<Laptop> searchLaptops(List<Laptop> laptops, String query) {
    final q = query.toLowerCase();
    return laptops
        .where(
          (laptop) =>
              laptop.name.toLowerCase().contains(q) ||
              laptop.brand.toLowerCase().contains(q) ||
              laptop.specs.toLowerCase().contains(q),
        )
        .toList();
  }
}
