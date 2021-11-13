import 'package:firebase_database/firebase_database.dart';
import 'category.dart';

final _dbRef = FirebaseDatabase.instance.reference();

DatabaseReference addCategory(Category category) {
  var id = _dbRef.child("categories/").push();
  id.set(category.toJson());
  return id;
}

void deleteCategory(String id) {
  _dbRef.child("categories/").child(id).remove();
}
