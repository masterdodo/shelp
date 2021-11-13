class Item {
  String id;
  String name;
  String storeId;
  String categoryId;
  String userId;
  String price;

  Item(this.name, this.userId, this.storeId, this.categoryId, this.price);
  Item.withId(this.id, this.name, this.userId, this.storeId, this.categoryId,
      this.price);

  Map<String, dynamic> toJson() {
    return {
      'userId': this.userId,
      'name': this.name,
      'storeId': this.storeId,
      'categoryId': this.categoryId,
      'price': this.price
    };
  }
}
