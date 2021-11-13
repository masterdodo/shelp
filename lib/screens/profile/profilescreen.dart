import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelp/authentication_service.dart';
import 'package:shelp/components/bottomnavbar.dart';
import 'package:shelp/screens/family/components/familyaccount.dart';
import 'package:shelp/screens/family/components/familyaccounts_db.dart';
import 'package:shelp/screens/family/components/familyrequests_db.dart';
import 'package:shelp/screens/items/components/categories_db.dart';
import 'package:shelp/screens/items/components/items_db.dart';
import 'package:shelp/screens/items/components/stores_db.dart';
import 'package:shelp/screens/login/loginscreen.dart';
import 'package:shelp/screens/profile/components/profiles_db.dart';
import 'components/profile.dart';

enum GenderType { male, female }

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var profileInfo;
  String profileId;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = new TextEditingController();
  TextEditingController ageController = new TextEditingController();
  TextEditingController genderController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  GenderType _genderType = GenderType.male;
  String errText = "";

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      FirebaseDatabase.instance
          .reference()
          .child("profiles/")
          .orderByChild("userId")
          .equalTo(firebaseUser.uid)
          .once()
          .then((snap) {
        setState(() {
          snap.value?.forEach((k, v) {
            profileId = k;
            profileInfo = v;
          });
        });
      });

      return Scaffold(
        backgroundColor: Color(0xff9FA8DA),
        body: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Profile",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    RaisedButton(
                      color: Color(0xffe36954),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: () {
                        context.read<AuthenticationService>().signOut();
                      },
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        child: const Text('Sign Out',
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Image(
                  image: AssetImage('img/pp.png'),
                  height: 80,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(primary: Colors.black),
                      icon: Icon(Icons.edit),
                      label: Text("Edit"),
                      onPressed: switchEditing,
                    ),
                  ],
                ),
              ),
              Visibility(
                  visible: !_isEditing,
                  child: ((profileInfo != null)
                      ? (Column(
                          children: [
                            Text(
                              "Email",
                              style: labelStyle(),
                            ),
                            Text(
                              firebaseUser.email,
                              style: valuesStyle(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                "Full name",
                                style: labelStyle(),
                              ),
                            ),
                            Text(
                              (profileInfo["fullName"] == "")
                                  ? "NaN"
                                  : profileInfo["fullName"],
                              style: valuesStyle(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                "Age",
                                style: labelStyle(),
                              ),
                            ),
                            Text(
                              (profileInfo["age"] == "")
                                  ? "NaN"
                                  : profileInfo["age"],
                              style: valuesStyle(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                "Gender",
                                style: labelStyle(),
                              ),
                            ),
                            Text(
                              (profileInfo["gender"] == "")
                                  ? "NaN"
                                  : profileInfo["gender"],
                              style: valuesStyle(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                "Phone number",
                                style: labelStyle(),
                              ),
                            ),
                            Text(
                              (profileInfo["phoneNumber"] == "")
                                  ? "NaN"
                                  : profileInfo["phoneNumber"],
                              style: valuesStyle(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: RaisedButton(
                                color: Colors.red[700],
                                textColor: Colors.white,
                                onPressed: () {
                                  FlatButton confirmDeletion = FlatButton(
                                    child: Text("Confirm"),
                                    onPressed: () {
                                      context
                                          .read<AuthenticationService>()
                                          .signIn(
                                              email: firebaseUser.email,
                                              password: passwordController.text
                                                  .trim())
                                          .then((value) {
                                        if (value == "Signed In!") {
                                          String userId = firebaseUser.uid;
                                          //remove items
                                          FirebaseDatabase.instance
                                              .reference()
                                              .child("items/")
                                              .orderByChild("userId")
                                              .equalTo(userId)
                                              .once()
                                              .then((el) =>
                                                  el.value?.forEach((k, v) {
                                                    deleteItem(k);
                                                  }));
                                          //remove stores
                                          FirebaseDatabase.instance
                                              .reference()
                                              .child("stores/")
                                              .orderByChild("userId")
                                              .equalTo(userId)
                                              .once()
                                              .then((el) =>
                                                  el.value?.forEach((k, v) {
                                                    deleteStore(k);
                                                  }));
                                          //remove categories
                                          FirebaseDatabase.instance
                                              .reference()
                                              .child("categories/")
                                              .orderByChild("userId")
                                              .equalTo(userId)
                                              .once()
                                              .then((el) =>
                                                  el.value?.forEach((k, v) {
                                                    deleteCategory(k);
                                                  }));
                                          //remove profile
                                          var family = "NaN";
                                          FirebaseDatabase.instance
                                              .reference()
                                              .child("profiles/")
                                              .orderByChild("userId")
                                              .equalTo(userId)
                                              .once()
                                              .then((el) =>
                                                  el.value?.forEach((k, v) {
                                                    print(v["family"]);
                                                    family = v["family"];
                                                    deleteProfile(k);
                                                  }));
                                          //remove family connections
                                          List<String> famAccUsers = [];
                                          if (family != "" && family != "NaN") {
                                            FirebaseDatabase.instance
                                                .reference()
                                                .child("family-accounts/")
                                                .child(family)
                                                .once()
                                                .then((el) =>
                                                    el.value?.forEach((k, v) {
                                                      famAccUsers =
                                                          List<String>.from(
                                                              v["users"]);
                                                      if (famAccUsers.length >
                                                          2) {
                                                        famAccUsers
                                                            .remove(userId);
                                                        updateFamilyAcount(
                                                            k,
                                                            FamilyAccount(
                                                                famAccUsers));
                                                      } else {
                                                        famAccUsers?.forEach(
                                                            (element) {
                                                          if (element !=
                                                              userId) {
                                                            FirebaseDatabase
                                                                .instance
                                                                .reference()
                                                                .child(
                                                                    "profiles")
                                                                .orderByChild(
                                                                    "userId")
                                                                .equalTo(
                                                                    element)
                                                                .once()
                                                                .then((snap) {
                                                              snap.value
                                                                  ?.forEach(
                                                                      (k, v) {
                                                                v["family"] =
                                                                    "";
                                                                updateProfile(
                                                                    k, v);
                                                              });
                                                            });
                                                          }
                                                        });
                                                        deleteFamilyAccount(
                                                            family);
                                                      }
                                                    }));
                                            print("abc");
                                            FirebaseDatabase.instance
                                                .reference()
                                                .child("family-requests/")
                                                .once()
                                                .then((element) {
                                              print("abb");
                                              element.value?.forEach((k, v) {
                                                if (v["senderId"] == userId ||
                                                    v["recieverId"] == userId) {
                                                  deleteFamilyRequest(k);
                                                }
                                              });
                                            });
                                          }
                                          firebaseUser.delete();
                                          Navigator.of(context).pop();
                                        } else {
                                          setState(() {
                                            errText = value;
                                          });
                                        }
                                      }).catchError((e) {
                                        print(e);
                                      });
                                    },
                                  );
                                  FlatButton cancel = FlatButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  );

                                  showDialog(
                                      context: context,
                                      child: StatefulBuilder(
                                          builder: (context, setState) {
                                        return AlertDialog(
                                          title: Text("Are you sure?"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  "Confirm password to delete your account!"),
                                              Text(errText),
                                              TextField(
                                                obscureText: true,
                                                controller: passwordController,
                                                decoration: InputDecoration(
                                                    labelText: "Password"),
                                              )
                                            ],
                                          ),
                                          actions: [confirmDeletion, cancel],
                                        );
                                      }));
                                },
                                child: Text("Delete account"),
                              ),
                            )
                          ],
                        ))
                      : Container())),
              Visibility(
                visible: _isEditing,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: "Full name"),
                          autocorrect: false,
                          controller: fullNameController,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: "Age"),
                          autocorrect: false,
                          controller: ageController,
                        ),
                        ListTile(
                          title: Text("male"),
                          leading: Radio(
                            value: GenderType.male,
                            groupValue: _genderType,
                            onChanged: (GenderType val) {
                              setState(() {
                                _genderType = val;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text("female"),
                          leading: Radio(
                            value: GenderType.female,
                            groupValue: _genderType,
                            onChanged: (GenderType val) {
                              setState(() {
                                _genderType = val;
                              });
                            },
                          ),
                        ),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: "Phone number"),
                          autocorrect: false,
                          controller: phoneNumberController,
                        ),
                        RaisedButton(
                          color: Color(0xcc71e067),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0)),
                          onPressed: () {
                            print(profileId);
                            updateProfile(
                                profileId,
                                Profile(
                                    profileInfo["userId"],
                                    firebaseUser.email,
                                    fullNameController.text,
                                    (_genderType.index == 0)
                                        ? "male"
                                        : "female",
                                    ageController.text,
                                    phoneNumberController.text));
                            switchEditing();
                          },
                          child: Text("Save"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
              BottomNavBar()
            ],
          ),
        ),
      );
    }
    return LoginScreen();
  }

  TextStyle valuesStyle() {
    return TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w300,
    );
  }

  TextStyle labelStyle() {
    return TextStyle(
        fontSize: 20, color: Color(0xff555555), fontWeight: FontWeight.bold);
  }

  void switchEditing() {
    setState(() {
      _isEditing = !_isEditing;
      fullNameController.text = profileInfo["fullName"];
      ageController.text = profileInfo["age"];
      genderController.text = profileInfo["gender"];
      phoneNumberController.text = profileInfo["phoneNumber"];
    });
  }
}
