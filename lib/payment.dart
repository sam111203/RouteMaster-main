import 'dart:io';

import 'package:authentication/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler package

void main() {
  runApp(TicketingApp());
}

class TicketingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => TicketBookingScreen(),
        '/ticket': (context) => TicketScreen(),
      },
    );
  }
}

class TicketBookingScreen extends StatefulWidget {
  @override
  _TicketBookingScreenState createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  final Razorpay _razorpay = Razorpay();

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment successful!');
    print('Payment ID: ${response.paymentId}');
    print('Order ID: ${response.orderId}');

    Navigator.pushNamed(
      context,
      '/ticket',
      arguments: TicketScreenArguments(
        source: '$bS', // Replace with actual source
        destination: 'Destination', // Replace with actual destination
        paymentId: response.paymentId,
        orderId: response.orderId,
        rate: 200, // Replace with actual rate
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment failed!');
    print('Code: ${response.code}');
    print('Message: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet selected: ${response.walletName}');
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_BkSosQncVLWkPD',
      'amount': 200,
      'name': 'Bus/Train Ticket Booking',
      'description': 'Payment for bus/train ticket',
      'prefill': {
        'contact': '9324331547',
        'email': 'hardiktiwari065@gmail.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
    }
  }

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
            BusTicketBookingScreen(startPayment: _startPayment),
            TrainTicketBookingScreen(startPayment: _startPayment),
          ],
        ),
      ),
    );
  }
}

class BusTicketBookingScreen extends StatelessWidget {
  final VoidCallback startPayment;

  const BusTicketBookingScreen({required this.startPayment});

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
                  hintText: '$bS',
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
                  hintText: '$bS1',
                  border: InputBorder.none,
                  icon: Icon(Icons.location_on),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startPayment,
              child: Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}

class TrainTicketBookingScreen extends StatelessWidget {
  final VoidCallback startPayment;

  const TrainTicketBookingScreen({required this.startPayment});

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
                  hintText: '$tS',
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
                  hintText: '$tS1',
                  border: InputBorder.none,
                  icon: Icon(Icons.location_on),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startPayment,
              child: Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TicketScreenArguments args =
    ModalRoute.of(context)!.settings.arguments as TicketScreenArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Source: ${args.source ?? "Unknown"}',
                style: TextStyle(fontSize: 18)),
            Text('Destination: ${args.destination ?? "Unknown"}',
                style: TextStyle(fontSize: 18)),
            Text('Payment ID: ${args.paymentId ?? "Unknown"}',
                style: TextStyle(fontSize: 18)),
            Text('Order ID: ${args.orderId ?? "Unknown"}',
                style: TextStyle(fontSize: 18)),
            Text('Rate: ${args.rate ?? "Unknown"}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Date & Time: ${_formatDateTime(DateTime.now())}',
                style: TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: () => _savePdf(context, args),
              child: Text('Download Ticket'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePdf(BuildContext context, TicketScreenArguments args) async {
    final pdf = pw.Document();

    // Load the NotoSans font
    final fontData =
    await rootBundle.load("assets/fonts/NotoSans-VariableFont_wdth,wght.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            children: [
              pw.Text('Source: ${args.source ?? "Unknown"}',
                  style: pw.TextStyle(font: ttf, fontSize: 25)), // Use the font
              pw.Text('Destination: ${args.destination ?? "Unknown"}',
                  style: pw.TextStyle(font: ttf, fontSize: 25)), // Use the font
              pw.Text('Payment ID: ${args.paymentId ?? "Unknown"}',
                  style: pw.TextStyle(font: ttf, fontSize: 25)), // Use the font
              pw.Text('Order ID: ${args.orderId ?? "Unknown"}',
                  style: pw.TextStyle(font: ttf, fontSize: 25)), // Use the font
              pw.Text('Rate: ${args.rate ?? "Unknown"}',
                  style: pw.TextStyle(font: ttf, fontSize: 25)), // Use the font
              pw.Text('Date & Time: ${_formatDateTime(DateTime.now())}',
                  style: pw.TextStyle(font: ttf, fontSize: 25)), // Use the font
            ],
          ),
        ),
      ),
    );

    // Request write external storage permission
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with saving PDF

      // Allow the user to choose the destination directory
      final filePath = await FilePicker.platform.getDirectoryPath();
      print("The file path is  $filePath");
      if (filePath == null) {
        // User canceled the file picking operation
        return;
      }

      // Generate the file path
      final pdfFile = File('$filePath/ticket.pdf');

      // Write the PDF to the file
      await pdfFile.writeAsBytes(await pdf.save());

      // Display a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket downloaded successfully')),
      );

      // Print the file path after saving
      print('PDF saved to: ${pdfFile.path}');
    } else {
      // Permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to save PDF')),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${_padNumber(dateTime.month)}-${_padNumber(dateTime.day)}';
  }

  String _formatTime(DateTime dateTime) {
    return '${_padNumber(dateTime.hour)}:${_padNumber(dateTime.minute)}:${_padNumber(dateTime.second)}';
  }

  String _padNumber(int number) {
    return number.toString().padLeft(2, '0');
  }
}

class TicketScreenArguments {
  final String? source;
  final String? destination;
  final String? paymentId;
  final String? orderId;
  final int? rate;

  TicketScreenArguments({
    required this.source,
    required this.destination,
    required this.paymentId,
    required this.orderId,
    required this.rate,
  });
}
