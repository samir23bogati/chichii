class CartItem {
  final String title;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
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
    String? title,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      title: title ?? this.title,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}