class FamilyAccount {
  String id;
  List<String> users;

  FamilyAccount(this.users);
  FamilyAccount.withId(this.id, this.users);

  Map<String, dynamic> toJson() {
    return {
      'users': this.users,
    };
  }
}
