import 'package:caritalent_mobile/features/dashboard/presentation/widgets/view_location_modal.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class EventMapButton extends StatelessWidget {
  final String eventName;
  final String displayAddress;
  final double? latitude;
  final double? longitude;
  final bool expanded;

  const EventMapButton({
    super.key,
    required this.eventName,
    required this.displayAddress,
    required this.latitude,
    required this.longitude,
    this.expanded = false,
  });

  bool get _canOpen => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _canOpen ? Icons.map_outlined : Icons.location_off_outlined,
          size: 15,
          color: _canOpen ? const Color(0xFFC48DF6) : Colors.white38,
        ),
        const SizedBox(width: 5),
        Text(
          'Peta',
          style: TextStyle(
            color: _canOpen ? const Color(0xFFC48DF6) : Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_canOpen) ...[
          const SizedBox(width: 3),
          const Icon(
            Icons.open_in_new_rounded,
            size: 12,
            color: Color(0xFFC48DF6),
          ),
        ],
      ],
    );

    return InkWell(
      onTap: _canOpen
          ? () => ViewLocationModal.show(
                context,
                eventName: eventName,
                displayAddress: displayAddress,
                location: LatLng(latitude!, longitude!),
              )
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: expanded ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: (_canOpen ? const Color(0xFFC48DF6) : Colors.white)
              .withValues(alpha: _canOpen ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (_canOpen ? const Color(0xFFC48DF6) : Colors.white)
                .withValues(alpha: _canOpen ? 0.22 : 0.08),
          ),
        ),
        child: content,
      ),
    );
  }
}
