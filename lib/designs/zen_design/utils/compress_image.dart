import 'dart:async';
import 'dart:developer';
// import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

Future<String> compressImage(String path, BuildContext context) async {
  bool compressedWithFfmpeg = false;
  final directory = await getTemporaryDirectory();
  final outputPath =
      '${directory.path}/compressed_image${DateTime.now().toIso8601String()}.webp';
  // final webpPath =
  //     '${directory.path}/compressed_image${DateTime.now().toIso8601String()}.webp';
  final scale = await resizeImage(path);
  final resizeCommand = scale != null
      ? '-i $path -vf \"$scale\" -c:v libwebp -qscale:v 90 -preset photo -compression_level 4 $outputPath'
      : '-i $path -c:v libwebp -qscale:v 90 -preset photo -compression_level 4 $outputPath';

  // final command =
  //     '-i $path -vf $scale -qscale:v 90 -compression_level 4 $outputPath';
//-preset photo / -qscale:v 90
  // try {
  //   await FFmpegKit.execute(resizeCommand).then(
  //     (session) async {
  //       // session.
  //       final returnCode = await session.getReturnCode();
  //       // session.

  //       if (ReturnCode.isSuccess(returnCode)) {
  //         // await Future.delayed(Duration(seconds: 1)).then((onValue) {
  //         // log("done", name: "bashardinho");
  //         compressedWithFfmpeg = true;
  //         // });
  //       } else if (ReturnCode.isCancel(returnCode)) {
  //         compressedWithFfmpeg = false;
  //         // CANCEL
  //         // log("CANCEL", name: "bashardinho");
  //       } else {
  //         // log("ERROR", name: "bashardinho");
  //         compressedWithFfmpeg = false;

  //         // ERROR
  //       }
  //     },
  //   );
  // } catch (e) {
  //   // log(e.toString(), name: "bashardinho");
  //   compressedWithFfmpeg = false;
  //   // log(e.toString());
  // }
  // WidgetsBinding.instance.addPostFrameCallback((_) async {
  //   await Future.delayed(Duration.zero).then((onValue) async {
  //     // File file = File(webpPath);

  //   });
  // });

  // file.writeAsBytesSync(result, flush: true);

  // if (compressedWithFfmpeg) {
  //   // file.writeAsBytesSync(File(outputPath).readAsBytesSync());
  //   // log(await getFileSize(outputPath, 1), name: "bashardinho");
  //   // log("image there", name: "bashardinho");
  //   return outputPath;
  // }
  // log("image not there", name: "bashardinho");
  var result = await FlutterImageCompress.compressAndGetFile(
    format: CompressFormat.webp,
    path,outputPath,
    minHeight: 1920,
    minWidth: 1080,
    quality: 90,
  );
  // File(outputPath).writeAsBytesSync(result);
  final dataSize = await getFileSize(path, 1);
  final dataSizeAfterCompress = await getFileSize(outputPath, 1);
  log(dataSize[0].toString() + " " + dataSize[1].toString(),
      name: "bashardinho");
  log(
      dataSizeAfterCompress[0].toString() +
          " " +
          dataSizeAfterCompress[1].toString(),
      name: "bashardinho");
  return result!.path;
}

Future<Map<String, int>?> getImageDimensions(String path) async {
  try {
    Image image = path[0] == '/' ? Image.file(File(path)) : Image.network(path);

    final Completer<ui.Image> completer = Completer<ui.Image>();
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );
    final newImage = await completer.future;

    // Determine the image orientation
    return {
      'width': newImage.width,
      'height': newImage.height,
    };
  } catch (e) {
    return null;
  }
  // return ;
}

Future<String?> resizeImage(String path) async {
  final dimensions = await getImageDimensions(path);
  final width = dimensions!['width']!;
  final height = dimensions['height']!;

  if (width < height) {
    // Portrait
    if (width > 1080) {
      return 'scale=1080:-1'; // Reduce width to 1080, maintain aspect ratio
    } else {
      return null; // No scaling needed
    }
  } else if (width > height) {
    // Landscape
    if (height > 1080) {
      return 'scale=-1:1080'; // Reduce height to 1080, maintain aspect ratio
    } else {
      return null; // No scaling needed
    }
  } else {
    // Square
    if (width > 1080) {
      return 'scale=1080:1080'; // Reduce to 1080x1080
    } else {
      return null; // No scaling needed
    }
  }
}

Future<List> getFileSize(String filepath, int decimals) async {
  var file = File(filepath);
  int bytes = await file.length();
  if (bytes <= 0) return [0, 'B'];
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  var i = (math.log(bytes) / math.log(1024)).floor();
  return [((bytes / math.pow(1024, i)).toStringAsFixed(decimals)), suffixes[i]];
}
