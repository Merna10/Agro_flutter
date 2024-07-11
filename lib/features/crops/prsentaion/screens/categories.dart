import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/app/routes/routes.dart';
import 'package:crops/features/crops/data/model/crop.dart';
import 'package:crops/features/crops/prsentaion/providers/types_provider.dart';
import 'package:crops/features/crops/prsentaion/screens/type_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CropsCategoryItem extends ConsumerWidget {
  const CropsCategoryItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<QuerySnapshot> categoriesDataAsync =
        ref.watch(getGategoriesData);

    return Center(
      child: Scaffold(
        body: categoriesDataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (snapshot) {
            final data = snapshot.docs;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                var doc = data[index];
                var docId = doc.id;
                var title = (doc.data() as Map<String, dynamic>)['title'];
                var identify = (doc.data() as Map<String, dynamic>)['identify'];
                var symptoms = (doc.data() as Map<String, dynamic>)['symptoms'];
                var image = (doc.data() as Map<String, dynamic>)['image'];
                var treatment =
                    (doc.data() as Map<String, dynamic>)['treatment'];

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      navigateToDetailsScreen(context, docId, title, identify,
                          symptoms, image, treatment);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(
                            image,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            color: const Color.fromARGB(255, 94, 87, 87)
                                .withOpacity(0.6),
                            child: Text(
                              "$title",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void navigateToDetailsScreen(
    BuildContext context,
    String docId,
    String title,
    String identify,
    String symptoms,
    String image,
    String treatment,
  ) {
    FirebaseFirestore.instance
        .collection('types')
        .doc(docId)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        var crop = Crops(
            id: docId,
            title: title,
            identify: identify,
            symptoms: symptoms,
            image: image,
            treatment: treatment);

         Navigator.pushNamed(
        context,
        Routes.cropDetails,
        arguments: {'crop': crop},
      );
      }
    }).catchError((error) {});
  }
}
