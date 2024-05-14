import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewer({super.key,required this.imageUrls, required this.initialIndex});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.imageUrls.length,
          controller: PageController(initialPage: widget.initialIndex),
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: widget.imageUrls[index],
              fit: BoxFit.contain,
            );
          },
        ),
        Positioned(
          top: 40,
          left: 0,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < widget.imageUrls.length; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == i ? Colors.blue : Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
