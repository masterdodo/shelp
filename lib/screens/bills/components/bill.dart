class Bill {
  String id;
  String userId;
  String timeAndDay;
  String text;
  String fullPrice;

  Bill(this.userId, this.timeAndDay, this.text, this.fullPrice);
  Bill.withId(this.id, this.userId, this.timeAndDay, this.text, this.fullPrice);

  Map<String, dynamic> toJson() {
    return {
      'userId': this.userId,
      'timeAndDay': this.timeAndDay ?? "",
      'text': this.text ?? "",
      'fullPrice': this.fullPrice ?? ""
    };
  }
}
