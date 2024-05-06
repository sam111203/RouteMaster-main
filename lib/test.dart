import 'package:authentication/prehomepage.dart';
import 'package:authentication/routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
int selectedIndex = 0;
String apiKey1 = 'AIzaSyDm-MaPLtStPAEPLi-nQ2_DAgh24BRGH14';
String radius = "1000"; //in metre
List<dynamic> busStations = [];
List<dynamic> busStations1 = [];
String joinedPairs='';
String pair='';
String firststop='';
String laststop='';
List<dynamic> trainStations = [];
List<dynamic> trainStations1 = [];
List<String> pairs = [];
String tS = '';
String tS1 = '';
String bS = '';
String bS1 = '';
String transitOptionsDescription = '';

class Transit1 extends StatefulWidget {
  const Transit1({super.key});

  @override
  State<Transit1> createState() => _Transit1State();
}


class _Transit1State extends State<Transit1> {

  void _handleRadioValueChange(int? value) {
    setState(() {
      selectedIndex = value!;
    });
    if(selectedIndex==1)
      getNearbyBusStations();
    else if(selectedIndex==2)
      getNearbyTrainStations();
    else if(selectedIndex==3) {
      getTransitOptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Route Options'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top:10),
              child: Row(
                children: <Widget>[
                  Radio(
                    value: 1,
                    groupValue: selectedIndex,
                    onChanged: _handleRadioValueChange,
                  ),
                  Text('Bus',style: TextStyle(fontSize: 17),),
                  Radio(
                    value: 2,
                    groupValue: selectedIndex,
                    onChanged: _handleRadioValueChange,
                  ),
                  Text('Train',style: TextStyle(fontSize: 17),),
                  Radio(
                    value: 3,
                    groupValue: selectedIndex,
                    onChanged: _handleRadioValueChange,
                  ),
                  Text('Transit',style: TextStyle(fontSize: 17),),
                ],
              ),
            ),
            if(selectedIndex==1)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.blue[50],
                child: ListTile(
                  leading: const Icon(Icons.directions_bus_sharp),
                  title: Text('Nearest Bus Stop:', style: TextStyle(fontStyle: FontStyle.italic),),
                  subtitle: Text(
                    '$bS',
                  ),
                  selected: true,
                  onTap: () {

                  },
                ),
              ),
            ),
            if(selectedIndex==2)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.blue[50],
                  child: ListTile(
                    leading: const Icon(Icons.train_outlined),
                    title: Text('Nearest Train Station:'),
                    subtitle: Text(
                      '$tS',
                    ),
                    selected: true,
                    onTap: () {

                    },
                  ),
                ),
              ),
            if(selectedIndex==3)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.blue[50],
                  child: ListTile(
                    leading: const Icon(Icons.directions),
                    title: const Text(
                      'Transit',
                    ),

                    subtitle: Text('${destinationStops.asMap().entries.map((entry) => '${entry.value} >>>>> ${arrivalStops[entry.key]}').join(', ')}'),
                    selected: true,
                    onTap: () {

                    },
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(right:10),
              child: ElevatedButton(
                onPressed: (){

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => RouteDisplay(),
                      ),
                    );
                }, child: Text('Navigate'),
              ),

            ),
          ],
        ),

      ),
    );
  }

  void getNearbyTrainStations() async{
    var url = Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$sourcelat,$sourcelong&radius=4000&type=train_station&key=$apiKey1');
    var url1 = Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$destinationlat,$destinationlong&radius=4000&type=train_station&key=$apiKey1');
    var response = await http.post(url);
    var response1= await http.post(url1);
    if (response.statusCode == 200) {
      trainStations = jsonDecode(response.body.toString())['results'];
      setState(() {
        tS = trainStations[0] ['name'];
        // print(tS);
      });
    } else {
      tS= 'No nearby Train Stations to source';
      print('Failed to get nearest train station: ${response.statusCode}');
    }
    if (response1.statusCode == 200) {
      trainStations1 = jsonDecode(response1.body.toString())['results'];
      setState(() {
        tS1 = trainStations1[0] ['name'];
        print(tS1);
      });
    } else {
      tS1= 'No nearby Train Stations to destination';
      print('Failed to get nearest train station: ${response1.statusCode}');
    }
  }
  void getNearbyBusStations() async{
    var url = Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$sourcelat,$sourcelong&radius=2000&type=bus_station&key=$apiKey1');
    var url2 = Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$destinationlat,$destinationlong&radius=2000&type=bus_station&key=$apiKey1');
    var response = await http.post(url);
    var response2 = await http.post(url2);
    if (response.statusCode == 200) {
      busStations = jsonDecode(response.body.toString())['results'];
      setState(() {
        bS = busStations[0] ['name'];
        //print(bS);
      });
    } else {
      bS= 'No nearby Bus Stations';
      print('Failed to get nearest bus station: ${response.statusCode}');
    }
    if (response2.statusCode == 200) {
      busStations1 = jsonDecode(response2.body.toString())['results'];
      setState(() {
        bS1 = busStations1[0] ['name'];
        //print(bS1);
      });
    } else {
      bS1= 'No nearby Train Stations to destination';
      print('Failed to get nearest train station: ${response2.statusCode}');
    }
  }
  var arrivalStops = <String>[];
  var destinationStops = <String>[];
  void getTransitOptions() async {
    arrivalStops.clear();
    destinationStops.clear();
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$sourcelat,$sourcelong&destination=$destinationlat,$destinationlong&mode=transit&key=$apiKey1');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      var routes = data['routes'];
      if (routes.isNotEmpty) {
        var legs = routes[0]['legs'];

        legs[0]['steps'].forEach((step) {
          if (step['travel_mode'] == 'TRANSIT') {
            var transitDetails = step['transit_details'];
            var transitMode = transitDetails?['line']?['vehicle']?['type'];
            if (transitMode == 'BUS' || transitMode == 'RAIL') {
              var departureStop = transitDetails?['departure_stop'];
              var arrivalStop = transitDetails?['arrival_stop'];
              if (departureStop != null && arrivalStop != null) {
                arrivalStops.add(arrivalStop['name'] ?? '');
                destinationStops.add(departureStop['name'] ?? '');
              }
            }
          }
        });

        // Print the contents of the lists

        print('Destination Stops: $destinationStops');
        print('Arrival Stops: $arrivalStops');
        for (int i = 0; i < destinationStops.length && i < arrivalStops.length; i++) {
          // Concatenate elements from both lists as pairs
          pair = '${destinationStops[i]} >>>>> ${arrivalStops[i]}';
          pairs.add(pair); // Add the pair to the list
          if (arrivalStops[i] == laststop) {
            break; // Exit the loop if the condition is met
          }
        }
        firststop=destinationStops[0]!;
        laststop=arrivalStops.last!;
        print(laststop);
        for (int i = 0; i < destinationStops.length && i < arrivalStops.length; i++) {
          // Concatenate elements from both lists as pairs
            pair = '${destinationStops[i]} >>>>> ${arrivalStops[i]}';
            pairs.add(pair); // Add the pair to the list

        }
        joinedPairs = pairs.join(' then ');


        setState(() {
          transitOptionsDescription = arrivalStops.isNotEmpty && destinationStops.isNotEmpty
              ? 'Arrival Stops: $arrivalStops\nDestination Stops: $destinationStops'
              : 'No bus or train transit options found';
        });
      } else {
        setState(() {
          transitOptionsDescription = 'No transit options found';
        });
      }
    } else {
      setState(() {
        transitOptionsDescription = 'Failed to get transit options: ${response.statusCode}';
      });
    }
  }


}
