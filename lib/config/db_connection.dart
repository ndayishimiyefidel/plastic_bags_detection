import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class DB{
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

// Read data from the database
  void readData() {
    _databaseReference.child('your_node_name').once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        // Handle the retrieved data
        print(snapshot.value);
      }
    } as FutureOr Function(DatabaseEvent value));
  }

// Write data to the database
  void writeData() {
    _databaseReference.child('your_node_name').set('your_data');
  }

// Update data in the database
  void updateData() {
    _databaseReference.child('your_node_name').update({'key': 'new_value'});
  }

// Delete data from the database
  void deleteData() {
    _databaseReference.child('your_node_name').remove();
  }

}