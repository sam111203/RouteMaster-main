import 'dart:async';
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'prehomepage.dart';
import 'package:authentication/test.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Position? _currentLocation;
late bool servicePermission = false;
late LocationPermission permission;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required String title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(sourcelat, sourcelong), zoom: 14);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  Map<PolylineId, Polyline> polylines = {};

  bool _isSatelliteView = false; // Track if satellite view is enabled

  Future<Position> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print("Service Disabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _getPolylineCoordinates(
      LatLng origin, LatLng destination) async {
    String apiKey =
        'AIzaSyDm-MaPLtStPAEPLi-nQ2_DAgh24BRGH14'; // Replace with your actual API key
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<LatLng> polylineCoordinates = [];

      if (decoded['status'] == 'OK') {
        List<dynamic> routes = decoded['routes'];
        if (routes.isNotEmpty) {
          dynamic route = routes[0];
          dynamic overviewPolyline = route['overview_polyline'];
          String encodedPolyline = overviewPolyline['points'];
          polylineCoordinates = _decodePoly(encodedPolyline);
        }
      }

      setState(() {
        _polyline.add(
          Polyline(
            polylineId: PolylineId("1"),
            points: polylineCoordinates,
            color: Colors.purple,
            width: 3,
          ),
        );
      });
    } else {
      throw Exception('Failed to load polyline coordinates');
    }
  }

  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;
      poly.add(LatLng(latitude, longitude));
    }

    return poly;
  }

  late List<LatLng> latlng = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((position) {
      setState(() {
        _currentLocation = position;

        _kGooglePlex = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        );
        latlng = [
          LatLng(sourcelat!, sourcelong!),
          LatLng(destinationlat!, destinationlong!),
        ];
        _markers.clear();
        for (int i = 0; i < latlng.length; i++) {
          if (i == 0) {
            _markers.add(
              Marker(
                markerId: MarkerId(i.toString()),
                position: latlng[i],
                infoWindow: InfoWindow(
                  title: 'My Start point',
                  snippet: 'Source',
                ),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
          } else if (i == latlng.length - 1) {
            _markers.add(
              Marker(
                markerId: MarkerId(i.toString()),
                position: latlng[i],
                infoWindow: InfoWindow(
                  title: 'My End point',
                  snippet: 'Destination',
                ),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
          }
        }
        _getPolylineCoordinates(latlng[0], latlng[1]);
      });
    });
  }

  void _toggleMapStyle() {
    setState(() {
      _isSatelliteView = !_isSatelliteView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => HomePage(),
                ),
              );
            },
            icon: Icon(Icons.arrow_circle_left_outlined),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => Transit1(),
                    ),
                  );
                },
                child: Text("Choose best transit options"),
              ),
            ),
            IconButton(
              onPressed: _toggleMapStyle,
              icon: Icon(_isSatelliteView
                  ? Icons.map_outlined
                  : Icons.satellite_outlined),
            ),
          ],
        ),
        body: GoogleMap(
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          myLocationEnabled: true,
          polylines: _polyline,
          initialCameraPosition: _kGooglePlex,
          mapType: _isSatelliteView ? MapType.satellite : MapType.normal,
        ),
      ),
    );
  }
}
