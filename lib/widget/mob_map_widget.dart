import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_widget.dart';

// Update getMapWidget to accept latitude and longitude as parameters
MapWidget getMapWidget(String latitude, String longitude) => MobMap(
      latitude: double.parse(latitude),
      longitude: double.parse(longitude),
    );

class MobMap extends StatefulWidget implements MapWidget {
  final double latitude;
  final double longitude;

  MobMap({Key? key, required this.latitude, required this.longitude})
      : super(key: key);

  @override
  State<MobMap> createState() => MobMapState();
}

class MobMapState extends State<MobMap> {
  late GoogleMapController mapController;

  // Use the passed latitude and longitude to set the center
  late final LatLng _center = LatLng(widget.latitude, widget.longitude);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.0, // Adjust zoom level as needed
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        compassEnabled: true,
        markers: {
          Marker(
            markerId: MarkerId('target-location'),
            position: _center,
          ),
        },
      ),
    );
  }
}
