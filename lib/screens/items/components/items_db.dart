import 'package:firebase_database/firebase_database.dart';
import 'item.dart';

final _dbRef = FirebaseDatabase.instance.reference();

DatabaseReference addItem(Item item) {
  var id = _dbRef.child("items/").push();
  id.set(item.toJson());
  return id;
}

void deleteItem(String id) {
  _dbRef.child("items/").child(id).remove();
}
