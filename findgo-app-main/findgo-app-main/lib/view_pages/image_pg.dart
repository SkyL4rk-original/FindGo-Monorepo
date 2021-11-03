import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vrouter/vrouter.dart';

class ImagePage extends StatelessWidget {
  final String imageUrl;
  const ImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            PhotoView(
              imageProvider: CachedNetworkImageProvider(imageUrl),
            ),
            IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  context.vRouter.to("/", isReplacement: true);
                }
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white,),
            ),
          ],
        ),
      ),
    );
  }
}
