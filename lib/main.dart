import 'dart:io';
import 'package:flutter/material.dart';
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
  Set<String> saved = {};

  @override
  void initState() {
    super.initState();
    loadStatuses();
  }

  // تحميل الحالات
  void loadStatuses() {
    final dir =
        Directory('/storage/emulated/0/WhatsApp/Media/.Statuses');

    if (!dir.existsSync()) {
      print("المجلد غير موجود");
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

  // حفظ ملف واحد (محسّن)
  Future<void> saveFile(File file) async {
    try {
      final dir = Directory('/storage/emulated/0/MyApp');

      // إنشاء المجلد إذا غير موجود
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      final newPath = '${dir.path}/${file.uri.pathSegments.last}';

      // منع التكرار
      if (File(newPath).existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("محفوظ مسبقاً")),
        );
        return;
      }

      await file.copy(newPath);
      saved.add(file.path);

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم الحفظ")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء الحفظ")),
      );
      print(e);
    }
  }

  // حفظ الكل
  Future<void> saveAll(List<File> files) async {
    for (var f in files) {
      await saveFile(f);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم حفظ الكل")),
    );
  }

  // مشاركة
  void shareFile(File file) {
    Share.shareXFiles([XFile(file.path)]);
  }

  // عرض الشبكة
  Widget buildGrid(List<File> files) {
    if (files.isEmpty) {
      return Center(
        child: Text("لا توجد حالات"),
      );
    }

    return GridView.builder(
      itemCount: files.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, i) {
        final file = files[i];

        return Stack(
          children: [
            Positioned.fill(
              child: file.path.endsWith('.mp4')
                  ? Container(
                      color: Colors.black,
                      child: Center(
                        child: Icon(Icons.play_circle_fill,
                            size: 50, color: Colors.white),
                      ),
                    )
                  : Image.file(file, fit: BoxFit.cover),
            ),

            // علامة الصح
            if (saved.contains(file.path))
              Positioned(
                top: 5,
                right: 5,
                child: Icon(Icons.check,
                    color: Colors.green, size: 28),
              ),

            // الأزرار
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
                    onPressed: () => saveFile(file),
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.share, color: Colors.white),
                    onPressed: () => shareFile(file),
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
              icon: Icon(Icons.download),
              onPressed: () =>
                  saveAll([...images, ...videos]),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: loadStatuses,
            ),
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