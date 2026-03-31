import 'package:flutter/material.dart';
import 'picker_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B6B5C),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download, size: 100, color: Colors.green),
          SizedBox(height: 20),
          Text("موفر الحالة", style: TextStyle(color: Colors.white, fontSize: 24)),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PickerScreen()));
              },
              child: Text("لنبدأ"),
            ),
          )
        ],
      ),
    );
  }
}
