
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

CollectionReference userData = FirebaseFirestore.instance.collection("types");
final getUserData = FutureProvider<QuerySnapshot>(
  (ref) => userData.get(),
);
