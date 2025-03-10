import 'package:flutter/material.dart';

class ErrorUnkown extends StatelessWidget {
  const ErrorUnkown({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                color: Colors.grey,
                size: 100.0,
              ),
              SizedBox(height: 20.0),
              Text(
                '404',
                style: TextStyle(
                  fontSize: 60.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Page Not Found',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20.0),
              Divider(
                color: Colors.grey,
                thickness: 2.0,
                indent: 50.0,
                endIndent: 50.0,
              ),
              SizedBox(height: 20.0),
              Text(
                'The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      );
  }
}