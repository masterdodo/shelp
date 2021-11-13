import 'package:firebase_database/firebase_database.dart';
import 'profile.dart';

final _dbRef = FirebaseDatabase.instance.reference();

DatabaseReference addProfile(Profile user) {
  var id = _dbRef.child("profiles/").push();
  id.set(user.toJson());
  return id;
}

void updateProfile(String id, Profile user) {
  print(id);
  print(user.toJson());
  _dbRef.child("profiles/").child(id).update(user.toJson());
}

void deleteProfile(String id) {
  _dbRef.child("profiles/").child(id).remove();
}
