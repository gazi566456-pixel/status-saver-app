import 'package:flutter/material.dart';
import '../services/picker_service.dart';
import 'home_screen.dart';

class PickerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("اختر مجلد الحالات")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            String? path = await pickFolder();
            if (path != null) {
              Navigator.push(context,
                MaterialPageRoute(builder: (_) => HomeScreen(path: path)));
            }
          },
          child: Text("اختيار المجلد"),
        ),
      ),
    );
  }
}
