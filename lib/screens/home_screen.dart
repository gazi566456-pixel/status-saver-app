import 'package:flutter/material.dart';
import 'dart:io';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final String path;
  HomeScreen({required this.path});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<File> files = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    files = await loadStatuses(widget.path);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الحالات")),
      body: GridView.builder(
        itemCount: files.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          final file = files[index];
          return Image.file(file, fit: BoxFit.cover);
        },
      ),
    );
  }
}
