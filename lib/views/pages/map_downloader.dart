import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:local_map_front_end/controllers/map_downloader_controller.dart';
import 'package:local_map_front_end/views/widgets/custom_button.dart';
import 'package:local_map_front_end/views/widgets/custom_textfield.dart';

class MapDownloader extends StatefulWidget {
  const MapDownloader({super.key});

  @override
  State<MapDownloader> createState() => _MapDownloaderState();
}

class _MapDownloaderState extends State<MapDownloader> {
  final MapDownloaderController _downloaderController =
      Get.put(MapDownloaderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Map Downloader"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextField(
            controller: _downloaderController.zController,
            focusNode: _downloaderController.zFocusNode,
            maxLength: 2,
            labelText: "Zoom",
            onSubmitted: () {
              _downloaderController
                  .getNextFocusNode(_downloaderController.xStartFocusNode);
            },
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _downloaderController.xStartController,
                focusNode: _downloaderController.xStartFocusNode,
                maxLength: 6,
                labelText: "X Start",
                onSubmitted: () {
                  _downloaderController
                      .getNextFocusNode(_downloaderController.xEndFocusNode);
                },
              ),
              const SizedBox(width: 50),
              CustomTextField(
                controller: _downloaderController.xEndController,
                focusNode: _downloaderController.xEndFocusNode,
                maxLength: 6,
                labelText: "X End",
                onSubmitted: () {
                  _downloaderController
                      .getNextFocusNode(_downloaderController.yStartFocusNode);
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _downloaderController.yStartController,
                focusNode: _downloaderController.yStartFocusNode,
                maxLength: 6,
                labelText: "Y Start",
                onSubmitted: () {
                  _downloaderController
                      .getNextFocusNode(_downloaderController.yEndFocusNode);
                },
              ),
              const SizedBox(width: 50),
              CustomTextField(
                controller: _downloaderController.yEndController,
                focusNode: _downloaderController.yEndFocusNode,
                maxLength: 6,
                labelText: "Y End",
                onSubmitted: () {
                  _downloaderController.onSubmitted();
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          CustomButton(
            width: 300,
            buttonText: "Download With XYZ Folder Format",
            onPressed: () {
              _downloaderController.startXYZFolderDownload();
            },
          ),
          const SizedBox(height: 10),
          CustomButton(
            width: 300,
            buttonText: "Download All Tiles In One Folder",
            onPressed: () {
              _downloaderController.startTilesDownload();
            },
          ),
          const SizedBox(height: 10),
          Obx(() => Text(
                "Downloaded files : ${_downloaderController.totalDownloaded.value} / ${_downloaderController.totalFiles.value}",
                style: const TextStyle(color: Colors.white),
              )),
          const SizedBox(height: 10),
          Obx(() => Text(
                "Last downloaded files : ${_downloaderController.getLastDownloadFile}",
                style: const TextStyle(color: Colors.white),
              )),
          const SizedBox(height: 20),
          Container(
            height: 350,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 1,
                color: Colors.grey.shade400,
              ),
            ),
            child: RawScrollbar(
              controller: _downloaderController.scrollController,
              thumbVisibility: true,
              thumbColor: Colors.grey.shade400,
              interactive: false,
              radius: const Radius.circular(5),
              child: Obx(() => ListView.builder(
                    controller: _downloaderController.scrollController,
                    itemCount: _downloaderController.downloadedFiles.length,
                    itemBuilder: (context, index) {
                      var length = _downloaderController.downloadedFiles.length;
                      var reverseIndex = length - 1 - index;
                      if (_downloaderController.downloadedFiles.isEmpty) {
                        return const SizedBox();
                      }
                      return Obx(() => _downloaderController
                              .downloadedLoadings[reverseIndex]
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Obx(() => LinearProgressIndicator(
                                    minHeight: 5,
                                    value: _downloaderController.progress.value,
                                    backgroundColor: (reverseIndex % 2 == 0)
                                        ? Colors.green.shade300
                                        : Colors.blue.shade300,
                                    valueColor: (reverseIndex % 2 == 0)
                                        ? const AlwaysStoppedAnimation<Color>(
                                            Colors.green)
                                        : const AlwaysStoppedAnimation<Color>(
                                            Colors.blue),
                                  )),
                            )
                          : Container(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "${_downloaderController.downloadedFiles[reverseIndex]}     =====>     downloaded successfully ...",
                                style: TextStyle(
                                    color: (reverseIndex % 2 == 0)
                                        ? Colors.green
                                        : Colors.blue),
                              ),
                            ));
                    },
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
