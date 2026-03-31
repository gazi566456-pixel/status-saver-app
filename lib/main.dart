import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: StatusPage(),
    );
  }
}

class StatusPage extends StatefulWidget {
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<File> files = [];

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  Future<void> requestPermission() async {
    await Permission.photos.request();
    await Permission.videos.request();
  }

  // 🔥 اختيار مجلد الحالات يدوي (يشتغل بكل الإصدارات)
  Future<void> pickFolder() async {
    String? path = await FilePicker.platform.getDirectoryPath();

    if (path == null) return;

    final dir = Directory(path);

    final all = dir.listSync();

    files = all
        .where((f) =>
            f.path.endsWith('.jpg') ||
            f.path.endsWith('.png') ||
            f.path.endsWith('.mp4'))
        .map((e) => File(e.path))
        .toList();

    setState(() {});
  }

  void shareFile(File file) {
    Share.shareXFiles([XFile(file.path)]);
  }

  Widget buildGrid() {
    if (files.isEmpty) {
      return Center(child: Text("اضغط زر المجلد واختر مجلد الحالات"));
    }

    return GridView.builder(
      itemCount: files.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (_, i) {
        final f = files[i];

        return Stack(
          children: [
            Positioned.fill(
              child: f.path.endsWith('.mp4')
                  ? Container(
                      color: Colors.black,
                      child: Center(
                          child: Icon(Icons.play_circle_fill,
                              size: 50, color: Colors.white)),
                    )
                  : Image.file(f, fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () => shareFile(f),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Status Saver Pro"),
        actions: [
          IconButton(
            icon: Icon(Icons.folder),
            onPressed: pickFolder, // 🔥 أهم زر
          )
        ],
      ),
      body: buildGrid(),
    );
  }
}
