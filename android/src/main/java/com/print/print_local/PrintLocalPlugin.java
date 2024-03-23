package com.print.print_local;


import android.pt.printer.Printer;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * PrintLocalPlugin
 */
public class PrintLocalPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    Printer printer;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "print_local");
        channel.setMethodCallHandler(this);
        printer = new Printer();
        printer.open();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        if (call.method.equals("isPrintNative")) {
            int valueReturn = check_printer();
            result.success(valueReturn);
        } else if (call.method.equals("printNative")) {
            int valueReturn = check_printer();
            String message = "unknown error channel";
            try {
                String imageBase64 = call.argument("imageBase64");
                if (imageBase64 != null && valueReturn == 0) {
                    Bitmap bmp_bk = base64ToBitmap(imageBase64);
                    valueReturn = printer.printPicture(bmp_bk, bmp_bk.getWidth(), bmp_bk.getHeight());
                    if (valueReturn == 0) {
                        valueReturn = 6; //6: success print
                        message = "success";
                    }
                }
            } catch (Exception e) {
                message = e.toString();
                valueReturn = 5;
            }
            Map<String, Object> resultMap = new HashMap<>();
            resultMap.put("value", valueReturn);
            resultMap.put("message", message);
            result.success(resultMap);
        } else {
            result.notImplemented();
        }
    }

    public static Bitmap base64ToBitmap(String base64String) {
        byte[] decodedBytes = Base64.decode(base64String, Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.length);
    }

    private int check_printer() {
        //0: ready for print
        //1: No paper
        //2: Hot printer
        //3: Hot printer or not paper
        //4: time out
        //5: Unknown error
        //6: success print
        int status = printer.queState();
        if (status == -2) {
            return 4;
        } else {
            return status;
        }
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        printer.close();
    }
}
