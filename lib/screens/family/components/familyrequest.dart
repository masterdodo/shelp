class FamilyRequest {
  String id;
  String senderId;
  String recieverId;

  FamilyRequest(this.senderId, this.recieverId);
  FamilyRequest.withId(this.id, this.senderId, this.recieverId);

  Map<String, dynamic> toJson() {
    return {
      'senderId': this.senderId,
      'recieverId': this.recieverId,
    };
  }
}
