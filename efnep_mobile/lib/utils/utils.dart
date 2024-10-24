import 'package:permission_handler/permission_handler.dart';

/// If the permission is granted, return true. If the permission is not granted, request the permission
/// and return true if the permission is granted. Otherwise, return false
///
/// Args:
///   permission (Permission): The permission to request.
///
/// Returns:
///   A Future<bool>
Future<bool> requestPermission(Permission permission) async {
  if (await permission.isGranted) {
    return true;
  } else {
    var result = await permission.request();
    if (result == PermissionStatus.granted) {
      return true;
    }
  }
  return false;
}
