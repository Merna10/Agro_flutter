import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/core/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userStreamProvider = StreamProvider.family<Users?, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        return Users(
          username: data['username'],
          email: data['email'],
          userImage: data['userImage'],
        );
      } else {
        return null; // Missing data in snapshot
      }
    } else {
      return null; // User not found
    }
  }).handleError((error) {
    print('Error fetching lolol data: $error');
    // Return a stream with a single null event in case of error
    return Stream.value(null);
  });
});
