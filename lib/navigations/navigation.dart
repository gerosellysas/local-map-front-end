import 'package:get/route_manager.dart';
import 'package:local_map_front_end/views/pages/map_downloader.dart';
import 'package:local_map_front_end/views/pages/map_viewer.dart';

class Navigation {
  static Future<void> goToMapDownloader() async {
    Get.to(() => const MapDownloader());
  }

  static Future<void> goToMapViewer() async {
    Get.to(() => const MapViewer());
  }
}
