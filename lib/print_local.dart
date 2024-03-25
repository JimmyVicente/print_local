import 'dart:convert';

import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:print_local/model.dart';

class PrintLocal {
  final methodChannel = const MethodChannel('print_local');

  Future<PrintResult> isPrintNative() async {
    var value = 5;
    try {
      var val = await methodChannel.invokeMethod<int?>('isPrintNative');
      value = val ?? 5;
    } catch (err) {
      value = 5;
    }
    return getResultPrintFromCode(value);
  }

  Future<ObjectPrintResult> printNative(Uint8List image) async {
    var message = "unknown error flutter";
    var valueR = ObjectPrintResult(PrintResult.unknownError, message, -10);
    try {
      var size = await getSizeImage(image);
      size = getResizedSize(size, 380); //380 width
      var imageAux = await renderSizeIcon(
        image,
        size.width.toInt(),
        size.height.toInt(),
      );
      var imageBase64 = base64Encode(imageAux);
      final data = await methodChannel.invokeMethod('printNative', {
        'imageBase64': imageBase64,
      });
      if (data is Map) {
        var value = data["value"];
        var result = getResultPrintFromCode(value);
        message = data["message"] ?? message;
        valueR = ObjectPrintResult(result, message, value);
      }
    } catch (err) {
      valueR = ObjectPrintResult(PrintResult.unknownError, err.toString(), -10);
    }
    return valueR;
  }

  Future<Uint8List?> renderSizeIcon(Uint8List imageBytes,
      int targetWidth,
      int targetHeight) async {
    final ui.Codec markerImageCodec = await ui.instantiateImageCodec(imageBytes,
        targetWidth: targetWidth, targetHeight: targetHeight);
    final ui.FrameInfo frameInfo = await markerImageCodec.getNextFrame();
    final ByteData? byteData =
    await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? resizedMarkerImageBytes = byteData?.buffer.asUint8List();
    return resizedMarkerImageBytes;
  }

  Size getResizedSize(Size originalSize, double targetWidth) {
    double targetHeight =
        (originalSize.height * targetWidth) / originalSize.width;
    return Size(targetWidth, targetHeight);
  }

  Future<Size> getSizeImage(Uint8List imageData) async {
    ui.Codec codec = await ui.instantiateImageCodec(imageData);
    ui.FrameInfo f = await codec.getNextFrame();
    Size size = Size(f.image.width.toDouble(), f.image.height.toDouble());
    return size;
  }

}
