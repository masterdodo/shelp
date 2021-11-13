class Profile {
  String pid;
  String id;
  String email;
  String family;
  String fullName;
  String gender;
  String age;
  String phoneNumber;

  Profile(this.id, this.email, this.fullName, this.gender, this.age,
      this.phoneNumber);
  Profile.withFamily(this.id, this.email, this.family, this.fullName,
      this.gender, this.age, this.phoneNumber);
  Profile.onlyIdandEmail(this.id, this.email);
  Profile.complete(this.pid, this.id, this.email, this.family, this.fullName,
      this.gender, this.age, this.phoneNumber);

  Map<String, dynamic> toJson() {
    return {
      'userId': this.id,
      'email': this.email,
      'family': this.family ?? "",
      'fullName': this.fullName ?? "",
      'gender': this.gender ?? "",
      'age': this.age ?? "",
      'phoneNumber': this.phoneNumber ?? ""
    };
  }
}
