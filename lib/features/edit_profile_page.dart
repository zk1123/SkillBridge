import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'app_skills.dart';

// ═══════════════════════════════════════════════════════════════════
//  COLORS (same palette as profile page)
// ═══════════════════════════════════════════════════════════════════

class _C {
  static const primary = Color(0xFF2563EB);
  static const background = Color(0xFFF1F5F9);
  static const card = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF0F172A);
  static const textMid = Color(0xFF475569);
  static const textLight = Color(0xFF94A3B8);
  static const divider = Color(0xFFE2E8F0);
  static const tag = Color(0xFFEFF6FF);
  static const tagText = Color(0xFF3B82F6);
  static const gradStart = Color(0xFF1D4ED8);
  static const gradEnd = Color(0xFF34D399);
  static const error = Color(0xFFEF4444);
}

// ═══════════════════════════════════════════════════════════════════
//  CLOUDINARY CONFIG
// ═══════════════════════════════════════════════════════════════════

const _cloudinaryCloudName = 'dbca70ldz';
const _cloudinaryUploadPreset = 'SkillBridgeUploads';

// ═══════════════════════════════════════════════════════════════════
//  EDIT PROFILE PAGE
// ═══════════════════════════════════════════════════════════════════

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late List<String> _teachSkills;
  late List<String> _learnSkills;
  bool _isSaving = false;

  // ── Photo state (Switched to XFile and added memory bytes for Web) ──
  XFile? _pickedImage;
  Uint8List? _webImageBytes;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _bioCtrl = TextEditingController(text: widget.user.bio);
    _teachSkills = List<String>.from(widget.user.teachSkills);
    _learnSkills = List<String>.from(widget.user.learnSkills);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  // ── Pick image from gallery ──
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return;

    // Handle cross-platform states natively
    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedImage = picked;
        _webImageBytes = bytes;
        _isUploadingPhoto = true;
      });
    } else {
      setState(() {
        _pickedImage = picked;
        _isUploadingPhoto = true;
      });
    }

    try {
      final url = await _uploadToCloudinary(_pickedImage!);
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profilePicUrl': url,
      });
      if (!mounted) return;
      _snack('Profile photo updated ✓');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pickedImage = null;
        _webImageBytes = null;
      });
      _snack('Photo upload failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  // ── Upload to Cloudinary ──
  Future<String> _uploadToCloudinary(XFile image) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _cloudinaryUploadPreset;

    // Direct multi-part handling without relying on device file paths
    if (kIsWeb && _webImageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _webImageBytes!,
          filename: image.name,
        ),
      );
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Cloudinary error ${response.statusCode}');
    }
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);
    return json['secure_url'] as String;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Name cannot be empty', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': name,
        'bio': _bioCtrl.text.trim(),
        'teachSkills': _teachSkills,
        'learnSkills': _learnSkills,
      });
      if (!mounted) return;
      _snack('Profile updated ✓');
      Navigator.pop(context, true);
    } catch (e) {
      _snack('Failed to save: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _C.error : _C.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openSkillPicker({
    required String title,
    required List<String> selected,
    required void Function(List<String>) onDone,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SkillPickerSheet(
        title: title,
        selected: List<String>.from(selected),
        onDone: onDone,
      ),
    );
  }

  // ── Avatar widget ──
  Widget _buildAvatar() {
    final currentPhotoUrl = widget.user.profilePicUrl;
    return Center(
      child: Stack(
        children: [
          // Avatar circle
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _C.primary.withOpacity(0.2), width: 3),
              boxShadow: [
                BoxShadow(
                  color: _C.primary.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _webImageBytes != null
                  ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                  : (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty)
                  ? Image.network(
                      currentPhotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(),
                    )
                  : _avatarFallback(),
            ),
          ),

          // Upload overlay / loading
          Positioned.fill(
            child: ClipOval(
              child: _isUploadingPhoto
                  ? Container(
                      color: Colors.black.withOpacity(0.45),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // Camera badge
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _isUploadingPhoto ? null : _pickAndUploadImage,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.gradStart, _C.gradEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    final initials = widget.user.name.isNotEmpty
        ? widget.user.name.trim()[0].toUpperCase()
        : '?';
    return Container(
      color: _C.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: _C.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: _C.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _C.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _C.primary,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: _C.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Avatar ──
          const SizedBox(height: 8),
          _buildAvatar(),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Tap the camera icon to change photo',
              style: TextStyle(fontSize: 12, color: _C.textLight),
            ),
          ),
          const SizedBox(height: 24),

          // ── Name ──
          _SectionLabel(label: 'Display Name'),
          const SizedBox(height: 8),
          _InputField(controller: _nameCtrl, hint: 'Your full name'),
          const SizedBox(height: 20),

          // ── Bio ──
          _SectionLabel(label: 'Bio'),
          const SizedBox(height: 8),
          _InputField(
            controller: _bioCtrl,
            hint: 'Tell the community about yourself...',
            maxLines: 4,
          ),
          const SizedBox(height: 28),

          // ── Teach Skills ──
          _SkillSection(
            title: 'Skills I Can Teach',
            subtitle: 'What can you help others learn?',
            icon: Icons.school_outlined,
            iconColor: _C.primary,
            skills: _teachSkills,
            onEdit: () => _openSkillPicker(
              title: 'Skills I Can Teach',
              selected: _teachSkills,
              onDone: (v) => setState(() => _teachSkills = v),
            ),
          ),
          const SizedBox(height: 16),

          // ── Learn Skills ──
          _SkillSection(
            title: 'Skills I Want to Learn',
            subtitle: 'What are you looking to pick up?',
            icon: Icons.auto_stories_outlined,
            iconColor: const Color(0xFF8B5CF6),
            skills: _learnSkills,
            onEdit: () => _openSkillPicker(
              title: 'Skills I Want to Learn',
              selected: _learnSkills,
              onDone: (v) => setState(() => _learnSkills = v),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SKILL SECTION CARD
// ═══════════════════════════════════════════════════════════════════

class _SkillSection extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color iconColor;
  final List<String> skills;
  final VoidCallback onEdit;

  const _SkillSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.skills,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: _C.textLight),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _C.tag,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.primary.withOpacity(0.2)),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _C.tagText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(color: _C.divider, height: 1),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: skills
                  .map((s) => _SkillChip(label: s, color: iconColor))
                  .toList(),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              'No skills added yet — tap Edit to add some',
              style: TextStyle(
                fontSize: 13,
                color: _C.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SkillChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SKILL PICKER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════

class _SkillPickerSheet extends StatefulWidget {
  final String title;
  final List<String> selected;
  final void Function(List<String>) onDone;

  const _SkillPickerSheet({
    required this.title,
    required this.selected,
    required this.onDone,
  });

  @override
  State<_SkillPickerSheet> createState() => _SkillPickerSheetState();
}

class _SkillPickerSheetState extends State<_SkillPickerSheet> {
  late List<String> _selected;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selected);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggle(String skill) {
    setState(() {
      if (_selected.contains(skill)) {
        _selected.remove(skill);
      } else {
        _selected.add(skill);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _search.isEmpty
        ? AppSkills.byCategory
        : {
            for (final entry in AppSkills.byCategory.entries)
              if (entry.value.any(
                (s) => s.toLowerCase().contains(_search.toLowerCase()),
              ))
                entry.key: entry.value
                    .where(
                      (s) => s.toLowerCase().contains(_search.toLowerCase()),
                    )
                    .toList(),
          };

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _C.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _C.textDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.onDone(_selected);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_C.gradStart, _C.gradEnd],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Done (${_selected.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: _C.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.divider),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _search = v),
                decoration: const InputDecoration(
                  hintText: 'Search skills...',
                  hintStyle: TextStyle(color: _C.textLight, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: _C.textLight,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: _C.divider, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: filtered.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 10),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _C.textLight,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.value.map((skill) {
                        final isSelected = _selected.contains(skill);
                        return GestureDetector(
                          onTap: () => _toggle(skill),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? _C.primary : _C.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? _C.primary : _C.divider,
                              ),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : _C.textMid,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: _C.divider, height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SMALL REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContextcontext) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _C.textMid,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 14,
          color: _C.textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _C.textLight, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
