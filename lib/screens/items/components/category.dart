class Category {
  String id;
  String name;
  String userId;

  Category(this.name, this.userId);
  Category.withId(this.id, this.name, this.userId);

  Map<String, dynamic> toJson() {
    return {'userId': this.userId, 'name': this.name};
  }
}
