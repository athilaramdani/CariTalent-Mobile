import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_talent_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_eo_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
          style: GoogleFonts.dmSans(
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
          child: Text(
            'Lewati',
            style: GoogleFonts.dmSans(
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
            Text(
              'Sudah punya akun? ',
              style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => context.go(LoginPage.routePath),
              child: Text(
                'Masuk',
                style: GoogleFonts.dmSans(
                  color: const Color(0xFFF472B6),
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
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Logo Widget matching Web Brand
  Widget _buildLogo() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFB57AFF), Color(0xFFDB2777)],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB57AFF).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.mic_external_on_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: GoogleFonts.syne(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
              children: const [
                TextSpan(
                  text: 'Cari',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Talent',
                  style: TextStyle(color: Color(0xFF8B5CF6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 1: Welcome (Hero Section matching Web)
  Widget _buildPageWelcome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildLogo(),
          const SizedBox(height: 36),
          
          // Pill Badge matching web hero (slightly larger text)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF60A5FA),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PLATFORM MUSIK KREATIF INDONESIA',
                    style: GoogleFonts.dmSans(
                      color: Colors.white70,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title matching the exact bold style of "Temukan Talent Terbaik untuk Acaramu" (larger text)
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.syne(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                height: 1.25,
                letterSpacing: -0.5,
              ),
              children: [
                const TextSpan(text: 'Temukan\n'),
                TextSpan(
                  text: 'Talent Terbaik\n',
                  style: GoogleFonts.syne(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF60A5FA)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 50.0)),
                  ),
                ),
                const TextSpan(text: 'untuk Acaramu'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description Text (larger text)
          Text(
            'CariTalent menghubungkan musisi independen berbakat dengan penyelenggara acara — dari kafe, restoran, hingga event besar. Proses cepat, transparan, dan terstruktur.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              color: Colors.white60,
              fontSize: 14.5,
              height: 1.6,
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
          _buildBadgePill('★ FITUR UNGGULAN'),
          const SizedBox(height: 16),
          Text(
            'Semua Yang Kamu\nButuhkan Ada Di Sini',
            textAlign: TextAlign.center,
            style: GoogleFonts.syne(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Temukan, hubungkan, dan kelola talent untuk acaramu secara instan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 28),

          _buildFeatureCard(
            icon: Icons.search_rounded,
            iconColor: const Color(0xFF60A5FA),
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
            icon: Icons.verified_user_rounded,
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
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
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
                  style: GoogleFonts.syne(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: GoogleFonts.dmSans(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 3: How It Works (Cara Kerja matching Web)
  Widget _buildPageHowItWorks() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'CARA KERJA',
            style: GoogleFonts.dmSans(
              color: const Color(0xFF8B5CF6),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sesederhana itu',
            textAlign: TextAlign.center,
            style: GoogleFonts.syne(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tiga langkah mudah mempertemukan talenta dan penyelenggara acara.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 32),

          _buildStepCard(
            stepNumber: '1',
            stepColor: const Color(0xFF7C3AED),
            title: 'Buat Profil',
            description: 'Talent membuat profil profesional dengan genre, portofolio, dan kisaran harga penampilan.',
            icon: Icons.palette_rounded,
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            stepNumber: '2',
            stepColor: const Color(0xFF3B82F6),
            title: 'Temukan Event',
            description: 'EO memposting kebutuhan acara. Talent menemukan event yang cocok dan melamar langsung.',
            icon: Icons.search_rounded,
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            stepNumber: '3',
            stepColor: const Color(0xFF6366F1),
            title: 'Booking & Tampil',
            description: 'Kesepakatan tercatat di sistem. Keduanya memiliki rekam jejak yang jelas dan terstruktur.',
            icon: Icons.handshake_rounded,
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
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: stepColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  stepNumber,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              Icon(icon, color: stepColor.withValues(alpha: 0.8), size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.syne(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.dmSans(
              color: Colors.white54,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 4: Choose Role (Siap Naik Panggung matching Web)
  Widget _buildPageChooseRole() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: Color(0xFF8B5CF6),
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.syne(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
              children: [
                const TextSpan(text: 'Siap naik panggung\natau temukan '),
                TextSpan(
                  text: 'talenta?',
                  style: GoogleFonts.syne(color: const Color(0xFFF472B6)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bergabung dengan ribuan musisi and penyelenggara acara yang telah menggunakan CariTalent.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 32),

          // Selection row (2 cards side by side)
          Row(
            children: [
              Expanded(
                child: _buildRoleSelectCard(
                  roleKey: 'talent',
                  title: 'Talent',
                  subtitle: 'Penyanyi, MC, dancer, dll',
                  icon: Icons.mic_rounded,
                  iconColor: const Color(0xFF8B5CF6),
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
        height: 190,
        decoration: BoxDecoration(
          color: isSelected 
              ? iconColor.withValues(alpha: 0.08) 
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? iconColor 
                : Colors.white.withValues(alpha: 0.07),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? iconColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
              ),
              child: Icon(icon, color: isSelected ? iconColor : Colors.white70, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.syne(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: Colors.white38,
                fontSize: 10.5,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
