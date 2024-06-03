import 'package:crops/widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int index;

  const ImageGrid({super.key, required this.imageUrls, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imageUrls.isNotEmpty)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageViewer(
                    imageUrls: imageUrls,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: imageUrls.length == 1
                ? Container(
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(
                      imageUrls.first,
                      fit: BoxFit.cover,
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: imageUrls.length > 2 ? 2 : imageUrls.length,
                    itemBuilder: (context, index) {
                      return FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: imageUrls[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
          ),
        if (imageUrls.length > 2)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageViewer(
                    imageUrls: imageUrls,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '+${imageUrls.length - 2}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
