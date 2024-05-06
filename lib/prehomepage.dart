import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'homepage.dart';
import 'package:http/http.dart' as http;
import 'feedback.dart';
TextEditingController _controller1 = TextEditingController();
TextEditingController _controller2 = TextEditingController();
String dest ='';
final String apiKey = 'AIzaSyDm-MaPLtStPAEPLi-nQ2_DAgh24BRGH14';
double sourcelat = 0.0,sourcelong=0.0,destinationlat=0.0,destinationlong=0.0;
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var uuid = Uuid();
  String _sessionToken = '12';
  String _sessionToken1 = '34';
  List<dynamic> _placesList = [];
  List<dynamic> _placesList1 = [];
  String selectedItem = '';
  bool showListView = false;// Flag to control the visibility of ListView.builder
  bool showListView1 = false;// Flag to control the visibility of ListView.builder
  
  @override
  void initState() {
    super.initState();

    _controller1.addListener(() {
      onChange();
    });
    _controller2.addListener(() {
      onChange1();
    });
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }

    getSuggestion(_controller1.text);
  }

  void onChange1() {
    if (_sessionToken1 == null) {
      setState(() {
        _sessionToken1 = uuid.v4();
      });
    }

    getSuggestion1(_controller2.text);
  }
  void getSuggestion(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();
    print('data');
    print(data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      setState(() async{
        _placesList = jsonDecode(response.body.toString())['predictions'];
        List<Location> locations1 = await locationFromAddress(_placesList[0] ['description']);
        sourcelat = locations1.last.latitude;
        print(sourcelat);
        sourcelong = locations1.last.longitude;
        print(sourcelong);
        showListView = true; // Show ListView.builder when suggestions are loaded
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void getSuggestion1(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessionToken1';

    var response1 = await http.get(Uri.parse(request));
    var data1 = response1.body.toString();
    print('data');
    print(data1);
    print(response1.body.toString());

    if (response1.statusCode == 200) {
      _placesList1 = jsonDecode(response1.body.toString())['predictions'];
      List<Location> locations = await locationFromAddress(_placesList1[0] ['description']);
      setState(() {
        destinationlat = locations.last.latitude;
        print(destinationlat);
        destinationlong = locations.last.longitude;
        print(destinationlong);
        showListView1 = true; // Show ListView.builder when suggestions are loaded
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if(_selectedIndex==2){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  FeedbackSender()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: (){
              launchUrl(Uri.parse('tel:102'));
             }, icon: Image.asset('assets/healthcare.png',  // Path to your custom icon image
                 width: 70,  // Adjust width as needed
                 height: 80,  // Adjust height as needed
                  ),
            ),
                 ],
          backgroundColor: Colors.deepPurple[400],
          title: Text(
            'RouteMaster',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _controller1,
                onTap: () {
                  setState(() {
                    showListView = true; // Show ListView.builder when text field is tapped
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter Source',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _controller1.clear();
                    },
                    icon: Icon(Icons.clear),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (showListView) // Only show ListView.builder when flag is true
                Expanded(
                  child: ListView.builder(
                    itemCount: _placesList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          setState(() {
                            //showListView = false; // Hide ListView.builder after selection
                            _controller1.text =
                                _placesList[index]['description'].toString();
                          });
                        },
                        title: Text(_placesList[index]['description']),
                      );
                    },
                  ),
                ),
              TextField(
                controller: _controller2,
                decoration: InputDecoration(
                  labelText: 'Enter Destination',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _controller2.clear();
                    },
                    icon: Icon(Icons.clear),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _placesList1.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        setState(() {
                          //showListView1 = false; // Hide ListView.builder after selection
                          _controller2.text =
                              _placesList1[index]['description'].toString();
                        });
                      },
                      title: Text(_placesList1[index]['description']),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                if (_controller1.text.isNotEmpty &&
                    _controller2.text.isNotEmpty) {
                  print(_controller1.text);
                  print(_controller2.text);
                 dest= _controller2!.text;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(title: 'Map'),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        "Please enter both source and destination!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Ok!"),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Icon(Icons.search),
            ),
            SizedBox(height: 16.0),
            FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.navigation),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Feedback',
            ),
          ],
          selectedItemColor: Colors.deepPurple,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
