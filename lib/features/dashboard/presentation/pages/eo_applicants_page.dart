import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EoApplicantsPage extends StatelessWidget {
  const EoApplicantsPage({super.key});

  static const routePath = '/eo/applicants';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Internal App Bar / Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, color: Color(0xFFD8B4FE), size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Kembali ke Events',
                      style: TextStyle(
                        color: Color(0xFFD8B4FE), // Light purple
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            // Title Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GradientText(
                        'Pelamar Event',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Event ID:#6 · 4 pelamar',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.pushReplacement('/eo/recommendations'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00BFFF), // Cyan Blue
                      ),
                      child: const Icon(Icons.auto_awesome, color: Color(0xFF082F49), size: 24),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('Semua', '2', true),
                  _buildFilterChip('Pending', '0', false),
                  _buildFilterChip('Accepted', '2', false),
                  _buildFilterChip('Rejected', '2', false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // List of Applicants
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildApplicantCard(
                    context,
                    name: 'Rizky Maulana Acoustic',
                    location: 'Bandung',
                    rating: '4.0',
                    isVerified: true,
                    genres: ['Solo Singer', 'Indie Pop', 'Acoustic'],
                    status: 'Pending',
                    price: 'Rp 30.000',
                    dateSubmitted: '13 Mei 2026',
                  ),
                  const SizedBox(height: 16),
                  _buildApplicantCard(
                    context,
                    name: 'DJ Arfz Bdg',
                    location: 'Bandung',
                    rating: '4.8',
                    isVerified: true,
                    genres: ['DJ', 'EDM'],
                    status: 'Pending',
                    price: 'Rp 45.000',
                    dateSubmitted: '14 Mei 2026',
                  ),
                  const SizedBox(height: 16),
                  _buildApplicantCard(
                    context,
                    name: 'The Rotten Bandung',
                    location: 'Bandung',
                    rating: '5.0',
                    isVerified: true,
                    genres: ['Pop Punk', 'Hardcore', 'Alternative Rock'],
                    status: 'Pending',
                    price: 'Rp 75.000',
                    dateSubmitted: '15 Mei 2026',
                  ),
                  const SizedBox(height: 16),
                  _buildApplicantCard(
                    context,
                    name: 'Altar Sunda',
                    location: 'Bandung',
                    rating: '6.0', // as shown in image
                    isVerified: false,
                    genres: ['Pop Punk', 'Hardcore', 'Alternative Rock'],
                    status: 'Rejected',
                    rejectReason: '"Maaf, kami saat ini mencari genre yang lebih ringan untuk pembukaan event."',
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String count, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFFB57AFF), Color(0xFFE94057)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isActive ? null : Colors.transparent,
        border: isActive ? null : Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: const BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
            child: Text(
              count,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildApplicantCard(
    BuildContext context, {
    required String name,
    required String location,
    required String rating,
    required bool isVerified,
    required List<String> genres,
    required String status,
    String? price,
    String? dateSubmitted,
    String? rejectReason,
  }) {
    final isPending = status == 'Pending';
    final isRejected = status == 'Rejected';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isRejected ? Colors.redAccent : Colors.orangeAccent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (isRejected ? Colors.redAccent : Colors.orangeAccent).withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isRejected ? Colors.redAccent : Colors.orangeAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                location,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.orangeAccent, size: 16),
              const SizedBox(width: 2),
              Text(
                rating,
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 12),
                      SizedBox(width: 4),
                      Text('VERIFIED', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: genres.map((genre) {
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    genre,
                    style: const TextStyle(
                      color: Color(0xFFD8B4FE), // Light purple
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          
          if (rejectReason != null) ...[
            Text(
              rejectReason,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Telah Ditolak',
                style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ] else ...[
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HARGA DITAWARKAN',
                      style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.0, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'DIKIRIM',
                      style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.0, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateSubmitted ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E), // Green
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text('Terima', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5).withValues(alpha: 0.3)), // Faint red border
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_outlined, color: Color(0xFFFCA5A5), size: 18), // Pale red icon
                        SizedBox(width: 6),
                        Text('Tolak', style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 14, fontWeight: FontWeight.bold)), // Pale red text
                      ],
                    ),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}
