  import 'package:flutter/material.dart';

  // Enhancement 1: Custom splash UI shown while persistent authentication loads.
  class SplashScreen extends StatelessWidget {
    const SplashScreen({super.key, this.message = 'Checking your session...'});

    final String message;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
  }
