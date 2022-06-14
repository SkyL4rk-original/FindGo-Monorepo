import 'dart:html' as html;
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:findgo_admin/core/constants.dart';
import 'package:flutter/material.dart';

class ImageCropper extends StatefulWidget {
  final Uint8List image;

  const ImageCropper({Key? key, required this.image}) : super(key: key);

  @override
  _ImageCropperState createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  final controller = CropController();
  bool cropping = false;
  late html.Worker worker;

  @override
  void initState() {
    final blob = html.Blob(
      ["onmessage = self.postMessage('msg from worker')"],
      '{ type: "text/javascript" }',
    );
    worker = html.Worker(html.Url.createObjectUrlFromBlob(blob));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // void cropImage(String string) {
    //   controller.crop();
    // }
    return SizedBox(
      height: 400,
      child: AlertDialog(
        title: const Text("Crop Image"),
        content: SizedBox(
          width: 250.0,
          height: 200.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Crop(
                image: widget.image,
                controller: controller,
                aspectRatio: 5 / 4,
                cornerDotBuilder: (size, cornerIndex) =>
                    const DotControl(color: kColorAccent),
                onCropped: (image) => Navigator.of(context).pop(image),
              ),
              if (cropping)
                Container(
                  width: 250,
                  height: 200,
                  color: Colors.black87.withOpacity(0.9),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Processing... may take a while",
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8.0),
                      const CircularProgressIndicator(),
                    ],
                  ),
                )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              cropping = true;
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 300));

              final blob = html.Blob(
                ["onmessage = self.postMessage('msg from worker')"],
                '{ type: "text/javascript" }',
              );
              worker = html.Worker(html.Url.createObjectUrlFromBlob(blob));
              worker.onMessage.listen((event) {
                // print("main:receive: ${event.data}");
                controller.crop();
              });
              // worker.postMessage("start");

              // controller.crop();
            },
            // onPressed: () async => Executor().execute(arg1: "done", fun1: cropImage),
            child: const Text("Crop"),
          ),
        ],
      ),
    );
  }
}


// class ImageCropper extends StatelessWidget {
//   final Uint8List image;
//
//   const ImageCropper({Key? key, required this.image}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final _controller = CropController();
//     final GlobalKey<ExtendedImageEditorState> _editorKey = GlobalKey<ExtendedImageEditorState>();
//
//     // late final Isolate isolate;
//     // late final ReceivePort receivePort;
//
//     return SizedBox(
//       height: 400,
//       child: AlertDialog(
//         title: const Text("Crop Image"),
//         content: SizedBox(
//           width: 250.0,
//           height: 200.0,
//           // child: Crop(
//           //     image: image,
//           //     controller: _controller,
//           //     aspectRatio: 5 / 4,
//           //     cornerDotBuilder: (size, cornerIndex) => const DotControl(color: kColorAccent),
//           //     onCropped: (image) {
//           //       Navigator.of(context).pop(image);
//           //     }
//           // ),
//
//           child: ExtendedImage.memory(
//             image,
//             fit: BoxFit.contain,
//             mode: ExtendedImageMode.editor,
//             extendedImageEditorKey: _editorKey,
//             initEditorConfigHandler: (state) {
//               return EditorConfig(
//                   maxScale: 8.0,
//                   cropRectPadding: EdgeInsets.all(20.0),
//                   hitTestSize: 20.0,
//                   cropAspectRatio: 5/4
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () async => Navigator.of(context).pop(),
//               child: const Text("Cancel")
//           ),
//           TextButton(
//               onPressed: () {
//                 print('Pressed');
//
//                 void _cropImage() {
//                   final Rect? cropRect = _editorKey.currentState!.getCropRect();
//                   final data = _editorKey.currentState!.rawImageData;
//
//                   img.Image? src = img.decodeImage(data);
//
//                   src = img.bakeOrientation(src!);
//
//                   src = img.copyCrop(src, cropRect!.left.toInt(), cropRect.top.toInt(),
//                       cropRect.width.toInt(), cropRect.height.toInt());
//
//                   // final img.Image src = await img.isolateDecodeImage(data) as img.Image;
//                   // final lb = await loadBalancer;
//                   // img.Image src = await lb.run<Image, List<int>>(decodeImage, data);
//
//
//                   final im = src.getBytes(format: img.Format.abgr);
//
//                   // sendPort.send("Cropped");
//                   Navigator.of(context).pop(im);
//                 }
//
//
//                 // final blob = html.Blob(["onmessage = self.postMessage('msg from worker')"], '{ type: "text/javascript" }');
//                 //
//                 // final worker = html.Worker(html.Url.createObjectUrlFromBlob(blob));
//                 // worker.onMessage.listen((event) {
//                 //   print("main:receive: ${event.data}");
//                 //   print("Cropping");
//                 //   _cropImage();
//                 // });
//                 // worker.postMessage("start");
//
//
//                 // receivePort = ReceivePort();
//                 // try {
//                 //   isolate = await Isolate.spawn(_cropImage, receivePort.sendPort);
//                 //   print("Isolate: $isolate");
//                 //   receivePort.listen((dynamic message) {
//                 //     print('New message from Isolate: $message');
//                 //   });
//                 //
//                 // } catch (e) {
//                 //   print("Error: $e");
//                 // }
//
//
//               },
//               child: const Text("Crop")
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }
