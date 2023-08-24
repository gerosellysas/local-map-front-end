import 'dart:io';

import "package:dio/dio.dart" as dio;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MapDownloaderController extends GetxController {
  final dio.Dio _dio = dio.Dio();
  static final url = dotenv.env['MAP_URL']!;
  var downloadUrl = "".obs;
  var x = "".obs;
  var y = "".obs;
  var totalX = 0.obs;
  var totalY = 0.obs;
  var totalDownloaded = "0".obs;
  var totalFiles = "0".obs;
  var isDownloading = false.obs;
  var progress = 0.0.obs;
  var isXYZfolder = true.obs;

  TextEditingController zController = TextEditingController();
  TextEditingController xStartController = TextEditingController();
  TextEditingController xEndController = TextEditingController();
  TextEditingController yStartController = TextEditingController();
  TextEditingController yEndController = TextEditingController();
  FocusNode zFocusNode = FocusNode();
  FocusNode xStartFocusNode = FocusNode();
  FocusNode xEndFocusNode = FocusNode();
  FocusNode yStartFocusNode = FocusNode();
  FocusNode yEndFocusNode = FocusNode();

  var xFolders = <String>[].obs;
  var yFiles = <String>[].obs;
  var downloadedFiles = <String>[].obs;
  var downloadedLoadings = <bool>[].obs;
  ScrollController scrollController = ScrollController();

  Future<void> _showDialog(String title, String body) async {
    await Get.defaultDialog(
      radius: 7.5,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      title: title,
      middleText: body,
      barrierDismissible: false,
      buttonColor: Colors.blue,
      cancel: const SizedBox(),
      confirmTextColor: Colors.white,
      textConfirm: "OK",
      onConfirm: () {
        Get.back();
      },
    );
  }

  String get getLastDownloadFile {
    if (downloadedFiles.isEmpty) {
      return "-";
    }
    return downloadedFiles.last;
  }

  Future<List<String>> _getXFolders() async {
    if (xStartController.text.isEmpty && xEndController.text.isEmpty) {
      return xFolders;
    }
    int xStart = int.parse(xStartController.text);
    int xEnd = int.parse(xEndController.text);
    if (xStart > xEnd) {
      _showDialog(
        "Error X Range Input",
        "X Start value should be less than X End value.",
      );
      return xFolders;
    }
    xFolders.clear();
    for (var i = xStart; i <= xEnd; i++) {
      String xFolder = i.toString();
      xFolders.add(xFolder);
    }
    // print(xFolders);
    return xFolders;
  }

  Future<List<String>> _getYFiles() async {
    if (yStartController.text.isEmpty && yEndController.text.isEmpty) {
      return yFiles;
    }
    int yStart = int.parse(yStartController.text);
    int yEnd = int.parse(yEndController.text);
    if (yStart > yEnd) {
      _showDialog(
        "Error Y Range Input",
        "Y Start value should be less than Y End value.",
      );
      return yFiles;
    }
    yFiles.clear();
    for (var i = yStart; i <= yEnd; i++) {
      String yFile = i.toString();
      yFiles.add(yFile);
    }
    // print(yFiles);
    return yFiles;
  }

  Future<bool> _requestPermission(Permission permission) async {
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

  Future<List<String>> _saveFile(Directory dir) async {
    for (var i = 0; i < yFiles.length; i++) {
      y.value = yFiles[i];
      downloadUrl.value = "${zController.text}/${x.value}/${y.value}.png";
      downloadedFiles.add(downloadUrl.value);
      downloadedLoadings.add(true);
      // print(downloadedFiles);
      // print(downloadedLoadings);
      if (!await dir.exists()) {
        // print(">>>>> CREATE DIRECTORY !!!");
        await dir.create(recursive: true);
      }
      if (await dir.exists()) {
        File? saveFile;
        if (isXYZfolder.value) {
          //! Save file with Y value name and store them per X folder
          saveFile = File("${dir.path}/$y.png");
        } else {
          //! Save file with specific XYZ name format and store them all inside Z folder
          saveFile = File(
              "${dir.path}/tile_${zController.text}_${x.value}_${y.value}.png");
        }
        try {
          await _dio.download(
            url + downloadUrl.value,
            saveFile.path,
            onReceiveProgress: (value1, value2) {
              progress.value = (value1 / value2) * 100;
              // print(progress.value);
            },
          );
          if (progress.value == 100.0) {
            for (var iLoading = 0;
                iLoading < downloadedLoadings.length;
                iLoading++) {
              downloadedLoadings[iLoading] = false;
            }
            totalDownloaded.value =
                await _formatTotal(downloadedFiles.length.toString());
            await Future.delayed(const Duration(microseconds: 500));
          }
        } on dio.DioException catch (e) {
          _showDialog(
            "Error Download File",
            "Download zoom: ${zController.text}, folder: ${x.value}, file: ${y.value} is failed!.\nError code : ${e.message}\nindex: $i",
          );
        }
      }
    }
    return downloadedFiles;
  }

  Future<bool> _createDirectory() async {
    Directory directory;
    isDownloading.value = true;
    downloadedFiles.clear();
    downloadedLoadings.clear();
    try {
      if (await _requestPermission(Permission.manageExternalStorage)) {
        for (var xFolder in xFolders) {
          directory = (await getExternalStorageDirectory())!;
          String newPath = "";
          // print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/$folder";
            } else {
              break;
            }
          }
          x.value = xFolder;
          if (isXYZfolder.value) {
            //! Create Z folder with X folders inside, saved files will be divided per X Folder
            newPath = "$newPath/Local Map/${zController.text}/${x.value}";
          } else {
            //! Create Z folder, all saved files will be stored inside it without making X folders
            newPath = "$newPath/Local Map/${zController.text}";
          }
          directory = Directory(newPath);
          // print(directory);
          await _saveFile(directory);
        }
        return true;
      } else {
        return false;
      }
    } on FileSystemException catch (e) {
      _showDialog(
        "Error File System",
        "Cannot create folder: ${x.value} from zoom: ${zController.text}.\nError code : ${e.message}",
      );
    }
    return false;
  }

  Future<void> startXYZFolderDownload() async {
    isXYZfolder.value = true;
    _startDownload();
  }

  Future<void> startTilesDownload() async {
    isXYZfolder.value = false;
    _startDownload();
  }

  Future<void> _startDownload() async {
    if (zController.text.isEmpty ||
        xStartController.text.isEmpty ||
        xEndController.text.isEmpty ||
        yStartController.text.isEmpty ||
        yEndController.text.isEmpty) {
      _showDialog(
          "Error Text Field Input", "Please fill all fields before download.");
      return;
    }
    if (isDownloading.value) return;
    await _getXFolders();
    if (xFolders.isEmpty) return;
    await _getYFiles();
    if (yFiles.isEmpty) return;
    await _getDownloadInfo();
    var done = await _createDirectory();
    if (!done) return;
    await Future.delayed(const Duration(milliseconds: 750));
    isDownloading.value = false;
    _showDialog("Information", "Downloading has done !!!");
  }

  Future<void> getNextFocusNode(FocusNode focusNode) async {
    if (zController.text.isEmpty ||
        xStartController.text.isEmpty ||
        xEndController.text.isEmpty ||
        yStartController.text.isEmpty ||
        yEndController.text.isEmpty) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
      _showDialog(
        "Information",
        "Select download method from one of the available buttons.",
      );
    }
  }

  Future<void> onSubmitted() async {
    if (zController.text.isEmpty ||
        xStartController.text.isEmpty ||
        xEndController.text.isEmpty ||
        yStartController.text.isEmpty ||
        yEndController.text.isEmpty) {
      _showDialog(
          "Error Text Field Input", "Please fill all fields before download.");
    } else {
      _showDialog(
        "Information",
        "Select download method from one of the available buttons.",
      );
    }
  }

  Future<void> _getDownloadInfo() async {
    if (xFolders.isEmpty || yFiles.isEmpty) return;
    totalX.value = int.parse(xFolders.last) - int.parse(xFolders.first);
    totalY.value = int.parse(yFiles.last) - int.parse(yFiles.first);
    if (totalX.value == 0) {
      totalX.value = 1;
    } else {
      totalX = totalX + 1;
    }
    if (totalY.value == 0) {
      totalY.value = 1;
    } else {
      totalY.value = totalY.value + 1;
    }
    totalFiles.value =
        await _formatTotal((totalX.value * totalY.value).toString());
  }

  Future<String> _formatTotal(String total) async {
    String totalStr = total;
    String totalInText = "";
    int counter = 0;
    for (int i = (totalStr.length - 1); i >= 0; i--) {
      counter++;
      String str = totalStr[i];
      if ((counter % 3) != 0 && i != 0) {
        totalInText = "$str$totalInText";
      } else if (i == 0) {
        totalInText = "$str$totalInText";
      } else {
        totalInText = ",$str$totalInText";
      }
    }
    return totalInText.trim();
  }
}
