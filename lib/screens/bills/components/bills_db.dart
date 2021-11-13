import 'package:firebase_database/firebase_database.dart';
import 'bill.dart';

final _dbRef = FirebaseDatabase.instance.reference();

DatabaseReference addBill(Bill bill) {
  var id = _dbRef.child("bills/").push();
  id.set(bill.toJson());
  return id;
}

void deleteBill(String id) {
  _dbRef.child("bills/").child(id).remove();
}
