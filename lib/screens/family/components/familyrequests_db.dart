import 'package:firebase_database/firebase_database.dart';
import 'familyrequest.dart';

final _dbRef = FirebaseDatabase.instance.reference();

DatabaseReference addFamilyRequest(FamilyRequest freq) {
  var id = _dbRef.child("family-requests/").push();
  id.set(freq.toJson());
  return id;
}

void deleteFamilyRequest(String id) {
  _dbRef.child("family-requests/").child(id).remove();
}
