import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class EventLocationPanel extends StatefulWidget {
  final String venueName;
  final String displayAddress;
  final double? latitude;
  final double? longitude;

  const EventLocationPanel({
    required this.venueName,
    required this.displayAddress,
    required this.latitude,
    required this.longitude,
    super.key,
  });

  @override
  State<EventLocationPanel> createState() => _EventLocationPanelState();
}

class _EventLocationPanelState extends State<EventLocationPanel> {
  final MapController _mapController = MapController();

  bool get _hasCoordinates =>
      widget.latitude != null && widget.longitude != null;

  LatLng get _location => LatLng(widget.latitude!, widget.longitude!);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _openGoogleMaps() async {
    if (!_hasCoordinates) return;

    final url = Uri.https(
      'www.google.com',
      '/maps/search/',
      {
        'api': '1',
        'query': '${widget.latitude},${widget.longitude}',
      },
    );

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) _showMapError();
    } catch (_) {
      if (mounted) _showMapError();
    }
  }

  void _showMapError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Maps tidak bisa dibuka di perangkat ini.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF9D7BFF),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.venueName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.displayAddress.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.displayAddress,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_hasCoordinates)
            Container(
              height: 190,
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _location,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.caritalent.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _location,
                            width: 44,
                            height: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Column(
                      children: [
                        _MapControlButton(
                          icon: Icons.add,
                          onPressed: () => _changeZoom(1),
                        ),
                        const SizedBox(height: 4),
                        _MapControlButton(
                          icon: Icons.remove,
                          onPressed: () => _changeZoom(-1),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openGoogleMaps,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF21143D),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Buka di Google Maps',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: Colors.white38,
                    size: 30,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Koordinat peta belum tersedia',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _changeZoom(double delta) {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + delta,
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
      ),
    );
  }
}
