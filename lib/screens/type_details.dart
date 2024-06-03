import 'package:crops/models/crop.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:transparent_image/transparent_image.dart';

class TypesDetails extends StatelessWidget {
  const TypesDetails({
    super.key,
    required this.crop,
  });

  final Crops crop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          crop.title,
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 26, 115, 44),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(15), // Adjust the radius as needed
              child: FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: NetworkImage(
                  crop.image,
                ),
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'What is ${crop.title}?',
              style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 26, 115, 44)),
            ),
            const SizedBox(height: 8),
            Text(
              crop.identify,
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'Georgia',
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Symptoms:',
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 26, 115, 44),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              crop.symptoms,
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'Georgia',
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Treatment:',
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 26, 115, 44),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              crop.treatment,
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'Georgia',
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
