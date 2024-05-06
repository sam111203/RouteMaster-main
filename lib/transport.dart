import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class Transit extends StatefulWidget {
  const Transit({super.key});

  @override
  State<Transit> createState() => _TransitState();
}

class _TransitState extends State<Transit> {
  Future<void> getDirections() async {
    String apiKey = 'AIzaSyDm-MaPLtStPAEPLi-nQ2_DAgh24BRGH14';
    String origin = 'Powai,Mumbai';
    String destination = 'Xavier Institute of Engineering, Mahim';
    String transitMode= 'TRANSIT_TRAVEL_MODE_UNSPECIFIED';
    String mode = 'transit';// Can be 'driving', 'walking', 'bicycling', or 'transit'
    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$origin'
        '&destination=$destination'
        '&transit_mode=$transitMode'
        '&key=$apiKey';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
    } else {
      print('Failed to fetch directions: ${response.reasonPhrase}');
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Transport Options',style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back_rounded,color: Colors.white,)),
        ),
        body: ElevatedButton(
          onPressed: () async{
            await getDirections();
          },
          child: Text('Try'),
        ),
      ),
    );
  }
}
