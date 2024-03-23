import 'dart:convert';

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
      var imageBase64 = base64Encode(image);
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
}
