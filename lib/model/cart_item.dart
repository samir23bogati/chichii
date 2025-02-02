class CartItem {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
     required this.price, 
     required this.imageUrl,
     this.quantity = 1, //default
     });

     void increaseQuantity() {
    quantity++;
}
 void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }
  // CopyWith method to create a new CartItem with updated fields
  CartItem copyWith({
    String? id,
    String? title,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(

      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}