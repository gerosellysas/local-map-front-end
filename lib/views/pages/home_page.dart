import 'package:flutter/material.dart';
import 'package:local_map_front_end/navigations/navigation.dart';
import 'package:local_map_front_end/views/widgets/custom_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              buttonText: "Download Map",
              onPressed: () {
                Navigation.goToMapDownloader();
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              buttonText: "View Map",
              onPressed: () {
                Navigation.goToMapViewer();
              },
            ),
          ],
        ),
      ),
    );
  }
}
