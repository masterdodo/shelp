import 'package:firebase_database/firebase_database.dart';
import 'store.dart';

final _dbRef = FirebaseDatabase.instance.reference();

DatabaseReference addStore(Store store) {
  var id = _dbRef.child("stores/").push();
  id.set(store.toJson());
  return id;
}

void deleteStore(String id) {
  _dbRef.child("stores/").child(id).remove();
}
