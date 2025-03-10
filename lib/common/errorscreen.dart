
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 100.0,
              ),
              SizedBox(height: 20.0),
              Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Error in showing details",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20.0),
              Divider(
                color: Colors.redAccent,
                thickness: 2.0,
                indent: 50.0,
                endIndent: 50.0,
              ),
            ],
          ),
        ),
      );
  }
}