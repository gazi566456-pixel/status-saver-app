import 'package:file_picker/file_picker.dart';

Future<String?> pickFolder() async {
  return await FilePicker.platform.getDirectoryPath();
}
