import 'package:image_picker/image_picker.dart';

//Picking media faster
Future<List<String>> pickMediaForEditor({bool oneImage = false}) async {
  List<String> imagesPath = [];
  List<XFile> images = [];
  if (!oneImage) {
    images = await ImagePicker().pickMultipleMedia(
      requestFullMetadata: false,
      maxHeight: 1920,
      maxWidth: 1080,
    );
  } else {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
      maxHeight: 1920,
      maxWidth: 1080,
    );
    if (image != null) {
      images.add(image);
    }
  }

  for (var i in images) {
    imagesPath.add(i.path);
  }

  return imagesPath;
}
