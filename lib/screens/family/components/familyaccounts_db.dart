import 'package:firebase_database/firebase_database.dart';
import 'familyaccount.dart';

final _dbRef = FirebaseDatabase.instance.reference();

DatabaseReference addFamilyAccount(FamilyAccount facc) {
  var id = _dbRef.child("family-accounts/").push();
  id.set(facc.toJson());
  return id;
}

void updateFamilyAcount(String id, FamilyAccount facc) {
  _dbRef.child("family-accounts/").child(id).update(facc.toJson());
}

void deleteFamilyAccount(String id) {
  _dbRef.child("family-accounts/").child(id).remove();
}
