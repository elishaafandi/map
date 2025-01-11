import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addUser({
  required String username,
  required String email,
  required String password,
  required String name,
  required String matricNo,
  required String course,
  required String phoneNo,
  required String address,
}) async {
  try {
    // Reference to Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the userCounter document
    DocumentReference counterRef =
        firestore.collection('metadata').doc('userCounter');

    // Use a transaction to ensure atomicity
    int newId = await firestore.runTransaction((transaction) async {
      // Get the current value of lastId
      DocumentSnapshot snapshot = await transaction.get(counterRef);

      if (!snapshot.exists) {
        // Initialize if it doesn't exist
        transaction.set(counterRef, {'lastId': 0});
        return 0;
      }

      int lastId = snapshot['lastId'] as int;
      int incrementedId = lastId + 1;

      // Update the lastId with the new value
      transaction.update(counterRef, {'lastId': incrementedId});

      return incrementedId;
    });

    // Add the user to the collection
    CollectionReference users = firestore.collection('users');
    await users.add({
      'userId': newId, // Auto-incremented user ID
      'username': username,
      'email': email,
      'password': password, // Avoid storing plain-text passwords in production
      'name': name,
      'matricNo': matricNo,
      'course': course,
      'phoneNo': phoneNo,
      'address': address,
    });

    print('User added successfully with ID $newId!');
  } catch (e) {
    print('Failed to add user: $e');
  }
}
