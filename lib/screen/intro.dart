import 'package:flutter/material.dart';

class IntroHome extends StatelessWidget {
  const IntroHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text("intro"),
          )
        ],
      ),
    );
  }
}
