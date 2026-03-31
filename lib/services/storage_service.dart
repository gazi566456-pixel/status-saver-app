import 'dart:io';

Future<List<File>> loadStatuses(String path) async {
  final dir = Directory(path);

  return dir.listSync().whereType<File>().where((file) {
    return file.path.endsWith(".jpg") ||
           file.path.endsWith(".png") ||
           file.path.endsWith(".mp4");
  }).toList();
}
