class CartItem {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  int quantity;

  // Constructor with default value for quantity
  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1, // Default quantity is 1
  });

  // Method to increase quantity by 1
  void increaseQuantity() {
    quantity++;
  }

  // Method to decrease quantity by 1
  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  // Method to copy the CartItem with a new quantity or other fields
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

  // To convert CartItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  // From JSON to CartItem with default quantity handling
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      quantity: json['quantity'] ?? 1, // Default to 1 if quantity is not provided
    );
  }

  
}
