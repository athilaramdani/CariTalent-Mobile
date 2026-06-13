import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/event_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/genre_model.dart';
import 'package:dio/dio.dart';
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
  late final TextEditingController _addressCtrl;

  // Dropdown states
  final Set<String> _selectedGenres = {};
  LatLng? _selectedLocation;
  final _mapController = MapController();
  bool _isLoading = false;
  bool _isResolvingAddress = false;
  int _geocodeRequestId = 0;

  // Mutable so we can add custom genres from saved events
  late final List<GenreModel> _genres;

  @override
  void initState() {
    super.initState();
    final e = widget.event;

    // Build genres list, adding any custom genre from the saved event
    final baseGenres = <GenreModel>[];
    if (e != null && e.genres.isNotEmpty) {
      for (final g in e.genres) {
        if (!baseGenres.any((genre) => genre.name == g)) {
          baseGenres.add(GenreModel(id: 0, name: g));
        }
      }
    }
    _genres = baseGenres;

    _titleCtrl = TextEditingController(text: e?.title);
    _descCtrl = TextEditingController(text: e?.description);
    _budgetCtrl = TextEditingController(text: e?.budget.toString());
    _dateCtrl = TextEditingController(text: _formatDateForDisplay(e?.eventDate));
    _venueCtrl = TextEditingController(text: e?.venueName);
    _cityCtrl = TextEditingController(text: e?.city);
    _addressCtrl = TextEditingController(
      text: e != null && e.venueName.isNotEmpty
          ? '${e.venueName}, ${e.city}'
          : 'Belum ada lokasi dipilih',
    );

    if (e != null && e.genres.isNotEmpty) {
      _selectedGenres.addAll(e.genres);
    }
    if (e != null && e.latitude != null && e.longitude != null) {
      _selectedLocation = LatLng(e.latitude!, e.longitude!);
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
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _onMapTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      _selectedLocation = point;
      _isResolvingAddress = true;
      _addressCtrl.text = 'Mencari alamat lokasi...';
    });
    await _resolveAddress(point);
  }

  Future<void> _resolveAddress(LatLng point) async {
    final requestId = ++_geocodeRequestId;
    try {
      final response = await Dio().get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': point.latitude,
          'lon': point.longitude,
          'addressdetails': 1,
        },
        options: Options(
          headers: {'User-Agent': 'CariTalent-Mobile/1.0'},
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      if (!mounted || requestId != _geocodeRequestId) return;

      final data = response.data ?? {};
      final address = data['address'] as Map<String, dynamic>? ?? {};
      final displayName =
          data['display_name']?.toString() ?? 'Alamat tidak ditemukan';
      final city = _pickCity(address);

      setState(() {
        _addressCtrl.text = displayName;
        if (city.isNotEmpty) _cityCtrl.text = city;
        _isResolvingAddress = false;
      });
    } catch (_) {
      if (!mounted || requestId != _geocodeRequestId) return;
      setState(() {
        _addressCtrl.text = 'Alamat belum ditemukan untuk titik ini';
        _isResolvingAddress = false;
      });
    }
  }

  String _pickCity(Map<String, dynamic> address) {
    const keys = [
      'city',
      'town',
      'municipality',
      'county',
      'village',
      'suburb',
      'state',
    ];
    for (final key in keys) {
      final value = address[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime? _parseEventDate(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;

    final isoDate = DateTime.tryParse(value);
    if (isoDate != null) {
      return DateTime(isoDate.year, isoDate.month, isoDate.day);
    }

    final match = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(value);
    if (match == null) return null;

    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) return null;
    return date;
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year.toString().padLeft(4, '0')}';
  }

  String _formatIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateForDisplay(String? raw) {
    final date = _parseEventDate(raw);
    return date == null ? (raw?.trim() ?? '') : _formatDisplayDate(date);
  }

  String _formatDateForApi(String raw) {
    final date = _parseEventDate(raw);
    return date == null ? raw.trim() : _formatIsoDate(date);
  }

  String? _validateEventDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';

    final date = _parseEventDate(value);
    if (date == null) return 'Format tanggal harus DD-MM-YYYY';

    if (date.isBefore(_todayDate())) {
      return 'Tanggal tidak boleh sebelum hari ini';
    }

    return null;
  }

  List<GenreModel> _genreOptions(List<GenreModel>? backendGenres) {
    final merged = <String, GenreModel>{};
    final source = backendGenres ?? const <GenreModel>[];

    for (final genre in source) {
      if (genre.name.isNotEmpty) merged[genre.name] = genre;
    }
    for (final genre in _genres) {
      if (genre.name.isNotEmpty) merged.putIfAbsent(genre.name, () => genre);
    }

    return merged.values.toList();
  }

  List<int> _selectedGenreIds(List<GenreModel> genres) {
    return genres
        .where((genre) => _selectedGenres.contains(genre.name))
        .map((genre) => genre.id)
        .where((id) => id > 0)
        .toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu genre.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final genreOptions = _genreOptions(ref.read(genresProvider).valueOrNull);
    final genreIds = _selectedGenreIds(genreOptions);
    if (genreIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Genre belum tersedia dari backend. Coba refresh dulu.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'budget': int.parse(_budgetCtrl.text.replaceAll('.', '')),
        'event_date': _formatDateForApi(_dateCtrl.text),
        'venue_name': _venueCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        if (widget.event == null) 'status': 'dibuka',
        'genre_ids': genreIds,
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
              status: 'dibuka',
              genreIds: data['genre_ids'] as List<int>,
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
    final genresAsync = ref.watch(genresProvider);
    final genreOptions = _genreOptions(genresAsync.valueOrNull);
    final genresLoading = genresAsync.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final genresError = genresAsync.maybeWhen(
      error: (_, __) => true,
      orElse: () => false,
    );
    
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
                  const SizedBox(width: 48),
                  Text(
                    isEdit ? 'Edit Event' : 'Buat Event',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                    _buildGenreMultiSelect(
                      context,
                      genreOptions,
                      isLoading: genresLoading,
                      hasError: genresError,
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
                      hint: 'DD-MM-YYYY',
                      suffixIcon: Icons.calendar_today,
                      readOnly: true,
                      validator: _validateEventDate,
                      onTap: () async {
                        final today = _todayDate();
                        final selectedDate = _parseEventDate(_dateCtrl.text);
                        final initial = selectedDate != null &&
                                !selectedDate.isBefore(today)
                            ? selectedDate
                            : today;
                          
                        final date = await showDatePicker(
                          context: context,
                          initialDate: initial,
                          firstDate: today,
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
                          _dateCtrl.text = _formatDisplayDate(date);
                        }
                      },
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

                    _buildSelectedAddressCard(),

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

  Widget _buildGenreMultiSelect(
    BuildContext context,
    List<GenreModel> genres,
    {
    required bool isLoading,
    required bool hasError,
  }) {
    final hasSelection = _selectedGenres.isNotEmpty;
    return InkWell(
      onTap:
          isLoading || hasError || genres.isEmpty ? null : () => _showGenrePicker(context, genres),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.uiDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: hasSelection
                  ? Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _selectedGenres
                          .map(
                            (genre) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.highlight.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.highlight
                                      .withValues(alpha: 0.28),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    genre,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedGenres.remove(genre)),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : Text(
                      isLoading
                          ? 'Memuat genre...'
                          : hasError
                              ? 'Genre gagal dimuat'
                              : genres.isEmpty
                                  ? 'Genre belum tersedia'
                                  : 'Pilih genre...',
                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down,
                color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _showGenrePicker(
    BuildContext context,
    List<GenreModel> genres,
  ) async {
    final tempSelected = Set<String>.from(_selectedGenres);
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.neutralDark,
              title: const Text(
                'Pilih Genre',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: genres
                        .map(
                          (genre) => CheckboxListTile(
                            value: tempSelected.contains(genre.name),
                            onChanged: (checked) {
                              setDialogState(() {
                                if (checked == true) {
                                  tempSelected.add(genre.name);
                                } else {
                                  tempSelected.remove(genre.name);
                                }
                              });
                            },
                            dense: true,
                            activeColor: AppTheme.highlight,
                            checkColor: Colors.white,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              genre.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, tempSelected),
                  child: const Text('Pilih'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedGenres
          ..clear()
          ..addAll(result);
      });
    }
  }

  Widget _buildSelectedAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.highlight.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.highlight.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isResolvingAddress
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.highlight,
                  ),
                )
              : const Icon(
                  Icons.location_on,
                  color: AppTheme.highlight,
                  size: 18,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ALAMAT LOKASI TERPILIH',
                  style: TextStyle(
                    color: AppTheme.highlight,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _addressCtrl.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
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
