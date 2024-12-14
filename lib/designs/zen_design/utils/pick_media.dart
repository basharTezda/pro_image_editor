import 'package:image_picker/image_picker.dart';
//Picking media faster
Future<List<String>> pickMediaForEditor() async {
  List<String> imagesPath = [];
  final List<XFile> images = await ImagePicker().pickMultipleMedia(
    requestFullMetadata: false,
    maxHeight: 1920,
    maxWidth: 1080,
  );

  for (var i in images) {
    imagesPath.add(i.path);
  }

  return imagesPath;
}
