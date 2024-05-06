import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FeedbackSender(),
    );
  }
}

class FeedbackSender extends StatefulWidget {
  const FeedbackSender({Key? key}) : super(key: key);

  @override
  State<FeedbackSender> createState() => _FeedbackSenderState();
}

class _FeedbackSenderState extends State<FeedbackSender> {
  final TextEditingController Textcontroller = TextEditingController();

  void sendFeedbackEmail(String feedback) async {
    String username = 'samsaji111203@gmail.com'; // Your email
    String password ='hkqg xsjn ewyg uydo'; // Your password

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'User')
      ..recipients.add('khanaamir1554@gmail.com') // Recipient email
      ..subject = 'Feedback'
      ..text = feedback;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());        showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Feedback Sent'),
          content: Text('Thank you for your feedback!'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Ok"),
            ),
          ],
        ),
      );
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Section'),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Please enter your feedback below",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: TextFormField(
                controller: Textcontroller,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    hintText: 'Enter your Feedback',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  String feedback = Textcontroller.value.text.trim();
                  if (feedback.isNotEmpty) {
                    sendFeedbackEmail(feedback);
                    // Add any further actions after sending feedback
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Feedback empty!!! Please enter a feedback!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Ok!"),
                            ),
                          ],
                        ));
                  }
                },
                child: Text('Send feedback'))
          ],
        ),
      ),
    );
  }
}