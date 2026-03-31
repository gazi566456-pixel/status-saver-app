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
  bool isLoading = true; // متغير للتحكم في واجهة التحميل

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  // ✅ دالة الإذن المصححة والمحسنة
  Future<void> requestPermission() async {
    // طلب الإذن العادي والشامل في نفس الوقت لتغطية كل إصدارات الأندرويد
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.storage,
    ].request();

    bool isGranted = false;

    // التحقق من قبول أي من الإذنين
    if (statuses[Permission.manageExternalStorage]!.isGranted ||
        statuses[Permission.storage]!.isGranted) {
      isGranted = true;
    }

    if (isGranted) {
      loadStatuses();
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("يرجى تفعيل إذن الوصول للملفات من إعدادات الهاتف")),
        );
      }
    }
  }

  // ✅ قراءة الحالات من جميع المسارات الممكنة
  void loadStatuses() {
    // قائمة بجميع مسارات الواتساب الممكنة (العادي والأعمال - القديم والحديث)
    List<String> paths = [
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
      '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
      '/storage/emulated/0/WhatsApp/Media/.Statuses',
      '/storage/emulated/0/WhatsApp Business/Media/.Statuses',
    ];

    List<FileSystemEntity> allFiles = [];

    // البحث في جميع المسارات وجمع الملفات الموجودة
    for (String path in paths) {
      Directory dir = Directory(path);
      if (dir.existsSync()) {
        allFiles.addAll(dir.listSync());
      }
    }

    if (allFiles.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // فلترة الصور
    images = allFiles
        .where((f) =>
            f.path.endsWith('.jpg') ||
            f.path.endsWith('.png') ||
            f.path.endsWith('.jpeg'))
        .map((e) => File(e.path))
        .toList();

    // فلترة الفيديوهات
    videos = allFiles
        .where((f) => f.path.endsWith('.mp4'))
        .map((e) => File(e.path))
        .toList();

    setState(() {
      isLoading = false;
    });
  }

  // ✅ حفظ ملف (تم تغيير المسار لمجلد Download ليكون متوافقاً وأكثر أماناً)
  Future<void> saveFile(File file) async {
    final dir = Directory('/storage/emulated/0/Download/StatusSaver');

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final newPath = '${dir.path}/${file.uri.pathSegments.last}';
    await file.copy(newPath);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم الحفظ في التنزيلات (Download/StatusSaver)")),
      );
    }
  }

  // ✅ مشاركة
  void shareFile(File file) {
    Share.shareXFiles([XFile(file.path)]);
  }

  // ✅ عرض الشبكة
  Widget buildGrid(List<File> files) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (files.isEmpty) {
      return Center(child: Text("لا توجد حالات.. قم بمشاهدة بعض الحالات في الواتساب أولاً"));
    }

    return GridView.builder(
      itemCount: files.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (_, i) {
        final f = files[i];

        return Card(
          margin: EdgeInsets.all(2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              f.path.endsWith('.mp4')
                  ? Container(
                      color: Colors.black87,
                      child: Center(
                        child: Icon(Icons.play_circle_fill,
                            color: Colors.white, size: 50),
                      ),
                    )
                  : Image.file(f, fit: BoxFit.cover),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black54, // خلفية شفافة للأزرار لتكون واضحة
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.download, color: Colors.white),
                        onPressed: () => saveFile(f),
                      ),
                      IconButton(
                        icon: Icon(Icons.share, color: Colors.white),
                        onPressed: () => shareFile(f),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
              onPressed: () {
                setState(() {
                  isLoading = true; // إظهار التحميل عند التحديث
                });
                loadStatuses();
              },
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
