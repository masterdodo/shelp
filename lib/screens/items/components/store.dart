class Store {
  String id;
  String name;
  String userId;

  Store(this.name, this.userId);
  Store.withId(this.id, this.name, this.userId);

  Map<String, dynamic> toJson() {
    return {'userId': this.userId, 'name': this.name};
  }
}
