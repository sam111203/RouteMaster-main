import 'dart:async';
import 'dart:convert';
import 'prehomepage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:authentication/payment.dart';
late bool servicePermission = false;
late LocationPermission permission;
double buslat=0.0,buslong=0.0;
var uuid1 = Uuid();
String _sessionToken1 = '67';
List<dynamic> _placesList2 = [];
Position? _currentLocation;
bool showListView = false;// Flag to control the visibility of ListView.builder
class RouteDisplay extends StatefulWidget {
  const RouteDisplay({Key? key}) : super(key: key);

  @override
  State<RouteDisplay> createState() => _RouteDisplayState();
}

class _RouteDisplayState extends State<RouteDisplay> {
  @override

  void onChange() {
    if (_sessionToken1 == null) {
      setState(() {
        _sessionToken1 = uuid1.v4();
      });
    }
    if(selectedIndex!=0&&selectedIndex==1)
     getSuggestion(bS!);
    else if(selectedIndex!=0&&selectedIndex==2)
      getSuggestion(tS!);

  }
  void getSuggestion(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessionToken1';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();
    print('data');
    print(data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      setState(() async{
        _placesList2 = jsonDecode(response.body.toString())['predictions'];
        List<Location> locations1 = await locationFromAddress(_placesList2[0] ['description']);
        buslat = locations1.last.latitude;
        print(buslat);
        buslong = locations1.last.longitude;
        print(buslong);
        showListView = true; // Show ListView.builder when suggestions are loaded
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _kGooglePlex =
  CameraPosition(target: LatLng(sourcelat, sourcelong), zoom: 14);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  Map<PolylineId, Polyline> polylines = {};

  Future<Position> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print("Service Disabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _getPolylineCoordinates(LatLng origin, LatLng destination) async {
    String apiKey = 'AIzaSyDm-MaPLtStPAEPLi-nQ2_DAgh24BRGH14'; // Replace with your actual API key
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
            color: Colors.blue,
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
        onChange();
        _kGooglePlex = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        );

        latlng = [
          LatLng(sourcelat!,sourcelong!),
          LatLng(buslat!,buslong!),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
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
                      builder: (BuildContext context) => TicketingApp(),
                    ),
                  );
                },
                child: Text("Confirm Route"),
              ),
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
          mapType: MapType.normal,
        ),
      ),
    );
  }
}