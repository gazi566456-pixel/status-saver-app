import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

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
  List<File> images = [];
  List<File> videos = [];

  @override
  void initState() {
    super.initState();
    requestPermission(); // ✅ تم التأكد
  }

  // ✅ دالة الإذن (المصححة)
  Future<void> requestPermission() async {
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }

    if (!await Permission.manageExternalStorage.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى تفعيل إذن الوصول لجميع الملفات")),
      );
      return;
    }

    loadStatuses();
  }

  // ✅ قراءة الحالات تلقائي
  void loadStatuses() {
    Directory dir = Directory(
        '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');

    // دعم واتساب بزنس
    if (!dir.existsSync()) {
      dir = Directory(
          '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses');
    }

    if (!dir.existsSync()) {
      setState(() {});
      return;
    }

    final files = dir.listSync();

    images = files
        .where((f) =>
            f.path.endsWith('.jpg') ||
            f.path.endsWith('.png') ||
            f.path.endsWith('.jpeg'))
        .map((e) => File(e.path))
        .toList();

    videos = files
        .where((f) => f.path.endsWith('.mp4'))
        .map((e) => File(e.path))
        .toList();

    setState(() {});
  }

  // حفظ ملف
  Future<void> saveFile(File file) async {
    final dir = Directory('/storage/emulated/0/MyApp');

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final newPath = '${dir.path}/${file.uri.pathSegments.last}';
    await file.copy(newPath);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم الحفظ")),
    );
  }

  // مشاركة
  void shareFile(File file) {
    Share.shareXFiles([XFile(file.path)]);
  }

  // عرض الشبكة
  Widget buildGrid(List<File> files) {
    if (files.isEmpty) {
      return Center(child: Text("لا توجد حالات"));
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
                            color: Colors.white, size: 50),
                      ),
                    )
                  : Image.file(f, fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 5,
              left: 5,
              right: 5,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.download,
                        color: Colors.white),
                    onPressed: () => saveFile(f),
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.share, color: Colors.white),
                    onPressed: () => shareFile(f),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Status Saver"),
          bottom: TabBar(
            tabs: [
              Tab(text: "صور"),
              Tab(text: "فيديو"),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: loadStatuses,
            )
          ],
        ),
        body: TabBarView(
          children: [
            buildGrid(images),
            buildGrid(videos),
          ],
        ),
      ),
    );
  }
}
