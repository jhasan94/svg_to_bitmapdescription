import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:svg_to_bitmapdescription/services/svg_to_marker_converter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  ///Static LatLng
  final LatLng location = const LatLng(29.087135836966137, 48.06660284599616);
  ///add your network svg path here
  final String url = "";
  ///add your local asset path here
  final String asset = "";

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  BitmapDescriptor marker = BitmapDescriptor.defaultMarker;
  @override
  void initState() {
    super.initState();
    _loadMarker();
  }

  Future<void> _loadMarker() async {
    ///for network svg
   var convertMarker = await SvgToMarkerConverter.fromNetwork(widget.url, context);
   ///for local svg asset
   //var marker = await SvgToMarkerConverter.fromAssets(widget.asset);

    setState(() {
      marker = convertMarker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: GoogleMap(
            zoomGesturesEnabled: true,
            initialCameraPosition: CameraPosition(
              target: widget.location,
              zoom: 16.0,
            ),
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('1'),
                position: widget.location,
                icon: marker, // Use custom marker icon
              ),
            },
          ),
        ),
      ),
    );
  }
}
