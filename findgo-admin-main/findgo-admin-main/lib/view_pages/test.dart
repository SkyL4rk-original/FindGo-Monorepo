import 'dart:typed_data';

import 'package:findgo_admin/widgets/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

// class _TestState extends State<Test> {
//
//   Future<void> _showAlert() async {
//     bool popped = false;
//     showDialog(context: context, builder: (ctx) => AlertDialog(
//       title : Text("Title"),
//       content: Text("Content"),
//       actions: [
//         TextButton(
//             onPressed: () async {
//               popped = true;
//               Navigator.of(context).pop();
//             },
//             child: const Text("Close")
//         ),
//       ],
//     ));
//
//     await Future.delayed(const Duration(seconds: 2));
//     if (!popped) Navigator.of(context).pop();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async => _showAlert(),
//           child: const Text("Show"),
//         ),
//       ),
//     );
//   }
// }

class _TestState extends State<Test> {
  final _picker = ImagePicker();
  Uint8List? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            if (_image != null)
              Container(
                width: 250.0,
                height: 200.0,
                color: Colors.black,
                child: Image.memory(
                  _image!,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 20.0),
            // if (_image != null && !_cropped) SizedBox(
            //   width: 250.0,
            //   height: 200.0,
            //   child: Crop(
            //       image: _image!,
            //       controller: _controller,
            //       aspectRatio: 5 / 4,
            //       cornerDotBuilder: (size, cornerIndex) => const DotControl(color: kColorAccent),
            //       onCropped: (image) {
            //         _image = image;
            //         _cropped = true;
            //         setState(() {});
            //       }
            //   ),
            // ),
            const SizedBox(height: 20.0),
            TextButton.icon(
              onPressed: () async {
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  // print(pickedFile.path);
                  final file = await pickedFile.readAsBytes();

                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      content: SizedBox(
                        height: 250.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Preparing... may take a while",
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 16.0),
                            const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                  );

                  await Future.delayed(const Duration(seconds: 1));
                  _image = await showDialog(
                    context: context,
                    builder: (ctx) => ImageCropper(image: file),
                  );
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  setState(() {});
                } else {
                  print('No image selected.');
                }
              },
              icon: const Icon(
                Icons.image_outlined,
                color: Colors.white,
              ),
              label: _image == null
                  ? const Text(
                      "Add Image (max 3MB)",
                      style: TextStyle(color: Colors.white),
                    )
                  : const Text(
                      "Update Image (max 3MB)",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            // if (!_cropped) TextButton(
            //     onPressed: () async {
            //      _controller.crop();
            //     },
            //     child: const Text("Crop", style: TextStyle(color: Colors.white),)
            // ),
          ],
        ),
      ),
    );
  }
}
