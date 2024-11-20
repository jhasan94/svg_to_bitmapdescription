import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SvgToMarkerConverter {
  // Scaling factor for SVG rendering
  static const double _scaleFactor = 4.0;
  // Output size for the PNG image
  static const int _outputSize = 400;

  static Future<BitmapDescriptor> fromAssets(String assetPath) async {
    final String svgContent = await _loadSvgFromAssets(assetPath);
    return _convertSvgToBitmapDescriptor(svgContent);
  }

  static Future<BitmapDescriptor> fromNetwork(
      String url, BuildContext context) async {
    final String svgContent = await _loadSvgFromNetwork(url, context);
    return _convertSvgToBitmapDescriptor(svgContent);
  }

  static Future<String> _loadSvgFromAssets(String assetPath) async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (e) {
      throw FlutterError(
          'Failed to load SVG from assets: $assetPath. Error: $e');
    }
  }

  static Future<String> _loadSvgFromNetwork(
      String url, BuildContext context) async {
    try {
      var data = SvgNetworkLoader(url);
      var res = await data.prepareMessage(context);
      return utf8.decode(res!);
    } catch (e) {
      throw Exception('Failed to fetch SVG from network: $url. Error: $e');
    }
  }

  static Future<BitmapDescriptor> _convertSvgToBitmapDescriptor(
      String svgContent) async {
    try {
      final PictureInfo pictureInfo =
          await vg.loadPicture(SvgStringLoader(svgContent), null);

      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      canvas.scale(_scaleFactor, _scaleFactor);
      canvas.drawPicture(pictureInfo.picture);

      final ui.Image image = await pictureRecorder
          .endRecording()
          .toImage(_outputSize, _outputSize);

      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert SVG to BitmapDescriptor');
      }

      return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    } catch (e) {
      throw Exception('Error while converting SVG to BitmapDescriptor: $e');
    }
  }
}
