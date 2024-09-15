class Product {
  final String product_id;
  final String product_name;
  final String product_description;
  final int product_quantity;
  final double product_price;
  final double product_offerprice;
  final String product_cateogory;
  final bool product_availability;
  final double product_rating;
  final String imageLink;
  final String? deliveryTime;
  final int? deliveryDays;
  final int? Available_count;

  Product({
    required this.product_id,
    required this.product_name,
    required this.product_description,
    required this.product_quantity,
    required this.product_price,
    required this.product_offerprice,
    required this.product_cateogory,
    required this.product_availability,
    required this.product_rating,
    required this.imageLink,
    this.deliveryTime,
    this.deliveryDays,
    required this.Available_count,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      product_id: data['product_id'],
      product_name: data['product_name'],
      product_description: data['product_description'],
      product_quantity: data['product_quantity'],
      product_price: (data['product_price'] as num).toDouble(),
      product_offerprice: (data['product_offerprice'] as num).toDouble(),
      product_cateogory: data['product_cateogory'],
      product_availability: data['product_availability'],
      product_rating: (data['product_rating'] as num).toDouble(),
      imageLink: data['imageLink'],
      deliveryTime: data['deliveryTime'],
      deliveryDays: data['deliveryDays'],
      Available_count: data['Available_count']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': product_id,
      'product_name': product_name,
      'product_description': product_description,
      'product_quantity': product_quantity,
      'product_price': product_price,
      'product_offerprice': product_offerprice,
      'product_cateogory': product_cateogory,
      'product_availability': product_availability,
      'product_rating': product_rating,
      'imageLink': imageLink,
      'deliveryTime': deliveryTime,
      'deliveryDays': deliveryDays,
      'Available_count': Available_count
    };
  }
}
