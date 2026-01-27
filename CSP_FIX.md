# Perbaikan Content Security Policy (CSP)

## Masalah yang Ditemukan

Aplikasi Flutter web mengalami error Content Security Policy (CSP) karena mencoba melakukan request ke external API yang tidak diizinkan:

```
Refused to connect to 'https://dummyjson.com/products/1' because it violates the following Content Security Policy directive
```

## Solusi yang Diterapkan

### 1. Perbaikan CSP di `web/index.html`

**Sebelum:**
```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self' data: gap: https://ssl.gstatic.com https://fonts.gstatic.com 'unsafe-eval' 'unsafe-inline'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; media-src *; img-src 'self' data: content:;">
```

**Sesudah:**
```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self' data: gap: https://ssl.gstatic.com https://fonts.gstatic.com 'unsafe-eval' 'unsafe-inline'; connect-src 'self' https://vgfpiqzjsozomsvrnrtb.supabase.co https://*.supabase.co; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; media-src *; img-src 'self' data: content:;">
```

### 2. Penggantian API External dengan Data Lokal

**File:** `lib/pages/dashboard.dart`

- Menghapus penggunaan `dummyjson.com` API
- Mengganti dengan data sales lokal untuk setiap brand
- Menghapus dependency `http` yang tidak diperlukan

**Data Lokal yang Digunakan:**
```dart
final Map<String, List<int>> localData = {
  'Asus': [85, 92, 78, 95, 88, 91],
  'Acer': [72, 85, 90, 83, 87, 79],
  'Lenovo': [88, 95, 82, 89, 93, 86],
  'HP': [75, 88, 92, 85, 90, 83],
  'Dell': [90, 87, 94, 88, 85, 92],
  'MSI': [82, 89, 85, 91, 87, 94],
  'Apple': [95, 98, 92, 96, 94, 97],
};
```

### 3. Pembersihan Dependencies

**File:** `pubspec.yaml`
- Menghapus dependency `http: ^1.4.0` yang tidak lagi diperlukan

## Keuntungan Solusi Ini

1. **Keamanan:** Tidak ada lagi request ke external API yang tidak terpercaya
2. **Performa:** Data lokal lebih cepat karena tidak perlu network request
3. **Reliabilitas:** Tidak bergantung pada ketersediaan external API
4. **Offline:** Aplikasi tetap berfungsi tanpa koneksi internet
5. **CSP Compliant:** Tidak melanggar kebijakan keamanan browser

## Testing

Setelah perubahan ini, aplikasi Flutter web seharusnya:
- Tidak lagi menampilkan error CSP
- Sales chart tetap berfungsi dengan data lokal
- Supabase authentication tetap berfungsi normal
- Tidak ada lagi request ke dummyjson.com

## Catatan

Jika di masa depan diperlukan data real-time dari external API, pastikan untuk:
1. Menambahkan domain API ke CSP `connect-src`
2. Menggunakan API yang aman dan terpercaya
3. Menambahkan error handling yang proper
4. Mempertimbangkan fallback ke data lokal 