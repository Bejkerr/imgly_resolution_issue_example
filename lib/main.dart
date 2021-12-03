import 'dart:io';

import 'package:flutter/material.dart';
import 'package:imgly_sdk/imgly_sdk.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Configuration createConfiguration() {
    final emoticons = StickerCategory.existing("imgly_sticker_category_emoticons");
    final shapes = StickerCategory.existing("imgly_sticker_category_shapes",
        items: [Sticker.existing("imgly_sticker_shapes_badge_01"), Sticker.existing("imgly_sticker_shapes_arrow_02")]);
    var categories = <StickerCategory>[emoticons, shapes];
    final configuration = Configuration(sticker: StickerOptions(personalStickers: true, categories: categories));
    return configuration;
  }

  Future<File> openEditor(String path) async {
    final result = await VESDK.openEditor(Video(path), configuration: createConfiguration());
    print(result?.toJson());
    return File(result!.video);
  }

  VideoPlayerController controller = VideoPlayerController.asset('assets/example720p.mp4');
  String currentResolution = '';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('VideoEditor example'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () async {
                  controller = VideoPlayerController.asset('assets/example720p.mp4');
                  await controller.initialize();
                  setState(() {
                    currentResolution = controller.value.size.toString();
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.red,
                  height: 64,
                  child: Text('Load video 720x1280'),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  controller = VideoPlayerController.asset('assets/example1080p.mp4');
                  await controller.initialize();
                  setState(() {
                    currentResolution = controller.value.size.toString();
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.blue,
                  height: 64,
                  child: Text('Load video 1080x1920'),
                ),
              ),
              if (controller.value.isInitialized)
                Column(
                  children: [
                    Container(
                      height: 128,
                      alignment: Alignment.center,
                      child: Text(
                        "Current loaded video resolution\n$currentResolution",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await controller.dispose();
                        print(controller.dataSource);
                        final result = await openEditor(controller.dataSource);
                        controller = VideoPlayerController.file(result);
                        await controller.initialize();
                        setState(() {
                          currentResolution = controller.value.size.toString();
                        });
                      },
                      child: Container(
                        height: 64,
                        color: Colors.green,
                        child: Center(child: Text('Open Imgly')),
                      ),
                    )
                  ],
                ),
            ],
          )),
    );
  }
}
