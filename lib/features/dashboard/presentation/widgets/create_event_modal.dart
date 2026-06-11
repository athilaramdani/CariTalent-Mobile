import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class CreateEventModal extends ConsumerStatefulWidget {
  final EventModel? event;
  const CreateEventModal({super.key, this.event});

  static Future<void> show(BuildContext context, {EventModel? event}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateEventModal(event: event),
    );
  }

  @override
  ConsumerState<CreateEventModal> createState() => _CreateEventModalState();
}

class _CreateEventModalState extends ConsumerState<CreateEventModal> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _budgetCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _venueCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  // Dropdown states
  String? _selectedGenre;
  String? _selectedStatus;
  LatLng? _selectedLocation;
  final _mapController = MapController();
  bool _isLoading = false;

  // Mutable so we can add custom genres from saved events
  late final List<String> _genres;
  static const _statuses = ['open', 'closed', 'draft', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    final e = widget.event;

    // Build genres list, adding any custom genre from the saved event
    final baseGenres = [
      'Rock', 'Jazz', 'Pop', 'Electronic', 'Indie',
      'Folk', 'Classical', 'Acoustic', 'Hip-Hop', 'R&B',
    ];
    if (e != null && e.genres.isNotEmpty) {
      for (final g in e.genres) {
        if (!baseGenres.contains(g)) baseGenres.add(g);
      }
    }
    _genres = baseGenres;

    _titleCtrl = TextEditingController(text: e?.title);
    _descCtrl = TextEditingController(text: e?.description);
    _budgetCtrl = TextEditingController(text: e?.budget.toString());
    _dateCtrl = TextEditingController(text: e?.eventDate);
    _venueCtrl = TextEditingController(text: e?.venueName);
    _cityCtrl = TextEditingController(text: e?.city);
    
    _latController = TextEditingController(
      text: e?.latitude != null ? e!.latitude!.toStringAsFixed(6) : 'Belum ada pin'
    );
    _lngController = TextEditingController(
      text: e?.longitude != null ? e!.longitude!.toStringAsFixed(6) : 'Belum ada pin'
    );

    // Set selected genre only if it exists in the (possibly extended) list
    if (e != null && e.genres.isNotEmpty) {
      final firstGenre = e.genres.first;
      _selectedGenre = _genres.contains(firstGenre) ? firstGenre : null;
    }
    _selectedStatus = e?.status;
    if (e?.latitude != null && e?.longitude != null) {
      _selectedLocation = LatLng(e!.latitude!, e!.longitude!);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    _dateCtrl.dispose();
    _venueCtrl.dispose();
    _cityCtrl.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _latController.text = point.latitude.toStringAsFixed(6);
      _lngController.text = point.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'budget': int.parse(_budgetCtrl.text.replaceAll('.', '')),
        'event_date': _dateCtrl.text.trim(),
        'venue_name': _venueCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'status': _selectedStatus ?? 'open',
        'genre': _selectedGenre != null ? [_selectedGenre!] : [],
        if (_selectedLocation != null) 'latitude': _selectedLocation!.latitude,
        if (_selectedLocation != null) 'longitude': _selectedLocation!.longitude,
      };

      if (widget.event != null) {
        await ref.read(eventRepositoryProvider).updateEvent(widget.event!.id, data);
      } else {
        await ref.read(eventRepositoryProvider).createEvent(
              title: data['title'] as String,
              description: data['description'] as String,
              budget: data['budget'] as int,
              eventDate: data['event_date'] as String,
              venueName: data['venue_name'] as String,
              city: data['city'] as String,
              status: data['status'] as String,
              genre: data['genre'] as List<String>,
              latitude: data['latitude'] as double?,
              longitude: data['longitude'] as double?,
            );
      }

      ref.invalidate(myEventsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.event != null ? 'Event berhasil diperbarui! 🎉' : 'Event berhasil dibuat! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal ${widget.event != null ? "memperbarui" : "membuat"} event: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.event != null;
    
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: AppTheme.neutralDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    isEdit ? 'Edit Event' : 'Buat Event',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      isEdit ? 'Edit Detail Event' : 'Buat Event Baru',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEdit ? 'Perbarui informasi event kamu.' : 'Isi detail event yang ingin kamu selenggarakan.',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.border),
                    const SizedBox(height: 16),

                    _buildLabel('Judul Event *'),
                    _buildTextFormField(
                      controller: _titleCtrl,
                      hint: 'Masukkan judul...',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildLabel('Deskripsi'),
                    _buildTextFormField(
                      controller: _descCtrl,
                      hint: 'Deskripsikan event kamu...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    _buildLabel('Genre Dibutuhkan *'),
                    _buildDropdown(
                      value: _selectedGenre,
                      hint: 'Pilih genre...',
                      items: _genres,
                      onChanged: (v) =>
                          setState(() => _selectedGenre = v),
                    ),
                    const SizedBox(height: 12),

                    _buildLabel('Budget (Rp) *'),
                    _buildTextFormField(
                      controller: _budgetCtrl,
                      hint: 'Contoh: 2000000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildLabel('Tanggal Event *'),
                    _buildTextFormField(
                      controller: _dateCtrl,
                      hint: 'YYYY-MM-DD',
                      suffixIcon: Icons.calendar_today,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                      onTap: () async {
                        final initial = widget.event != null 
                          ? DateTime.tryParse(widget.event!.eventDate) ?? DateTime.now().add(const Duration(days: 7))
                          : DateTime.now().add(const Duration(days: 7));
                          
                        final date = await showDatePicker(
                          context: context,
                          initialDate: initial,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365 * 2)),
                          builder: (context, child) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFFB500FF),
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (date != null) {
                          _dateCtrl.text =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildLabel('Status'),
                    _buildDropdown(
                      value: _selectedStatus,
                      hint: 'Pilih status...',
                      items: _statuses,
                      onChanged: (v) =>
                          setState(() => _selectedStatus = v),
                    ),
                    const SizedBox(height: 12),

                    _buildLabel('Nama Venue *'),
                    _buildTextFormField(
                      controller: _venueCtrl,
                      hint: 'Masukkan venue...',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildLabel('Kota *'),
                    _buildTextFormField(
                      controller: _cityCtrl,
                      hint: 'Masukkan kota...',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text('Pilih Lokasi di Peta',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),

                    // Map View
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _selectedLocation ?? const LatLng(-6.914744, 107.609810),
                              initialZoom: 13.0,
                              onTap: _onMapTap,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.caritalent',
                              ),
                              if (_selectedLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _selectedLocation!,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Color(0xFFD8B4FE),
                                        size: 32,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Column(
                              children: [
                                _buildMapButton(Icons.add, () {
                                  final z =
                                      _mapController.camera.zoom;
                                  _mapController.move(
                                      _mapController.camera.center,
                                      z + 1);
                                }),
                                const SizedBox(height: 4),
                                _buildMapButton(Icons.remove, () {
                                  final z =
                                      _mapController.camera.zoom;
                                  _mapController.move(
                                      _mapController.camera.center,
                                      z - 1);
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildLabel('Latitude'),
                    _buildTextField(
                        controller: _latController,
                        readOnly: true,
                        fillColor: AppTheme.uiDark),
                    const SizedBox(height: 12),

                    _buildLabel('Longitude'),
                    _buildTextField(
                        controller: _lngController,
                        readOnly: true,
                        fillColor: AppTheme.uiDark),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.neutralDark,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24)),
                border: Border(
                    top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: _isLoading ? null : _submit,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFC026D3),
                              Color(0xFF6B21A8)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC026D3)
                                  .withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(isEdit ? Icons.save_outlined : Icons.add,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEdit ? 'Simpan Perubahan' : 'Buat Event',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.bold),
                                  ),
                                ],
                              ),
                      ),
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

  Widget _buildLabel(String text) {
    final hasAsterisk = text.endsWith('*');
    final baseText =
        hasAsterisk ? text.substring(0, text.length - 1).trim() : text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: baseText,
          style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins'),
          children: [
            if (hasAsterisk)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFFCA5A5)),
              )
          ],
        ),
      ),
    );
  }

  // Validated form field
  Widget _buildTextFormField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? suffixIcon,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      validator: validator,
      onTap: onTap,
      style: const TextStyle(fontSize: 13, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.white38, fontSize: 13),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.white70, size: 18)
            : null,
        fillColor: AppTheme.uiDark,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.highlight),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  // Read-only non-validated field
  Widget _buildTextField({
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? suffixIcon,
    TextEditingController? controller,
    bool readOnly = false,
    Color? fillColor,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 13, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.white38, fontSize: 13),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.white70, size: 18)
            : null,
        fillColor: fillColor ?? AppTheme.uiDark,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.highlight),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 13)),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white54, size: 18),
          dropdownColor: AppTheme.neutralDark,
          items: items
              .map((s) => DropdownMenuItem(
                     value: s,
                     child: Text(s,
                         style: const TextStyle(
                             color: Colors.white, fontSize: 13)),
                   ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 16),
      ),
    );
  }
}
