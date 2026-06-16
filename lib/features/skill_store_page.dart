import 'package:flutter/material.dart';
import 'payment_helper.dart';
import 'subscriptions_controller.dart';

// ═══════════════════════════════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════════════════════════════

class AppColors {
  static const primary     = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1E40AF);
  static const green       = Color(0xFF059669);
  static const surface     = Color(0xFFFFFFFF);
  static const background  = Color(0xFFEEF2FF);
  static const card        = Color(0xFFFFFFFF);
  static const textDark    = Color(0xFF0F172A);
  static const textMid     = Color(0xFF475569);
  static const textLight   = Color(0xFF94A3B8);
  static const divider     = Color(0xFFE2E8F0);
  static const success     = Color(0xFF10B981);
  static const tag         = Color(0xFFEFF6FF);
  static const tagText     = Color(0xFF3B82F6);
  static const warning     = Color(0xFFF59E0B);
  static const warningBg   = Color(0xFFFEF3C7);
  static const gold        = Color(0xFFFFD700);
  static const goldDark    = Color(0xFFB8860B);
}

class AppTextStyles {
  static const titleLarge  = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.2);
  static const titleMedium = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark);
  static const body        = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMid, height: 1.6);
  static const caption     = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textLight, letterSpacing: 0.2);
  static const label       = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMid);
}

// ═══════════════════════════════════════════════════════════════════
//  MODELS
// ═══════════════════════════════════════════════════════════════════

class _Course {
  final String title, instructor, instructorImage, category, description;
  final double rating, price;
  final int reviews, studentsCount;
  final bool hasLive, hasRecorded;
  const _Course({
    required this.title, required this.instructor, required this.instructorImage,
    required this.category, required this.description, required this.rating,
    required this.price, required this.reviews, required this.studentsCount,
    required this.hasLive, required this.hasRecorded,
  });
}

class _Package {
  final String name, description;
  final int sessions, hours;
  final double pricePerHour, discount;
  final Color color;
  const _Package({
    required this.name, required this.description, required this.sessions,
    required this.hours, required this.pricePerHour, required this.discount,
    required this.color,
  });
  double get totalPrice => pricePerHour * hours * (1 - discount / 100);
  double get originalPrice => pricePerHour * hours;
}

class _BoostPlan {
  final String name, description;
  final double price;
  final List<String> features;
  final Color color;
  final bool isPopular;
  const _BoostPlan({
    required this.name, required this.description, required this.price,
    required this.features, required this.color, this.isPopular = false,
  });
}

// ═══════════════════════════════════════════════════════════════════
//  DATA
// ═══════════════════════════════════════════════════════════════════

const _courses = [
  _Course(
    title: "Flutter from Zero to Pro",
    instructor: "Marwan Hussien",
    instructorImage: "https://i.postimg.cc/z3ZzXWGc/Marwan.webp",
    category: "Mobile Development",
    description: "Learn Flutter & Dart from basics to building professional iOS & Android apps",
    rating: 4.9, price: 899, reviews: 312, studentsCount: 1240,
    hasLive: true, hasRecorded: true,
  ),
  _Course(
    title: "Python & Data Science",
    instructor: "Mohamed Nukbassy",
    instructorImage: "https://i.postimg.cc/9f0r3cSF/Mo-nakbas.jpg",
    category: "Data Analysis",
    description: "Master Python, Pandas & Matplotlib for data analysis and ML model building",
    rating: 4.8, price: 749, reviews: 218, studentsCount: 980,
    hasLive: true, hasRecorded: true,
  ),
  _Course(
    title: "UI/UX Design with Figma",
    instructor: "Sara Khalil",
    instructorImage: "https://i.pravatar.cc/150?img=47",
    category: "UI/UX Design",
    description: "Design professional interfaces and build complete Design Systems",
    rating: 4.7, price: 649, reviews: 134, studentsCount: 756,
    hasLive: false, hasRecorded: true,
  ),
  _Course(
    title: "Backend with Node.js",
    instructor: "Ahmed Tarek",
    instructorImage: "https://i.pravatar.cc/150?img=12",
    category: "Backend Development",
    description: "Build professional APIs with Node.js, Express & PostgreSQL",
    rating: 4.6, price: 699, reviews: 92, studentsCount: 543,
    hasLive: true, hasRecorded: false,
  ),
  _Course(
    title: "Cybersecurity Fundamentals",
    instructor: "Khaled Mansour",
    instructorImage: "https://i.pravatar.cc/150?img=33",
    category: "Cybersecurity",
    description: "Learn information security basics and protection from cyber attacks",
    rating: 4.8, price: 829, reviews: 167, studentsCount: 892,
    hasLive: true, hasRecorded: true,
  ),
  _Course(
    title: "Cloud Computing with AWS",
    instructor: "Nour Eldin",
    instructorImage: "https://i.pravatar.cc/150?img=52",
    category: "Cloud Computing",
    description: "Learn AWS from scratch and build professional cloud infrastructure",
    rating: 4.7, price: 949, reviews: 203, studentsCount: 1100,
    hasLive: false, hasRecorded: true,
  ),
];

const _packages = [
  _Package(
    name: "Starter Pack", description: "Perfect for beginners",
    sessions: 5, hours: 5, pricePerHour: 150, discount: 10,
    color: Color(0xFF3B82F6),
  ),
  _Package(
    name: "Growth Pack", description: "Most popular ⭐",
    sessions: 10, hours: 15, pricePerHour: 140, discount: 20,
    color: Color(0xFF2563EB),
  ),
  _Package(
    name: "Pro Pack", description: "For serious learners",
    sessions: 20, hours: 30, pricePerHour: 130, discount: 30,
    color: Color(0xFF059669),
  ),
  _Package(
    name: "Elite Pack", description: "Maximum learning potential",
    sessions: 40, hours: 60, pricePerHour: 120, discount: 40,
    color: Color(0xFF7C3AED),
  ),
];

const _boostPlans = [
  _BoostPlan(
    name: "Basic Boost", description: "Start your visibility",
    price: 299,
    features: [
      "Appear in top search results",
      "Expert badge on profile",
      "Profile analytics dashboard",
      "Standard support",
    ],
    color: Color(0xFF3B82F6),
  ),
  _BoostPlan(
    name: "Pro Boost", description: "Most chosen plan",
    price: 599, isPopular: true,
    features: [
      "Everything in Basic",
      "Appear in Feed for visitors",
      "Gold Pro badge on profile",
      "Featured Expert on Home",
      "Advanced analytics",
      "Priority in filter results",
    ],
    color: Color(0xFF2563EB),
  ),
  _BoostPlan(
    name: "Elite Boost", description: "Full presence",
    price: 999,
    features: [
      "Everything in Pro",
      "Exclusive Elite badge",
      "Top page advertisement",
      "Custom profile page",
      "24/7 direct support",
      "Detailed monthly report",
    ],
    color: Color(0xFF059669),
  ),
];

// ═══════════════════════════════════════════════════════════════════
//  SKILL STORE PAGE
// ═══════════════════════════════════════════════════════════════════

class SkillStorePage extends StatefulWidget {
  const SkillStorePage({super.key});
  @override
  State<SkillStorePage> createState() => _SkillStorePageState();
}

class _SkillStorePageState extends State<SkillStorePage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _selectedCategory = "All";

  final _categories = ["All", "Mobile", "Data", "Design", "Backend", "Security", "Cloud"];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<_Course> get _filteredCourses {
    if (_selectedCategory == "All") return _courses;
    return _courses.where((c) {
      switch (_selectedCategory) {
        case "Mobile":   return c.category == "Mobile Development";
        case "Data":     return c.category == "Data Analysis";
        case "Design":   return c.category == "UI/UX Design";
        case "Backend":  return c.category == "Backend Development";
        case "Security": return c.category == "Cybersecurity";
        case "Cloud":    return c.category == "Cloud Computing";
        default:         return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE), Color(0xFFD1FAE5)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(children: [

            // ── Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.green.withOpacity(0.1),
                      ]),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  RichText(text: const TextSpan(children: [
                    TextSpan(text: "Skill", style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    TextSpan(text: "Store", style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.green)),
                  ])),
                  Text("Courses • Packages • Boost", style: AppTextStyles.caption),
                ]),
                const Spacer(),
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.green],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, size: 20, color: Colors.white),
                ),
              ]),
            ),

            // ── Tab Bar ──
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider.withOpacity(0.5)),
              ),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.green],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMid,
                tabs: const [
                  Tab(text: "📚 Courses"),
                  Tab(text: "🎯 Packages"),
                  Tab(text: "⭐ Boost"),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(controller: _tab, children: [
                _CoursesTab(
                  courses: _filteredCourses,
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (c) => setState(() => _selectedCategory = c),
                ),
                const _PackagesTab(),
                const _BoostTab(),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  COURSES TAB
// ═══════════════════════════════════════════════════════════════════

class _CoursesTab extends StatelessWidget {
  final List<_Course> courses;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  const _CoursesTab({
    required this.courses, required this.categories,
    required this.selectedCategory, required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (_, i) {
            final cat = categories[i];
            final active = cat == selectedCategory;
            return GestureDetector(
              onTap: () => onCategoryChanged(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  gradient: active ? const LinearGradient(colors: [AppColors.primary, AppColors.green]) : null,
                  color: active ? null : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? Colors.transparent : AppColors.divider),
                  boxShadow: active
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Text(cat, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.textMid,
                )),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: courses.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textLight),
                const SizedBox(height: 12),
                Text("No courses found", style: AppTextStyles.caption),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: courses.length,
                itemBuilder: (_, i) => _CourseCard(course: courses[i]),
              ),
      ),
    ]);
  }
}

class _CourseCard extends StatelessWidget {
  final _Course course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(course.instructorImage, width: 56, height: 56, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 56, height: 56,
                  color: AppColors.tag, child: const Icon(Icons.person, color: AppColors.primary))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.title, style: AppTextStyles.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(course.instructor, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.green]),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(course.category, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ])),
          ]),
          const SizedBox(height: 12),
          Text(course.description, style: AppTextStyles.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(children: [
            if (course.hasLive)   _TypeBadge(label: "🔴 Live",     color: const Color(0xFFEF4444)),
            if (course.hasLive && course.hasRecorded) const SizedBox(width: 8),
            if (course.hasRecorded) _TypeBadge(label: "🎬 Recorded", color: AppColors.primary),
          ]),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          Row(children: [
            Row(children: [
              const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(course.rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(width: 4),
              Text("(${course.reviews})", style: AppTextStyles.caption),
            ]),
            const SizedBox(width: 16),
            Row(children: [
              const Icon(Icons.people_outline_rounded, size: 14, color: AppColors.textLight),
              const SizedBox(width: 4),
              Text("${course.studentsCount} students", style: AppTextStyles.caption),
            ]),
            const Spacer(),
            Text("EGP ${course.price.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showEnrollDialog(context, course),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.green]),
                  borderRadius: BorderRadius.circular(14)),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Text("Enroll Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _showEnrollDialog(BuildContext context, _Course course) async {
    final paid = await showPaymentDialog(
      context: context,
      title: course.title,
      description: 'Course enrollment • ${course.category}',
      amount: course.price,
      recipient: course.instructor,
      icon: Icons.school_rounded,
    );

    if (paid && context.mounted) {
      SubscriptionsController.instance.addCourse(
        title: course.title,
        instructor: course.instructor,
        imageUrl: course.instructorImage,
        category: course.category,
        price: course.price,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("🎉 Successfully enrolled in ${course.title}!"),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PACKAGES TAB
// ═══════════════════════════════════════════════════════════════════

class _PackagesTab extends StatelessWidget {
  const _PackagesTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Save more with packages! 🎯",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text("More hours = bigger discount",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
            ])),
          ]),
        ),
        ..._packages.map((p) => _PackageCard(package: p)),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final _Package package;
  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final isPopular = package.name == "Growth Pack";
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: isPopular
            ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5)
            : Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: isPopular
            ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))]
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [package.color, package.color.withOpacity(0.7)]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(children: [
            if (isPopular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                child: const Text("⭐ Most Popular", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
              const SizedBox(height: 6),
            ],
            Text(package.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(package.description, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Row(children: [
              _PackageStat(icon: Icons.calendar_today_rounded, value: "${package.sessions}", label: "Sessions"),
              Container(width: 1, height: 40, color: AppColors.divider),
              _PackageStat(icon: Icons.access_time_rounded, value: "${package.hours}", label: "Hours"),
              Container(width: 1, height: 40, color: AppColors.divider),
              _PackageStat(icon: Icons.local_offer_rounded, value: "${package.discount.toStringAsFixed(0)}%",
                label: "Discount", valueColor: AppColors.success),
            ]),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Column(children: [
                Text("EGP ${package.originalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 14, color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
                const SizedBox(height: 4),
                Text("EGP ${package.totalPrice.toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: package.color)),
                Text("EGP ${package.pricePerHour.toStringAsFixed(0)}/hour", style: AppTextStyles.caption),
              ]),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final paid = await showPaymentDialog(
                    context: context,
                    title: package.name,
                    description: '${package.sessions} sessions • ${package.hours} hours • ${package.discount.toStringAsFixed(0)}% off',
                    amount: package.totalPrice,
                    recipient: 'SkillBridge Packages',
                    icon: Icons.card_giftcard_rounded,
                  );
                  if (paid && context.mounted) {
                    SubscriptionsController.instance.addPackage(
                      name: package.name,
                      sessions: package.sessions,
                      hours: package.hours,
                      discount: package.discount,
                      totalPrice: package.totalPrice,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("🎉 ${package.name} subscribed successfully!"),
                      backgroundColor: package.color,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.all(16),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: package.color, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: Text("Subscribe to ${package.name}",
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _PackageStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color? valueColor;
  const _PackageStat({required this.icon, required this.value, required this.label, this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Icon(icon, size: 16, color: AppColors.textLight),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: valueColor ?? AppColors.textDark)),
      Text(label, style: AppTextStyles.caption),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BOOST TAB
// ═══════════════════════════════════════════════════════════════════

class _BoostTab extends StatelessWidget {
  const _BoostTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E40AF), Color(0xFF059669)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Expert Boost 🚀",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 4),
              Text("Make your profile visible to thousands and grow your sessions",
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
            ])),
          ]),
        ),
        ..._boostPlans.map((p) => _BoostCard(plan: p)),
      ],
    );
  }
}

class _BoostCard extends StatelessWidget {
  final _BoostPlan plan;
  const _BoostCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: plan.isPopular
            ? Border.all(color: plan.color.withOpacity(0.5), width: 1.5)
            : Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: plan.isPopular
            ? [BoxShadow(color: plan.color.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))]
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [plan.color, plan.color.withOpacity(0.7)]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(children: [
            if (plan.isPopular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                child: const Text("🔥 Most Chosen", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
              const SizedBox(height: 8),
            ],
            Text(plan.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(plan.description, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
            const SizedBox(height: 12),
            Text("EGP ${plan.price.toStringAsFixed(0)} / month",
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            ...plan.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [plan.color, plan.color.withOpacity(0.7)]),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14)),
                const SizedBox(width: 10),
                Expanded(child: Text(f, style: AppTextStyles.body.copyWith(fontSize: 13))),
              ]),
            )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final paid = await showPaymentDialog(
                    context: context,
                    title: plan.name,
                    description: 'Monthly subscription • ${plan.description}',
                    amount: plan.price,
                    recipient: 'SkillBridge Boost',
                    icon: Icons.rocket_launch_rounded,
                  );
                  if (paid && context.mounted) {
                    SubscriptionsController.instance.addBoostPlan(
                      name: plan.name,
                      description: plan.description,
                      price: plan.price,
                      features: plan.features,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("🚀 ${plan.name} activated successfully!"),
                      backgroundColor: plan.color,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.all(16),
                    ));
                  }
                },
                icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                label: Text("Subscribe Now — EGP ${plan.price.toStringAsFixed(0)}",
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.color, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}