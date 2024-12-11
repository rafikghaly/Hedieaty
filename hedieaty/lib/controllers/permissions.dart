import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> requestPermissions(BuildContext context) async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;

    if (androidInfo.version.sdkInt <= 32) {
      // Use storage permission for Android 12 or lower
      if (await Permission.storage.request().isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied.')),
        );
        return false;
      }
    } else {
      // Use photos permission for Android 13 or higher
      if (await Permission.photos.request().isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photos permission denied.')),
        );
        return false;
      }
    }

    return true; // All permissions granted
  }
}
