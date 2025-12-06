import 'package:flutter/material.dart';
import 'package:hotel_reservation_demo/models/database_service.dart';
import 'login_screen.dart';

class InactivityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 350, minWidth: 250),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 7,
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 36),
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_clock, size: 50, color: Colors.deepOrange),
                  SizedBox(height: 24),
                  Text(
                    "You have been logged out for inactivity.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: Colors.deepOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => LoginScreen()), (_) => false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Back to Login"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
