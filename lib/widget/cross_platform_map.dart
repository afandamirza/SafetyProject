// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:safetyreport/widget/iframe_map.dart';
// import 'package:safetyreport/widget/mobile_map.dart';

// class CrossPlatformMap extends StatelessWidget {
//   final String mapSrc;
//   final LatLng location;

//   const CrossPlatformMap({super.key, required this.mapSrc, required this.location});

//   @override
//   Widget build(BuildContext context) {
//     if (kIsWeb) {
//       // Return iframe map for web
//       return IframeMap(
//         src: mapSrc,
//         width: 640,
//         height: 360,
//       );
//     } else {
//       // Return Google Map for mobile
//       return SizedBox(
//         width: 640,
//         height: 360,
//         child: MobileMap(location: location),
//       );
//     }
//   }
// }
