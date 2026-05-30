import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CreateEventModal extends StatefulWidget {
  const CreateEventModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateEventModal(),
    );
  }

  @override
  State<CreateEventModal> createState() => _CreateEventModalState();
}

class _CreateEventModalState extends State<CreateEventModal> {
  final _formKey = GlobalKey<FormState>();
  LatLng? _selectedLocation;
  final _mapController = MapController();

  final _latController = TextEditingController(text: 'Belum ada pin');
  final _lngController = TextEditingController(text: 'Belum ada pin');

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Buat Event',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 48), // Balance for centering
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
                     const Text(
                      'Buat Event Baru',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Isi detail event yang ingin kamu selenggarakan.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.border),
                    const SizedBox(height: 16),

                    _buildLabel('Judul Event *'),
                    _buildTextField(hint: 'Masukkan judul...'),
                    const SizedBox(height: 12),

                    _buildLabel('Deskripsi'),
                    _buildTextField(hint: 'Deskripsikan event kamu...', maxLines: 3),
                    const SizedBox(height: 12),

                    _buildLabel('Genre Dibutuhkan *'),
                    _buildDropdown(hint: 'Pilih genre...'),
                    const SizedBox(height: 12),

                    _buildLabel('Budget (Rp) *'),
                    _buildTextField(hint: 'Masukkan jumlah...', keyboardType: TextInputType.number),
                    const SizedBox(height: 12),

                    _buildLabel('Tanggal Event *'),
                    _buildTextField(hint: 'dd/mm/yyyy', suffixIcon: Icons.calendar_today),
                    const SizedBox(height: 12),

                    _buildLabel('Status Awal'),
                    _buildDropdown(hint: 'Draft (simpan dulu)'),
                    const SizedBox(height: 12),

                    _buildLabel('Nama Venue *'),
                    _buildTextField(hint: 'Masukkan venue...'),
                    const SizedBox(height: 12),

                    _buildLabel('Kota *'),
                    _buildTextField(hint: 'Masukkan kota...'),
                    const SizedBox(height: 16),

                    const Text('Pilih Lokasi di Peta', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
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
                              initialCenter: const LatLng(-6.914744, 107.609810), // Bandung
                              initialZoom: 13.0,
                              onTap: _onMapTap,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.caritalent',
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
                                        color: Color(0xFFD8B4FE), // Light Purple
                                        size: 32,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          // Zoom controls
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Column(
                              children: [
                                _buildMapButton(Icons.add, () {
                                  final currentZoom = _mapController.camera.zoom;
                                  _mapController.move(_mapController.camera.center, currentZoom + 1);
                                }),
                                const SizedBox(height: 4),
                                _buildMapButton(Icons.remove, () {
                                  final currentZoom = _mapController.camera.zoom;
                                  _mapController.move(_mapController.camera.center, currentZoom - 1);
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildLabel('Latitude'),
                    _buildTextField(controller: _latController, readOnly: true, fillColor: AppTheme.uiDark),
                    const SizedBox(height: 12),

                    _buildLabel('Longitude'),
                    _buildTextField(controller: _lngController, readOnly: true, fillColor: AppTheme.uiDark),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Bottom Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.neutralDark,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC026D3), Color(0xFF6B21A8)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC026D3).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(Icons.add, color: Color(0xFF9333EA), size: 16, weight: 800),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Buat Event',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    bool hasAsterisk = text.endsWith('*');
    String baseText = hasAsterisk ? text.substring(0, text.length - 1).trim() : text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: baseText,
          style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          children: [
            if (hasAsterisk)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFFCA5A5)), // Pale Red
              )
          ],
        ),
      ),
    );
  }

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
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.white70, size: 18) : null,
        fillColor: fillColor ?? AppTheme.uiDark, // Using uiDark for that deep input field look
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.highlight),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 18),
          dropdownColor: AppTheme.neutralDark,
          items: const [],
          onChanged: (_) {},
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
