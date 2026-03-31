import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(MaterialApp(home: StatusSaver(), debugShowCheckedModeBanner: false));

class StatusSaver extends StatefulWidget {
  @override
  _StatusSaverState createState() => _StatusSaverState();
}

class _StatusSaverState extends State<StatusSaver> {
  List<File> statusFiles = [];

  @override
  void initState() {
    super.initState();
    checkPermissionsAndLoad();
  }

  // ✅ طلب الإذن وفتح الإعدادات إذا لزم الأمر
  void checkPermissionsAndLoad() async {
    var status = await Permission.manageExternalStorage.request();
    
    if (status.isGranted) {
      loadFiles();
    } else {
      // إذا رفض، نفتح له صفحة الإعدادات ليفعله يدوياً لمرة واحدة
      openAppSettings();
    }
  }

  // ✅ جلب الملفات تلقائياً من المسارات المشهورة
  void loadFiles() {
    List<String> paths = [
      "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses",
      "/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses",
      "/storage/emulated/0/WhatsApp/Media/.Statuses",
    ];

    List<File> tempFiles = [];
    for (String path in paths) {
      Directory dir = Directory(path);
      if (dir.existsSync()) {
        tempFiles.addAll(dir.listSync().whereType<File>().toList());
      }
    }

    setState(() {
      statusFiles = tempFiles.where((f) => 
        f.path.endsWith('.jpg') || f.path.endsWith('.mp4') || f.path.endsWith('.png')
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("حفظ الحالات تلقائياً"),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: loadFiles)],
      ),
      body: statusFiles.isEmpty 
        ? Center(child: Text("لا توجد حالات.. تأكد من مشاهدتها في واتساب أولاً"))
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: statusFiles.length,
            itemBuilder: (context, index) {
              File file = statusFiles[index];
              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: file.path.endsWith('.mp4') 
                        ? Container(color: Colors.black, child: Icon(Icons.play_arrow, color: Colors.white))
                        : Image.file(file, fit: BoxFit.cover, width: double.infinity),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(icon: Icon(Icons.download), onPressed: () => save(file)),
                        IconButton(icon: Icon(Icons.share), onPressed: () => Share.shareXFiles([XFile(file.path)])),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
    );
  }

  void save(File file) async {
    final downloadDir = Directory('/storage/emulated/0/Download/MyStatuses');
    if (!downloadDir.existsSync()) downloadDir.createSync();
    await file.copy("${downloadDir.path}/${file.uri.pathSegments.last}");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم الحفظ في التنزيلات")));
  }
}
