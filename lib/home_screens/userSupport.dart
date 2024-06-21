import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupportScreen extends StatefulWidget {
  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('supportMessages').add({
      'name': _nameController.text,
      'email': _emailController.text,
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _emailController.clear();
    _messageController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message Sent'),
          content: Text('Your message has been sent successfully. Support team will contact you soon.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: Theme.of(context).primaryColor,
  //       title: Text('Support'),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         children: [
  //           TextField(
  //             cursorColor: Theme.of(context).primaryColor,
  //             controller: _nameController,
  //             decoration: InputDecoration(
  //               labelText: 'Name',
  //               border: OutlineInputBorder(),
  //               labelStyle: TextStyle(color: Theme.of(context).primaryColor),
  //               focusedBorder: OutlineInputBorder(
  //                 borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
  //               ),
  //               enabledBorder: OutlineInputBorder(
  //                 borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
  //               ),
  //             ),
  //           ),
  //           SizedBox(height: 10),
  //           TextField(
  //             cursorColor: Theme.of(context).primaryColor,
  //             controller: _emailController,
  //             decoration: InputDecoration(
  //               labelText: 'Email',
  //               border: OutlineInputBorder(),
  //               labelStyle: TextStyle(color: Theme.of(context).primaryColor),
  //               focusedBorder: OutlineInputBorder(
  //                 borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
  //               ),
  //               enabledBorder: OutlineInputBorder(
  //                 borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
  //               ),
  //             ),
  //
  //             keyboardType: TextInputType.emailAddress,
  //           ),
  //           SizedBox(height: 10),
  //           TextField(
  //             cursorColor: Theme.of(context).primaryColor,
  //             controller: _messageController,
  //             decoration: InputDecoration(
  //               labelText: 'Message',
  //               labelStyle: TextStyle(color: Theme.of(context).primaryColor),
  //               border: OutlineInputBorder(
  //                 borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
  //
  //               ),
  //               focusedBorder: OutlineInputBorder(
  //                 borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
  //               ),
  //               enabledBorder: OutlineInputBorder(
  //                 borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
  //               ),
  //             ),
  //             maxLines: 4,
  //           ),
  //           SizedBox(height: 20),
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor,),
  //             onPressed: _sendMessage,
  //             child: Text('Submit'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Support', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Text(
                  'Send us a message about any feedback, errors, or problems you are experiencing. We are here to help!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.5, // line height for better readability
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                cursorColor: Theme.of(context).primaryColor,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'Montserrat'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                cursorColor: Theme.of(context).primaryColor,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Your Email',
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'Montserrat'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              TextField(
                cursorColor: Theme.of(context).primaryColor,
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Message',
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'Montserrat'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.message, color: Theme.of(context).primaryColor),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 20),
              // Center(
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       foregroundColor: Theme.of(context).primaryColor,
              //       padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(30),
              //       ),
              //       elevation: 5,
              //     ),
              //     onPressed: _sendMessage,
              //     child: Text('Submit', style: TextStyle(fontSize: 16, fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
              //   ),
              // ),


        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              backgroundColor: Colors.greenAccent, // Transparent to show gradient
              shadowColor: Colors.greenAccent.withOpacity(0.5),
            ),
            onPressed: _sendMessage,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )


            ],
          ),
        ),
      ),
    );
  }


}
