import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:leviosa/service/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _email = '-';
  bool _loading = true;
  bool _avatarUploading = false;
  File? _selectedImage;
  String? _avatarUrl;
  static Map<String, dynamic>? _cachedProfile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      if (_cachedProfile != null) {
        _nameController.text = _cachedProfile!['display_name'] ?? '';
        _bioController.text = _cachedProfile!['bio'] ?? '';
        _email = _cachedProfile!['email'] ?? '-';
        _avatarUrl = _cachedProfile!['avatar_url'];
        setState(() { _loading = false; });
        // tetap fetch di background
      }
      final supabase = Supabase.instance.client;
      final profile =
          await supabase
              .from('profiles')
              .select('display_name, bio, email, avatar_url')
              .eq('id', user.id)
              .single();
      _nameController.text = profile['display_name'] ?? '';
      _bioController.text = profile['bio'] ?? '';
      _email = profile['email'] ?? '-';
      _avatarUrl = profile['avatar_url'];
      _cachedProfile = profile;
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _pickAndUploadImage() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _avatarUploading = true);

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) {
      setState(() => _avatarUploading = false);
      return;
    }

    final fileExt = picked.name.split('.').last;
    final filePath =
        '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final storage = Supabase.instance.client.storage;

    try {
      if (kIsWeb) {
        // Untuk web, upload dengan bytes
        final bytes = await picked.readAsBytes();
        final response = await storage
            .from('avatars')
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
        print('UPLOAD RESPONSE (web): $response');
      } else {
        // Untuk Android/iOS, upload dengan File
        final file = File(picked.path);
        final response = await storage
            .from('avatars')
            .upload(
              filePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        print('UPLOAD RESPONSE (android): $response');
      }

      // Dapatkan public URL
      final publicUrl = storage.from('avatars').getPublicUrl(filePath);

      // Simpan URL ke database
      await Supabase.instance.client
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id);

      if (mounted) {
        setState(() {
          _avatarUrl = publicUrl;
          _selectedImage = !kIsWeb ? File(picked.path) : null;
          _avatarUploading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _avatarUploading = false);
      print('UPLOAD EXCEPTION: $e');
    }
  }

  Future<void> _saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await AuthService().updateProfile(
        userId: user.id,
        displayName: _nameController.text,
        avatarUrl: _avatarUrl,
      );
      // Jika ada bio, tetap update langsung (atau bisa tambahkan ke service jika perlu)
      await Supabase.instance.client
          .from('profiles')
          .update({'bio': _bioController.text})
          .eq('id', user.id);
    }
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
                'Edit Profil',
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 44,
                                backgroundColor: Colors.blue[50],
                                backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty ? NetworkImage(_avatarUrl!) : null,
                                child: _avatarUrl == null || _avatarUrl!.isEmpty
                                    ? const Icon(Icons.person, size: 48, color: Color(0xFF008FE5))
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _avatarUploading ? null : _pickAndUploadImage,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: _avatarUploading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF008FE5)),
                                          )
                                        : const Icon(Icons.edit, size: 20, color: Color(0xFF008FE5)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            labelStyle: const TextStyle(color: Color(0xFF008FE5)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _emailController..text = _email,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Color(0xFF008FE5)),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _bioController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Bio',
                            labelStyle: const TextStyle(color: Color(0xFF008FE5)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : () async {
                              setState(() { _loading = true; });
                              await _saveProfile();
                              setState(() { _loading = false; });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profil berhasil disimpan!')),
                                );
                              }
                              if (!_loading && mounted) {
                                Navigator.pop(context, {
                                  'name': _nameController.text,
                                  'email': _email,
                                  'bio': _bioController.text,
                                  'avatar_url': _avatarUrl ?? '',
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF008FE5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            child: _loading
                                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Simpan Perubahan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
