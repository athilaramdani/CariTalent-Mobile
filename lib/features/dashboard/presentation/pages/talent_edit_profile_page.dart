import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/genre_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TalentEditProfilePage extends ConsumerStatefulWidget {
  const TalentEditProfilePage({super.key});

  static const routePath = '/talent/edit-profile';

  @override
  ConsumerState<TalentEditProfilePage> createState() =>
      _TalentEditProfilePageState();
}

class _TalentEditProfilePageState
    extends ConsumerState<TalentEditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _stageNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _portfolioCtrl;
  late TextEditingController _priceMinCtrl;
  late TextEditingController _priceMaxCtrl;

  List<String> _selectedGenres = [];
  bool _loading = false;
  bool _genresLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _stageNameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _portfolioCtrl = TextEditingController();
    _priceMinCtrl = TextEditingController();
    _priceMaxCtrl = TextEditingController();

    // Pre-fill from auth user (basic info)
    final user = ref.read(authControllerProvider).user;
    _nameCtrl.text = user?.name ?? '';
    _emailCtrl.text = user?.email ?? '';
    _phoneCtrl.text = user?.phone ?? '';

    // Pre-fill talent profile fields from myTalentProvider
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTalentData());
  }

  Future<void> _loadTalentData() async {
    setState(() => _genresLoading = true);
    try {
      final talent =
          await ref.read(talentRepositoryProvider).fetchMyTalent();
      if (mounted) {
        _stageNameCtrl.text = talent.stageName;
        _cityCtrl.text = talent.city;
        _bioCtrl.text = talent.bio ?? '';
        _portfolioCtrl.text = talent.portfolioLink ?? '';
        _priceMinCtrl.text = talent.priceMin?.toInt().toString() ?? '';
        _priceMaxCtrl.text = talent.priceMax?.toInt().toString() ?? '';
        _selectedGenres = List<String>.from(talent.genre);
        // Also fill fullName & phone from talent if available
        if (talent.fullName != null && _nameCtrl.text.isEmpty) {
          _nameCtrl.text = talent.fullName!;
        }
        if (talent.phone != null && _phoneCtrl.text.isEmpty) {
          _phoneCtrl.text = talent.phone!;
        }
        setState(() => _genresLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _genresLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _stageNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    _portfolioCtrl.dispose();
    _priceMinCtrl.dispose();
    _priceMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final stageName = _stageNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final bio = _bioCtrl.text.trim();
    final portfolio = _portfolioCtrl.text.trim();
    final priceMinStr = _priceMinCtrl.text.trim();
    final priceMaxStr = _priceMaxCtrl.text.trim();

    if (name.isEmpty) {
      _showSnack('Nama tidak boleh kosong', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      // 1. Update user profile (name & phone)
      final userPayload = <String, dynamic>{'name': name};
      if (phone.isNotEmpty) userPayload['phone'] = phone;
      await ref.read(talentRepositoryProvider).updateUserProfile(userPayload);

      // 2. Update talent profile via PUT /talents/{id}
      final talent =
          await ref.read(talentRepositoryProvider).fetchMyTalent();
      final talentPayload = <String, dynamic>{};
      if (stageName.isNotEmpty) talentPayload['stage_name'] = stageName;
      if (city.isNotEmpty) talentPayload['city'] = city;
      if (bio.isNotEmpty) talentPayload['bio'] = bio;
      if (portfolio.isNotEmpty) talentPayload['portfolio_link'] = portfolio;
      if (priceMinStr.isNotEmpty) {
        talentPayload['price_min'] = int.tryParse(priceMinStr) ?? 0;
      }
      if (priceMaxStr.isNotEmpty) {
        talentPayload['price_max'] = int.tryParse(priceMaxStr) ?? 0;
      }
      if (_selectedGenres.isNotEmpty) {
        talentPayload['genre'] = _selectedGenres;
      }

      await ref
          .read(talentRepositoryProvider)
          .updateTalentProfile(talent.id, talentPayload);

      // 3. Refresh auth state and talent data
      await ref.read(authControllerProvider.notifier).refreshUser();
      ref.invalidate(myTalentProvider);

      if (mounted) {
        context.pop();
        _showSnack('Profil berhasil diperbarui ✓');
      }
    } catch (e) {
      if (mounted) _showSnack('Gagal: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final email = user?.email ?? '-';
    final genres = ref.watch(genresProvider);

    return Scaffold(
      backgroundColor: AppTheme.uiDark,
      appBar: AppBar(
        backgroundColor: AppTheme.panel,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profil Talent',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFB500FF), Color(0xFFE94057)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 36),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- INFORMASI DASAR ---
              _buildSectionHeader('Informasi Dasar'),
              const SizedBox(height: 16),

              _buildLabel('Nama Lengkap'),
              _buildTextField(controller: _nameCtrl, hint: 'Masukkan nama lengkap'),
              const SizedBox(height: 20),

              _buildLabel('Nama Panggung'),
              _buildTextField(
                  controller: _stageNameCtrl,
                  hint: 'Contoh: Siti ND Jazz'),
              const SizedBox(height: 20),

              _buildLabel('Email'),
              _buildTextField(controller: _emailCtrl, hint: 'Email', enabled: false),
              const SizedBox(height: 20),

              _buildLabel('Nomor Telepon'),
              _buildTextField(
                  controller: _phoneCtrl,
                  hint: 'Contoh: 08123456789',
                  isPhone: true),
              const SizedBox(height: 20),

              _buildLabel('Kota'),
              _buildTextField(
                  controller: _cityCtrl, hint: 'Contoh: Bandung'),
              const SizedBox(height: 32),

              // --- INFORMASI TALENT ---
              _buildSectionHeader('Informasi Talent'),
              const SizedBox(height: 16),

              _buildLabel('Bio'),
              _buildTextField(
                controller: _bioCtrl,
                hint: 'Ceritakan tentang diri kamu sebagai talent...',
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              _buildLabel('Portofolio (Link)'),
              _buildTextField(
                controller: _portfolioCtrl,
                hint: 'https://instagram.com/username',
                isUrl: true,
              ),
              const SizedBox(height: 20),

              // --- HARGA ---
              _buildLabel('Harga Minimum (Rp)'),
              _buildTextField(
                controller: _priceMinCtrl,
                hint: 'Contoh: 600000',
                isNumber: true,
              ),
              const SizedBox(height: 20),

              _buildLabel('Harga Maximum (Rp)'),
              _buildTextField(
                controller: _priceMaxCtrl,
                hint: 'Contoh: 2500000',
                isNumber: true,
              ),
              const SizedBox(height: 20),

              // --- GENRE ---
              _buildLabel('Genre'),
              const SizedBox(height: 8),
              genres.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Text(
                  'Gagal memuat genre',
                  style: TextStyle(color: Colors.redAccent),
                ),
                data: (genreList) => _buildGenreSelector(genreList),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB500FF), Color(0xFFE94057)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFC48DF6),
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hint,
    bool enabled = true,
    bool isPhone = false,
    bool isNumber = false,
    bool isUrl = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: isPhone
          ? TextInputType.phone
          : isNumber
              ? TextInputType.number
              : isUrl
                  ? TextInputType.url
                  : TextInputType.text,
      inputFormatters:
          isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: TextStyle(color: enabled ? Colors.white : Colors.white54),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppTheme.panel,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppTheme.border.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.highlight),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildGenreSelector(List<GenreModel> genreList) {
    if (_genresLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genreList.map((g) {
        final selected = _selectedGenres.contains(g.name);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                _selectedGenres.remove(g.name);
              } else {
                _selectedGenres.add(g.name);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFB500FF).withValues(alpha: 0.2)
                  : AppTheme.panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? const Color(0xFFB500FF)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              g.name,
              style: TextStyle(
                color: selected
                    ? const Color(0xFFC48DF6)
                    : Colors.white54,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
