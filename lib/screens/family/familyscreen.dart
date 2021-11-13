import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelp/components/bottomnavbar.dart';
import 'package:shelp/screens/family/components/familyaccount.dart';
import 'package:shelp/screens/family/components/familyrequest.dart';
import 'package:shelp/screens/family/components/familyrequests_db.dart';
import 'package:shelp/screens/login/loginscreen.dart';
import 'package:shelp/screens/profile/components/profile.dart';
import 'package:shelp/screens/profile/components/profiles_db.dart';
import 'components/familyaccounts_db.dart';

class FamilyScreen extends StatefulWidget {
  @override
  _FamilyScreenState createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  String email = "";

  @override
  Widget build(BuildContext context) {
    email = "";
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return Scaffold(
        floatingActionButton: addButton(firebaseUser),
        backgroundColor: Color(0xffef9a9a),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 70, left: 20, right: 20, bottom: 20),
              child: Row(
                children: [
                  Text(
                    "Family Account",
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: StreamBuilder(
                stream: FirebaseDatabase.instance
                    .reference()
                    .child("profiles")
                    .orderByChild("userId")
                    .equalTo(firebaseUser.uid)
                    .onValue,
                builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.snapshot.value != null) {
                      Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                      String familyId = map.values.toList()[0]["family"];
                      //If user IS NOT in a family account
                      if (familyId == "") {
                        return StreamBuilder(
                          stream: FirebaseDatabase.instance.reference().onValue,
                          builder: (BuildContext context,
                                  AsyncSnapshot<Event> snapshot) =>
                              requestsBuilder(context, snapshot, firebaseUser),
                        );
                      } //If user IS in a family account
                      else {
                        return StreamBuilder(
                          stream: FirebaseDatabase.instance.reference().onValue,
                          builder: (BuildContext context,
                                  AsyncSnapshot<Event> snapshot) =>
                              accountBuilder(
                                  context, snapshot, firebaseUser, familyId),
                        );
                      }
                    }
                  }
                  return Container();
                },
              ),
            ),
            Spacer(),
            BottomNavBar()
          ],
        ),
      );
    }
    return LoginScreen();
  }

  Padding addButton(User firebaseUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 45, right: 5),
      child: FloatingActionButton(
        backgroundColor: Color(0xffb34240),
        child: Icon(Icons.add),
        onPressed: () => addRequestMethod(firebaseUser),
      ),
    );
  }

  Future<dynamic> addRequestMethod(User firebaseUser) {
    TextEditingController emailController = new TextEditingController();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Make a Request",
                      style: TextStyle(fontSize: 25, color: Color(0xffa34c49)),
                    ),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Color(0xffa34c49)),
                          focusColor: Color(0xffa34c49)),
                    ),
                    RaisedButton(
                      color: Color(0xffbd716f),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0)),
                      onPressed: () {
                        if (emailController.text.isNotEmpty &&
                            emailController.text != firebaseUser.email) {
                          FirebaseDatabase.instance
                              .reference()
                              .child("profiles")
                              .orderByChild("email")
                              .equalTo(emailController.text)
                              .once()
                              .then((snap) {
                            if (snap.value != null) {
                              String recieverId = "";
                              snap.value.forEach((k, v) {
                                recieverId = v["userId"];
                              });
                              if ((!outgoingRequests.any(
                                      (e) => e.recieverId == recieverId)) &&
                                  (!incomingRequests
                                      .any((e) => e.senderId == recieverId))) {
                                addFamilyRequest(FamilyRequest(
                                    firebaseUser.uid, recieverId));
                              }
                              Navigator.of(context).pop();
                            }
                          });
                        }
                      },
                      child: Text("Add"),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  List incomingRequests = [];
  List outgoingRequests = [];
  List profiles = [];
  Widget requestsBuilder(
      BuildContext context, AsyncSnapshot snapshot, User firebaseUser) {
    incomingRequests = [];
    outgoingRequests = [];
    profiles = [];
    if (snapshot.hasData) {
      if (snapshot.data.snapshot.value != null) {
        Map<dynamic, dynamic> map1 = snapshot.data.snapshot.value;

        map1["family-requests"]?.forEach((k, v) {
          if (v["senderId"] == firebaseUser.uid) {
            outgoingRequests
                .add(FamilyRequest.withId(k, v["senderId"], v["recieverId"]));
          }
        });
        map1["family-requests"]?.forEach((k, v) {
          if (v["recieverId"] == firebaseUser.uid) {
            incomingRequests
                .add(FamilyRequest.withId(k, v["senderId"], v["recieverId"]));
          }
        });
        map1["profiles"]?.forEach((k, v) => profiles.add(Profile.complete(
            k,
            v["userId"],
            v["email"],
            v["family"],
            v["fullName"],
            v["gender"],
            v["age"],
            v["phoneNumber"])));

        return Column(
          children: [
            Text("Incoming requests:"),
            Flexible(
              fit: FlexFit.tight,
              child: ListView.builder(
                  itemCount: incomingRequests.length,
                  itemBuilder: (BuildContext context, int index) =>
                      incomingRequestTile(context, index)),
            ),
            Text("Outgoing requests:"),
            Flexible(
              fit: FlexFit.tight,
              child: ListView.builder(
                  itemCount: outgoingRequests.length,
                  itemBuilder: outgoingRequestTile),
            ),
          ],
        );
      } else {
        return Text(
          "No incoming or outgoing requests.",
          style: TextStyle(fontSize: 18),
        );
      }
    }
    return Container();
  }

  Widget incomingRequestTile(BuildContext context, int index) {
    return (profiles.firstWhere(
                (v) => (incomingRequests[index].senderId == v.id),
                orElse: () => null) !=
            null)
        ? (Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  profiles
                      .firstWhere(
                          (v) => (incomingRequests[index].senderId == v.id))
                      .email,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                ),
                IconButton(
                  color: Colors.green,
                  icon: Icon(
                    Icons.check_box,
                  ),
                  onPressed: () {
                    var senderProfile = profiles.firstWhere(
                        (v) => (incomingRequests[index].senderId == v.id));
                    var recieverProfile = profiles.firstWhere(
                        (v) => (incomingRequests[index].recieverId == v.id));

                    if (senderProfile.family == "") {
                      var a = addFamilyAccount(FamilyAccount([
                        incomingRequests[index].senderId,
                        incomingRequests[index].recieverId
                      ]));

                      senderProfile.family = a.key;
                      recieverProfile.family = a.key;

                      updateProfile(senderProfile.pid, senderProfile);
                      updateProfile(recieverProfile.pid, recieverProfile);

                      deleteFamilyRequest(incomingRequests[index].id);
                    } else {
                      List<String> usrs = [];
                      FirebaseDatabase.instance
                          .reference()
                          .child("family-accounts/")
                          .child(senderProfile.family)
                          .once()
                          .then((el) {
                        el.value.forEach((key, val) {
                          usrs = List<String>.from(val);
                          usrs.add(incomingRequests[index].recieverId);
                          updateFamilyAcount(
                              senderProfile.family, FamilyAccount(usrs));
                        });
                      });
                      recieverProfile.family = senderProfile.family;
                      updateProfile(recieverProfile.pid, recieverProfile);
                      deleteFamilyRequest(incomingRequests[index].id);
                    }
                  },
                ),
                IconButton(
                  color: Colors.red,
                  icon: Icon(Icons.cancel),
                  onPressed: () =>
                      deleteFamilyRequest(incomingRequests[index].id),
                )
              ],
            ),
          ))
        : (Container());
  }

  Widget outgoingRequestTile(BuildContext context, int index) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            profiles
                .firstWhere((v) => (outgoingRequests[index].recieverId == v.id))
                .email,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          ),
          IconButton(
            color: Colors.red,
            icon: Icon(Icons.cancel),
            onPressed: () => deleteFamilyRequest(outgoingRequests[index].id),
          )
        ],
      ),
    );
  }

  List<String> famAcc = [];

  Widget accountBuilder(BuildContext context, AsyncSnapshot snapshot,
      User firebaseUser, String familyId) {
    if (snapshot.hasData) {
      if (snapshot.data.snapshot.value != null) {
        Map<dynamic, dynamic> map2 = snapshot.data.snapshot.value;

        profiles = [];
        famAcc = [];

        map2["family-accounts"]?.forEach((k, v) {
          if (k == familyId) {
            famAcc = List<String>.from(v["users"]);
          }
        });

        map2["profiles"]?.forEach((k, v) {
          if (famAcc.contains(v["userId"])) {
            profiles.add(Profile.complete(
                k,
                v["userId"],
                v["email"],
                v["family"],
                v["fullName"],
                v["gender"],
                v["age"],
                v["phoneNumber"]));
          }
        });

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Members:",
                  style: TextStyle(fontSize: 20),
                ),
                TextButton.icon(
                  label: Text("Leave Group"),
                  icon: Icon(Icons.person_remove),
                  onPressed: () => leaveGroup(firebaseUser, familyId),
                )
              ],
            ),
            Flexible(
              fit: FlexFit.tight,
              child: ListView.builder(
                itemCount: profiles.length,
                itemBuilder: memberTileBuilder,
              ),
            )
          ],
        );
      }
    }
    return Container();
  }

  void leaveGroup(User firebaseUser, String familyId) {
    FlatButton sure = FlatButton(
      child: Text("Sure"),
      onPressed: () {
        var userProfile =
            profiles.firstWhere((el) => el.id == firebaseUser.uid);
        //Remove from family account users
        famAcc.remove(userProfile.id);
        updateFamilyAcount(familyId, FamilyAccount(famAcc));
        //Remove family from user
        userProfile.family = "";
        updateProfile(userProfile.pid, userProfile);
        if (famAcc.length == 1) {
          userProfile = profiles.firstWhere((el) => el.id != firebaseUser.uid);
          //Remove from family account users
          famAcc.remove(userProfile.id);
          deleteFamilyAccount(familyId);
          //Remove family from user
          userProfile.family = "";
          updateProfile(userProfile.pid, userProfile);
        }
        Navigator.of(context).pop();
      },
    );

    FlatButton cancel = FlatButton(
      child: Text("Cancel"),
      onPressed: () => Navigator.of(context).pop(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text("Are you sure?"),
            content: Text("Are you sure you want to leave this group?"),
            actions: [sure, cancel]);
      },
    );
  }

  Widget memberTileBuilder(BuildContext context, int index) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 10),
        child: Row(
          children: [
            Icon(
              Icons.person,
              size: 25,
            ),
            Text(
              " " + profiles[index].email,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
