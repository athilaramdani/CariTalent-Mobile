import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_talent_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_eo_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({super.key, this.initialPage = 0});

  static const routePath = '/home';
  final int initialPage;

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage> {
  late final PageController _pageController;
  int _currentPage = 0;
  String _selectedRole = 'talent'; // 'talent' or 'eo'

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void didUpdateWidget(covariant PublicHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPage != widget.initialPage) {
      _navigateToPage(widget.initialPage);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int page) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: Stack(
        children: [
          // Background Glow Blobs
          _buildGlowBlobs(),

          // Main Onboarding PageView
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildPageWelcome(),
                      _buildPageFeatures(),
                      _buildPageHowItWorks(),
                      _buildPageChooseRole(),
                    ],
                  ),
                ),

                // Indicator & Navigation Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dot Indicators
                      _buildDotIndicators(),
                      const SizedBox(height: 24),

                      // CTA Button
                      _buildCtaButton(),
                      
                      // Skip / Footer text link
                      _buildFooterLink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Background Glow Blobs
  Widget _buildGlowBlobs() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Purple Top-Right Glow Blob
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                ),
              ),
            ),
            // Pink Bottom-Left Glow Blob
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFDB2777).withValues(alpha: 0.12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dot Indicators
  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: isActive ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: isActive 
                ? const Color(0xFF7C3AED) 
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
    );
  }

  // CTA Button matching style requirements
  Widget _buildCtaButton() {
    String label = 'Lanjut →';
    VoidCallback onPressed = () => _navigateToPage(_currentPage + 1);

    if (_currentPage == 0) {
      label = 'Mulai →';
    } else if (_currentPage == 3) {
      if (_selectedRole == 'talent') {
        label = 'Daftar sebagai Talent';
        onPressed = () => context.go(RegisterTalentPage.routePath);
      } else {
        label = 'Daftar sebagai EO';
        onPressed = () => context.go(RegisterEoPage.routePath);
      }
    }

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Footer / Skip links
  Widget _buildFooterLink() {
    if (_currentPage == 1 || _currentPage == 2) {
      return Padding(
        padding: const EdgeInsets.only(top: 14.0),
        child: TextButton(
          onPressed: () => _navigateToPage(3),
          child: const Text(
            'Lewati',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    if (_currentPage == 3) {
      return Padding(
        padding: const EdgeInsets.only(top: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sudah punya akun? ',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => context.go(LoginPage.routePath),
              child: const Text(
                'Masuk',
                style: TextStyle(
                  color: Color(0xFFF472B6),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox(height: 14);
  }

  // Badge pill utility
  Widget _buildBadgePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // PAGE 1: Welcome
  Widget _buildPageWelcome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          
          // Visual Stack: Center Card, Background Cards, Floating Trophy and Badge
          SizedBox(
            height: 190,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing Background Core
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),

                // Left rotated background card
                Transform.translate(
                  offset: const Offset(-60, 0),
                  child: Transform.rotate(
                    angle: -0.18,
                    child: Container(
                      width: 90,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16152B).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                            child: const Icon(Icons.star, size: 12, color: Color(0xFFA78BFA)),
                          ),
                          const Spacer(),
                          Container(height: 4, width: 40, color: Colors.white10),
                          const SizedBox(height: 4),
                          Container(height: 4, width: 50, color: Colors.white10),
                        ],
                      ),
                    ),
                  ),
                ),

                // Right rotated background card
                Transform.translate(
                  offset: const Offset(60, 0),
                  child: Transform.rotate(
                    angle: 0.18,
                    child: Container(
                      width: 90,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16152B).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFFDB2777).withValues(alpha: 0.2),
                            child: const Icon(Icons.person, size: 12, color: Color(0xFFF472B6)),
                          ),
                          const Spacer(),
                          Container(height: 4, width: 40, color: Colors.white10),
                          const SizedBox(height: 4),
                          Container(height: 4, width: 50, color: Colors.white10),
                        ],
                      ),
                    ),
                  ),
                ),

                // Center main card (Confetti box)
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1B3E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.celebration_rounded,
                      size: 52,
                      color: Color(0xFFF472B6),
                    ),
                  ),
                ),

                // Floating trophy on the left
                Positioned(
                  left: 30,
                  bottom: 25,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDB2777),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDB2777).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.emoji_events, size: 20, color: Colors.white),
                  ),
                ),

                // Floating star badge on the right
                Positioned(
                  right: 30,
                  bottom: 25,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4F46E5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.stars_rounded, size: 20, color: Colors.white),
                  ),
                ),

                // Floating ribbon details
                const Positioned(
                  top: 20,
                  left: 60,
                  child: Icon(Icons.gesture, size: 24, color: Colors.pinkAccent),
                ),
                const Positioned(
                  top: 20,
                  right: 60,
                  child: Icon(Icons.bubble_chart_rounded, size: 16, color: Colors.purpleAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildBadgePill('★ Selamat datang'),
          const SizedBox(height: 16),

          // Title
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              children: [
                const TextSpan(text: 'Selamat datang di\n'),
                TextSpan(
                  text: 'CariTalent',
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 40.0)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Subtext / Description
          const Text(
            'Platform inspiratif yang menghubungkan event organizer dengan talenta profesional di seluruh Indonesia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // 3 Columns of features in a row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildWelcomeFeatureCard(
                  icon: Icons.groups_rounded,
                  iconBg: const Color(0xFF7C3AED),
                  title: 'Temukan Talenta',
                  description: 'Cari talenta terbaik untuk setiap event Anda.',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWelcomeFeatureCard(
                  icon: Icons.calendar_month_rounded,
                  iconBg: const Color(0xFFDB2777),
                  title: 'Kelola Event',
                  description: 'Kelola jadwal dan kebutuhan event dengan mudah.',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWelcomeFeatureCard(
                  icon: Icons.stars_rounded,
                  iconBg: const Color(0xFF6366F1),
                  title: 'Kualitas Terjamin',
                  description: 'Talenta profesional dengan pengalaman terverifikasi.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeFeatureCard({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconBg.withValues(alpha: 0.15),
            child: Icon(icon, color: iconBg, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 8.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 2: Features
  Widget _buildPageFeatures() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildBadgePill('★ Fitur unggulan'),
          const SizedBox(height: 16),
          const Text(
            'Semua yang kamu butuhkan ada di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Temukan, hubungkan, dan kelola talent untuk acaramu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 28),

          // Vertical Feature list (3 features)
          _buildFeatureCard(
            icon: Icons.search_rounded,
            iconColor: const Color(0xFFA78BFA),
            title: 'Cari Kategori & Lokasi',
            text: 'Cari talent profesional sesuai kategori kebutuhan & lokasi event Anda.',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFFF472B6),
            title: 'Posting Event Baru',
            text: 'Posting detail event Anda dan terima penawaran harga langsung dari talent.',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF34D399),
            title: 'Talent Terverifikasi',
            text: 'Semua talent di platform kami melewati proses verifikasi ketat.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 3: How It Works
  Widget _buildPageHowItWorks() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildBadgePill('→ Cara kerja'),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              children: [
                const TextSpan(text: 'Mudah dalam\n'),
                TextSpan(
                  text: '3 langkah',
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 40.0)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Vertical Steps list
          _buildStepCard(
            stepNumber: '1',
            stepColor: const Color(0xFF7C3AED),
            title: 'Buat akun & pilih role',
            description: 'Daftar sebagai Talent atau Event Organizer',
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            stepNumber: '2',
            stepColor: const Color(0xFFDB2777),
            title: 'Cari atau posting event',
            description: 'Talent cari job, EO temukan talent terbaik',
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            stepNumber: '3',
            stepColor: const Color(0xFF34D399),
            title: 'Pesan & Selesaikan!',
            description: 'Pesan talent terbaik, selesaikan event, dan berikan review langsung.',
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required Color stepColor,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: stepColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: stepColor.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: TextStyle(
                color: stepColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 4: Choose Role + CTA
  Widget _buildPageChooseRole() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildBadgePill('🚀 Ayo mulai!'),
          const SizedBox(height: 16),
          const Text(
            'Kamu bergabung sebagai apa?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih role kamu untuk pengalaman terbaik di CariTalent.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 36),

          // Selection row (2 cards side by side)
          Row(
            children: [
              Expanded(
                child: _buildRoleSelectCard(
                  roleKey: 'talent',
                  title: 'Talent',
                  subtitle: 'Penyanyi, MC, dancer, dll',
                  icon: Icons.mic_rounded,
                  iconColor: const Color(0xFFA78BFA),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRoleSelectCard(
                  roleKey: 'eo',
                  title: 'Event Organizer',
                  subtitle: 'Cari talent untuk acaramu',
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFFF472B6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelectCard({
    required String roleKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedRole == roleKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = roleKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 180,
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF7C3AED).withValues(alpha: 0.1) 
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF7C3AED) 
                : Colors.white.withValues(alpha: 0.07),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
