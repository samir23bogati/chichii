class CartItem {
  final String title;
  final String price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.title,
     required this.price, 
     required this.imageUrl,
     this.quantity = 1, //default
     });
}
