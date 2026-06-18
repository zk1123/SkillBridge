import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reviews_controller.dart';

// ═══════════════════════════════════════════════════════════════════
//  COLORS & STYLES
// ═══════════════════════════════════════════════════════════════════

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF1F5F9);
  static const card = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF0F172A);
  static const textMid = Color(0xFF475569);
  static const textLight = Color(0xFF94A3B8);
  static const divider = Color(0xFFE2E8F0);
  static const tag = Color(0xFFEFF6FF);
  static const tagText = Color(0xFF3B82F6);
  static const gradStart = Color(0xFF1D4ED8);
  static const gradMid = Color(0xFF2563EB);
  static const gradEnd = Color(0xFF34D399);
  static const green = Color(0xFF059669);
}

class AppTextStyles {
  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.2,
  );
  static const titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMid,
    height: 1.6,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.2,
  );
  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMid,
  );
}

// ═══════════════════════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════════════════════

class _ExperienceData {
  String title, company, date;
  _ExperienceData(this.title, this.company, this.date);
}

// ═══════════════════════════════════════════════════════════════════
//  PROFILE DATA (per user)
// ═══════════════════════════════════════════════════════════════════

class ProfileData {
  final String userId;
  final String name;
  final String title;
  final String location;
  final String about;
  final String imageUrl;
  final List<String> skills;
  final List<_ExperienceData> experience;
  final String email, phone, website, github, linkedin, portfolio;
  final int followers;
  final int yearsExperience;

  ProfileData({
    required this.userId,
    required this.name,
    required this.title,
    required this.location,
    required this.about,
    required this.imageUrl,
    required this.skills,
    required this.experience,
    required this.email,
    required this.phone,
    required this.website,
    required this.github,
    required this.linkedin,
    required this.portfolio,
    this.followers = 0,
    this.yearsExperience = 0,
  });

  // 🆕 Marwan Hussien's profile
  static ProfileData marwan() => ProfileData(
    userId: 'marwan_hussien',
    name: 'Marwan Hussien',
    title: 'Flutter Expert & Video Editor',
    location: 'Cairo, Egypt',
    about:
        'Passionate Mobile Developer specializing in high-performance Flutter apps '
        'and creative video storytelling. Based in Cairo, working globally.',
    imageUrl: 'https://i.postimg.cc/z3ZzXWGc/Marwan.webp',
    skills: [
      'Flutter',
      'Dart',
      'Firebase',
      'iOS',
      'Android',
      'Video Editing',
      'Figma',
    ],
    experience: [
      _ExperienceData('Senior Developer', 'SkillBridge Tech', '2022 – Present'),
      _ExperienceData('Mobile Lead', 'AppWorld Egypt', '2019 – 2022'),
      _ExperienceData('Junior Programmer', 'Startup Hub', '2016 – 2019'),
    ],
    email: 'marwan.dev@example.com',
    phone: '+20 112 345 6789',
    website: 'www.marwan-dev.com',
    github: 'github.com/marwandev',
    linkedin: 'linkedin.com/in/marwandev',
    portfolio: 'marwan-dev.com/portfolio',
    followers: 12000,
    yearsExperience: 8,
  );

  // 🆕 Mohamed Nukbassy's profile
  static ProfileData mohamed() => ProfileData(
    userId: 'mohamed_nukbassy',
    name: 'Mohamed Nukbassy',
    title: 'Senior Mobile Engineer & Mentor',
    location: 'Alexandria, Egypt',
    about:
        'Mobile engineer and mentor with 10+ years of experience building '
        'scalable apps. Passionate about teaching Flutter, system design, and clean architecture.',
    imageUrl: 'https://i.postimg.cc/QtQ8gFb3/Mohamed.webp',
    skills: [
      'Flutter',
      'Kotlin',
      'Swift',
      'System Design',
      'Clean Architecture',
      'Mentoring',
    ],
    experience: [
      _ExperienceData(
        'Senior Mobile Engineer',
        'SkillBridge',
        '2021 – Present',
      ),
      _ExperienceData('Mobile Lead', 'TechCorp', '2018 – 2021'),
      _ExperienceData('Android Developer', 'AppHub', '2014 – 2018'),
    ],
    email: 'mohamed.nukbassy@example.com',
    phone: '+20 100 123 4567',
    website: 'www.mohamed-dev.com',
    github: 'github.com/mohamednukbassy',
    linkedin: 'linkedin.com/in/mohamednukbassy',
    portfolio: 'mohamed-dev.com/portfolio',
    followers: 18500,
    yearsExperience: 10,
  );
}

// ═══════════════════════════════════════════════════════════════════
//  PROFILE PAGE
// ═══════════════════════════════════════════════════════════════════

class ProfilePage extends StatefulWidget {
  /// 🆕 The profile data to display. Defaults to Marwan if not provided.
  final ProfileData? profile;

  /// 🆕 If true, shows Edit Profile button (only for own profile).
  /// If false, shows Hire Me button (for others' profiles).
  final bool isOwnProfile;

  const ProfilePage({super.key, this.profile, this.isOwnProfile = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileData _profile;

  // Editable copies (only used when isOwnProfile)
  late String _name, _title, _location, _about;
  late String _email, _phone, _website, _github, _linkedin, _portfolio;
  late List<String> _skills;
  late List<_ExperienceData> _exp;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile ?? ProfileData.marwan();
    _name = _profile.name;
    _title = _profile.title;
    _location = _profile.location;
    _about = _profile.about;
    _email = _profile.email;
    _phone = _profile.phone;
    _website = _profile.website;
    _github = _profile.github;
    _linkedin = _profile.linkedin;
    _portfolio = _profile.portfolio;
    _skills = List.from(_profile.skills);
    _exp = _profile.experience
        .map((e) => _ExperienceData(e.title, e.company, e.date))
        .toList();

    // 🆕 Listen for review changes
    ReviewsController.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    ReviewsController.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ── Actions ──

  void _openEditSheet() {
    final nameCtrl = TextEditingController(text: _name);
    final titleCtrl = TextEditingController(text: _title);
    final locationCtrl = TextEditingController(text: _location);
    final aboutCtrl = TextEditingController(text: _about);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);
    final websiteCtrl = TextEditingController(text: _website);
    final githubCtrl = TextEditingController(text: _github);
    final linkedinCtrl = TextEditingController(text: _linkedin);
    final portfolioCtrl = TextEditingController(text: _portfolio);
    final skillsNotifier = ValueNotifier<List<String>>(List.from(_skills));
    final expNotifier = ValueNotifier<List<_ExperienceData>>(
      _exp.map((e) => _ExperienceData(e.title, e.company, e.date)).toList(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        nameCtrl: nameCtrl,
        titleCtrl: titleCtrl,
        locationCtrl: locationCtrl,
        aboutCtrl: aboutCtrl,
        emailCtrl: emailCtrl,
        phoneCtrl: phoneCtrl,
        websiteCtrl: websiteCtrl,
        githubCtrl: githubCtrl,
        linkedinCtrl: linkedinCtrl,
        portfolioCtrl: portfolioCtrl,
        skillsNotifier: skillsNotifier,
        expNotifier: expNotifier,
        onSave: () {
          setState(() {
            _name = nameCtrl.text.trim().isNotEmpty
                ? nameCtrl.text.trim()
                : _name;
            _title = titleCtrl.text.trim().isNotEmpty
                ? titleCtrl.text.trim()
                : _title;
            _location = locationCtrl.text.trim().isNotEmpty
                ? locationCtrl.text.trim()
                : _location;
            _about = aboutCtrl.text.trim().isNotEmpty
                ? aboutCtrl.text.trim()
                : _about;
            _email = emailCtrl.text.trim();
            _phone = phoneCtrl.text.trim();
            _website = websiteCtrl.text.trim();
            _github = githubCtrl.text.trim();
            _linkedin = linkedinCtrl.text.trim();
            _portfolio = portfolioCtrl.text.trim();
            _skills = List.from(skillsNotifier.value);
            _exp = List.from(expNotifier.value);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showQrCode() {
    final profileUrl = 'https://skillbridge.app/profile/${_profile.userId}';
    final qrImageUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=220x220'
        '&data=${Uri.encodeComponent(profileUrl)}'
        '&bgcolor=ffffff&color=1d4ed8&margin=10';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gradStart, AppColors.gradEnd],
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.qr_code_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Scan to view profile',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textLight,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    qrImageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: Icon(
                          Icons.qr_code_rounded,
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        profileUrl,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMid,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: profileUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Link copied!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllReviews() {
    final reviews = ReviewsController.instance.getReviewsFor(_profile.userId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AllReviewsSheet(reviews: reviews, userName: _name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _ProfileSliverHeader(
            name: _name,
            title: _title,
            imageUrl: _profile.imageUrl,
            isOwnProfile: widget.isOwnProfile,
            onEditProfile: _openEditSheet,
            onShare: _showQrCode,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsRow(
                    location: _location,
                    userId: _profile.userId,
                    followers: _profile.followers,
                    years: _profile.yearsExperience,
                  ),
                  const SizedBox(height: 24),
                  _CardSection(
                    title: 'About',
                    child: Text(_about, style: AppTextStyles.body),
                  ),
                  const SizedBox(height: 16),
                  _CardSection(
                    title: 'Skills',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills
                          .map((s) => _SkillTag(label: s))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CardSection(
                    title: 'Experience',
                    child: Column(
                      children: _exp
                          .asMap()
                          .entries
                          .map(
                            (e) => _ExperienceRow(
                              data: e.value,
                              isLast: e.key == _exp.length - 1,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LinksSection(
                    github: _github,
                    linkedin: _linkedin,
                    portfolio: _portfolio,
                  ),
                  const SizedBox(height: 16),
                  _ReviewsSection(
                    userId: _profile.userId,
                    onSeeAll: _showAllReviews,
                  ),
                  const SizedBox(height: 16),
                  _CardSection(
                    title: 'Contact',
                    child: Column(
                      children: [
                        _ContactRow(icon: Icons.email_outlined, text: _email),
                        _ContactRow(
                          icon: Icons.phone_android_outlined,
                          text: _phone,
                        ),
                        _ContactRow(
                          icon: Icons.language_outlined,
                          text: _website,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PROFILE SLIVER HEADER
// ═══════════════════════════════════════════════════════════════════

class _ProfileSliverHeader extends StatelessWidget {
  final String name, title, imageUrl;
  final bool isOwnProfile;
  final VoidCallback onEditProfile, onShare;
  const _ProfileSliverHeader({
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.isOwnProfile,
    required this.onEditProfile,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradStart, AppColors.gradMid, AppColors.gradEnd],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.07,
                child: CustomPaint(painter: _DotPatternPainter()),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Top bar — back (if viewing other) + more
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        if (!isOwnProfile)
                          _GlassBtn(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                        const Spacer(),
                        _GlassBtn(icon: Icons.more_horiz_rounded, onTap: () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 36,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Georgia',
                      letterSpacing: -0.3,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _HeaderActionBtn(
                            label: isOwnProfile ? 'Edit Profile' : 'Message',
                            icon: isOwnProfile
                                ? Icons.edit_outlined
                                : Icons.chat_bubble_outline_rounded,
                            filled: true,
                            onTap: isOwnProfile
                                ? onEditProfile
                                : () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _HeaderActionBtn(
                            label: 'Share',
                            icon: Icons.qr_code_rounded,
                            filled: false,
                            onTap: onShare,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  LINKS SECTION
// ═══════════════════════════════════════════════════════════════════

class _LinksSection extends StatelessWidget {
  final String github, linkedin, portfolio;
  const _LinksSection({
    required this.github,
    required this.linkedin,
    required this.portfolio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
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
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.gradEnd],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Links', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _LinkButton(
                icon: Icons.code_rounded,
                label: 'GitHub',
                color: const Color(0xFF333333),
                url: github,
                context: context,
              ),
              const SizedBox(width: 10),
              _LinkButton(
                icon: Icons.business_rounded,
                label: 'LinkedIn',
                color: const Color(0xFF0A66C2),
                url: linkedin,
                context: context,
              ),
              const SizedBox(width: 10),
              _LinkButton(
                icon: Icons.language_rounded,
                label: 'Portfolio',
                color: AppColors.primary,
                url: portfolio,
                context: context,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label, url;
  final Color color;
  final BuildContext context;
  const _LinkButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.url,
    required this.context,
  });

  @override
  Widget build(_) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $url'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  REVIEWS SECTION — reads from ReviewsController
// ═══════════════════════════════════════════════════════════════════

class _ReviewsSection extends StatelessWidget {
  final String userId;
  final VoidCallback onSeeAll;
  const _ReviewsSection({required this.userId, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final reviews = ReviewsController.instance.getReviewsFor(userId);
    final count = reviews.length;
    final avgRating = ReviewsController.instance.averageRatingFor(userId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
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
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.gradEnd],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Reviews', style: AppTextStyles.titleLarge),
              const Spacer(),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFFFB300)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (count == 0)
            _emptyReviews()
          else ...[
            ...reviews.take(2).map((r) => _ReviewItem(review: r)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.gradStart,
                      AppColors.gradMid,
                      AppColors.gradEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'See All $count Review${count > 1 ? "s" : ""}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyReviews() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: Color(0xFFF59E0B),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Reviews from sessions will appear here',
            style: TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;
  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: review.reviewerImage.isNotEmpty
                    ? Image.network(
                        review.reviewerImage,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _fallbackAvatar(review.reviewerName),
                      )
                    : _fallbackAvatar(review.reviewerName),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewerName, style: AppTextStyles.titleMedium),
                    Text(review.formattedDate, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 14,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(review.comment, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar(String name) {
    return Container(
      width: 42,
      height: 42,
      color: AppColors.tag,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ALL REVIEWS SHEET
// ═══════════════════════════════════════════════════════════════════

class _AllReviewsSheet extends StatelessWidget {
  final List<Review> reviews;
  final String userName;
  const _AllReviewsSheet({required this.reviews, required this.userName});

  @override
  Widget build(BuildContext context) {
    final count = reviews.length;
    final avg = count == 0
        ? 0.0
        : reviews.fold<double>(0, (s, r) => s + r.rating) / count;

    return Container(
      height: MediaQuery.of(context).size.height * 0.87,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFFFB300)],
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviews for $userName',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '$count total review${count != 1 ? "s" : ""}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFFFB300)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${avg.toStringAsFixed(1)} ★',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 24, color: AppColors.divider.withOpacity(0.5)),
          Expanded(
            child: count == 0
                ? const Center(
                    child: Text(
                      'No reviews yet',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    children: reviews
                        .map((r) => _ReviewItem(review: r))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EDIT PROFILE SHEET
// ═══════════════════════════════════════════════════════════════════

class _EditProfileSheet extends StatefulWidget {
  final TextEditingController nameCtrl, titleCtrl, locationCtrl, aboutCtrl;
  final TextEditingController emailCtrl, phoneCtrl, websiteCtrl;
  final TextEditingController githubCtrl, linkedinCtrl, portfolioCtrl;
  final ValueNotifier<List<String>> skillsNotifier;
  final ValueNotifier<List<_ExperienceData>> expNotifier;
  final VoidCallback onSave;

  const _EditProfileSheet({
    required this.nameCtrl,
    required this.titleCtrl,
    required this.locationCtrl,
    required this.aboutCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.websiteCtrl,
    required this.githubCtrl,
    required this.linkedinCtrl,
    required this.portfolioCtrl,
    required this.skillsNotifier,
    required this.expNotifier,
    required this.onSave,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _newSkillCtrl = TextEditingController();

  @override
  void dispose() {
    _newSkillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.93,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gradStart, AppColors.gradEnd],
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: widget.onSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gradStart, AppColors.gradEnd],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 24, color: AppColors.divider.withOpacity(0.5)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                children: [
                  _sectionTitle('Basic Info'),
                  const SizedBox(height: 12),
                  _field(
                    'Full Name',
                    widget.nameCtrl,
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _field('Title', widget.titleCtrl, Icons.work_outline_rounded),
                  const SizedBox(height: 12),
                  _field(
                    'Location',
                    widget.locationCtrl,
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('About'),
                  const SizedBox(height: 12),
                  _field(
                    'About',
                    widget.aboutCtrl,
                    Icons.info_outline_rounded,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('Skills'),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<List<String>>(
                    valueListenable: widget.skillsNotifier,
                    builder: (_, skills, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: skills
                              .map(
                                (s) => _EditableChip(
                                  label: s,
                                  onDelete: () => widget.skillsNotifier.value =
                                      List.from(skills)..remove(s),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newSkillCtrl,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Add a skill...',
                                  hintStyle: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 13,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                final s = _newSkillCtrl.text.trim();
                                if (s.isNotEmpty && !skills.contains(s)) {
                                  widget.skillsNotifier.value = [...skills, s];
                                  _newSkillCtrl.clear();
                                }
                              },
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.gradStart,
                                      AppColors.gradEnd,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('Links'),
                  const SizedBox(height: 12),
                  _field('GitHub URL', widget.githubCtrl, Icons.code_rounded),
                  const SizedBox(height: 12),
                  _field(
                    'LinkedIn URL',
                    widget.linkedinCtrl,
                    Icons.business_rounded,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    'Portfolio URL',
                    widget.portfolioCtrl,
                    Icons.language_outlined,
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('Contact'),
                  const SizedBox(height: 12),
                  _field('Email', widget.emailCtrl, Icons.email_outlined),
                  const SizedBox(height: 12),
                  _field(
                    'Phone',
                    widget.phoneCtrl,
                    Icons.phone_android_outlined,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    'Website',
                    widget.websiteCtrl,
                    Icons.language_outlined,
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('Experience'),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<List<_ExperienceData>>(
                    valueListenable: widget.expNotifier,
                    builder: (_, exp, _) => Column(
                      children: [
                        ...exp.asMap().entries.map((entry) {
                          final i = entry.key;
                          final e = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Column(
                              children: [
                                _inlineField('Job Title', e.title, (v) {
                                  widget.expNotifier.value = List.from(exp)
                                    ..[i].title = v;
                                }),
                                const SizedBox(height: 8),
                                _inlineField('Company', e.company, (v) {
                                  widget.expNotifier.value = List.from(exp)
                                    ..[i].company = v;
                                }),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _inlineField('Period', e.date, (
                                        v,
                                      ) {
                                        widget.expNotifier.value = List.from(
                                          exp,
                                        )..[i].date = v;
                                      }),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        final updated =
                                            List<_ExperienceData>.from(exp)
                                              ..removeAt(i);
                                        widget.expNotifier.value = updated;
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Color(0xFFEF4444),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: () {
                            widget.expNotifier.value = [
                              ...exp,
                              _ExperienceData(
                                'New Role',
                                'Company',
                                '2024 – Present',
                              ),
                            ];
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: AppColors.tag,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Add Experience',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.gradEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _inlineField(
    String label,
    String initial,
    ValueChanged<String> onChanged,
  ) {
    return TextField(
      controller: TextEditingController(text: initial),
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11, color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}

class _EditableChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;
  const _EditableChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tag,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.tagText,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  HEADER BUTTONS
// ═══════════════════════════════════════════════════════════════════

class _HeaderActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  const _HeaderActionBtn({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: filled
              ? null
              : Border.all(color: Colors.white.withOpacity(0.45), width: 1.2),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: filled ? AppColors.primary : Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: filled ? AppColors.primary : Colors.white,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STATS ROW — uses ReviewsController for count
// ═══════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  final String location;
  final String userId;
  final int followers;
  final int years;
  const _StatsRow({
    required this.location,
    required this.userId,
    required this.followers,
    required this.years,
  });

  String _formatNumber(int n) {
    if (n >= 1000)
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final reviewCount = ReviewsController.instance.countFor(userId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.tag,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.tagText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _PStat(
                value: '$reviewCount',
                label: 'Reviews',
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFF59E0B),
              ),
              _VDivider(),
              _PStat(
                value: _formatNumber(followers),
                label: 'Followers',
                icon: Icons.people_alt_outlined,
                iconColor: AppColors.primary,
              ),
              _VDivider(),
              _PStat(
                value: '$years yrs',
                label: 'Experience',
                icon: Icons.workspace_premium_outlined,
                iconColor: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color iconColor;
  const _PStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textDark,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 48, color: AppColors.divider);
}

// ═══════════════════════════════════════════════════════════════════
//  CARD SECTION
// ═══════════════════════════════════════════════════════════════════

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _CardSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
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
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.gradEnd],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EXPERIENCE ROW
// ═══════════════════════════════════════════════════════════════════

class _ExperienceRow extends StatelessWidget {
  final _ExperienceData data;
  final bool isLast;
  const _ExperienceRow({required this.data, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.tag,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.work_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            if (!isLast)
              Container(width: 1.5, height: 24, color: AppColors.divider),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(data.title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(data.company, style: AppTextStyles.label),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tag,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.date,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.tagText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  CONTACT ROW
// ═══════════════════════════════════════════════════════════════════

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;
  const _ContactRow({
    required this.icon,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.tag,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Text(text, style: AppTextStyles.label),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _SkillTag extends StatelessWidget {
  final String label;
  const _SkillTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tag,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.tagText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
