import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.storage,
    Permission.photos,
    Permission.mediaLibrary,
    Permission.notification,
    Permission.videos
  ].request();

  // Handle the result
  statuses.forEach((permission, status) {
    if (status.isGranted) {
      debugPrint('${permission.toString()} is granted');
    } else if (status.isDenied) {
      debugPrint('${permission.toString()} is denied');
    } else if (status.isPermanentlyDenied) {
      debugPrint('${permission.toString()} is permanently denied');
      // Open app settings to let the user enable the permission
      openAppSettings();
    }
  });
}
