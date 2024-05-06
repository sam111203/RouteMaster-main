import 'package:authentication/test.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';
//import 'package:flutter_stripe_payment/flutter_stripe_payment.dart';
import 'prehomepage.dart';
void main() {
  runApp(TicketingApp());
}

class TicketingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ticketing System',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TicketBookingScreen(),
    );
  }
}

class TicketBookingScreen extends StatefulWidget {
  @override
  _TicketBookingScreenState createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ticketing System'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Bus'),
              Tab(text: 'Train'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BusTicketBookingScreen(),
            TrainTicketBookingScreen(),
          ],
        ),
      ),
    );
  }
}

class BusTicketBookingScreen extends StatefulWidget {
  @override
  _BusTicketBookingScreenState createState() => _BusTicketBookingScreenState();
}

class _BusTicketBookingScreenState extends State<BusTicketBookingScreen> {
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  String _selectedPaymentMethod = 'UPI'; // Default payment method is UPI

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      print(e);
      apps = [];
    });
    super.initState();
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "chrisjonesjrx@okhdfcbank",
      receiverName: "Chris Jones",
      transactionRefId: "Testing",
      amount: 1, // You can update this amount dynamically based on transportation changes
    );
  }

  Future<void> startCardTransaction() async {
    // Placeholder implementation for card transaction
    print('Card transaction initiated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.grey[200],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: bS!,
                  enabled: false,
                  border: InputBorder.none,
                  icon: Icon(Icons.location_on),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.grey[200],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: dest!,
                  enabled: false,
                  border: InputBorder.none,
                  icon: Icon(Icons.location_on),
                ),
              ),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedPaymentMethod,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              items: <String>['UPI', 'Credit Card', 'Debit Card']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            if (_selectedPaymentMethod == 'UPI') displayUpiApps(),
            if (_selectedPaymentMethod == 'Credit Card' || _selectedPaymentMethod == 'Debit Card')
              ElevatedButton(
                onPressed: startCardTransaction,
                child: Text('Pay with ${_selectedPaymentMethod}'),
              ),
          ],
        ),
      ),
    );
  }

  Widget displayUpiApps() {
    if (apps == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (apps!.isEmpty) {
      return Center(
        child: Text(
          "No apps to handle transaction.",
          style: TextStyle(fontSize: 20),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  _transaction = initiateTransaction(app);
                  setState(() {});
                },
                child: Container(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }
}


class TrainTicketBookingScreen extends StatefulWidget {
  @override
  _TrainTicketBookingScreenState createState() => _TrainTicketBookingScreenState();
}

class _TrainTicketBookingScreenState extends State<TrainTicketBookingScreen> {
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  String _selectedPaymentMethod = 'UPI'; // Default payment method is UPI

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      print(e);
      apps = [];
    });
    super.initState();
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    // Generate a unique transaction reference ID
    String transactionRefId = generateTransactionRefId();

    // Start the UPI transaction with the generated transaction reference ID
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "chrisjonesjrx@okhdfcbank",
      receiverName: "Chris Jones",
      transactionRefId: transactionRefId,
      amount: 1.00, // You can update this amount dynamically based on transportation changes
    );
  }

  String generateTransactionRefId() {
    // Here, you can implement your logic to generate a unique transaction reference ID.
    // For example, you can combine the current timestamp with a unique identifier.
    // Alternatively, you can use a UUID library to generate a unique identifier.

    // Example using current timestamp and a unique identifier
    String uniqueId = 'your_unique_identifier'; // Replace with your actual unique identifier
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$uniqueId-$timestamp';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.grey[200],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: tS!,
                  enabled: false,
                  border: InputBorder.none,
                  icon: Icon(Icons.location_on),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.grey[200],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: dest!,
                  enabled: false,
                  border: InputBorder.none,
                  icon: Icon(Icons.location_on),
                ),
              ),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedPaymentMethod,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPaymentMethod = newValue;
                  });
                }
              },
              items: <String>['UPI', 'Credit Card', 'Debit Card']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            if (_selectedPaymentMethod == 'UPI') displayUpiApps(),
            if (_selectedPaymentMethod == 'Credit Card' || _selectedPaymentMethod == 'Debit Card')
              ElevatedButton(
                onPressed: () {
                  // Implement payment method for card
                  //_makeStripePayment();
                },
                child: Text('Pay with ${_selectedPaymentMethod}'),
              ),
          ],
        ),
      ),
    );
  }

  Widget displayUpiApps() {
    if (apps == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (apps!.isEmpty) {
      return Center(
        child: Text(
          "No apps to handle transaction.",
          style: TextStyle(fontSize: 20),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  _transaction = initiateTransaction(app);
                  setState(() {});
                },
                child: Container(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }
}