import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

Future<String> downScale(
  String path,
) async {
  final directory = await getTemporaryDirectory();
  final outputPath =
      '${directory.path}/scaled_image${DateTime.now().toIso8601String()}.webp';
  final image = img.decodeImage(File(path).readAsBytesSync());
  final thumbnail = img.copyResize(image!, height: 300);
  File(outputPath).writeAsBytesSync(img.encodePng(thumbnail));

  return outputPath;
}

Future<String> compressImageWithFfmpeg(
    String path, BuildContext context) async {
  bool compressedWithFfmpeg = false;
  final directory = await getTemporaryDirectory();
  final outputPath =
      '${directory.path}/compressed_image${DateTime.now().toIso8601String()}.webp';

  final scale = await resizeImage(path);
  final resizeCommand = scale != null
      ? '-i $path -vf \"$scale\" -c:v libwebp -qscale:v 90 -preset photo -compression_level 4 $outputPath'
      : '-i $path -c:v libwebp -qscale:v 90 -preset photo -compression_level 4 $outputPath';

  try {
    await FFmpegKit.execute(resizeCommand).then(
      (session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          log(scale.toString(), name: 'scale');
          log('Image compressed with FFmpeg');
          final size = await getFileSize(outputPath, 2);
          log('${size[0]}  ${size[1]}');
          compressedWithFfmpeg = true;
        } else if (ReturnCode.isCancel(returnCode)) {
          compressedWithFfmpeg = false;
        } else {
          compressedWithFfmpeg = false;
        }
      },
    );
  } catch (e) {
    compressedWithFfmpeg = false;
  }

  if (compressedWithFfmpeg) {
    return outputPath;
  }
  log('Image not compressed with Flutter Image Compress');

  return path;
}

Future<String> compressImage(String path, BuildContext context) async {
  return path;
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

    return {
      'width': newImage.width,
      'height': newImage.height,
    };
  } catch (e) {
    return null;
  }
}

Future<String?> resizeImage(String path) async {
  final dimensions = await getImageDimensions(path);
  final width = dimensions!['width']!;
  final height = dimensions['height']!;
  log('$width  $height', name: 'scale');
  if (width < height) {
    if (width > 1080) {
      return 'scale=1080:-1';
    }
    return null;
  } else if (width > height) {
    if (height > 1080) {
      return 'scale=-1:1080';
    }
    return null;
  } else {
    if (width > 1080) {
      return 'scale=1080:1080';
    }
    return null;
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
