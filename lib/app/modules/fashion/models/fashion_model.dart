class FashionModel {
  int? id;
  String? sku;
  String? name;
  String? category;
  int? price;
  String? size;
  String? color;
  int? qty;
  String? status;
  String? imageUrl;

  FashionModel({
    this.id,
    this.sku,
    this.name,
    this.category,
    this.price,
    this.size,
    this.color,
    this.qty,
    this.status,
    this.imageUrl,
  });

  factory FashionModel.fromJson(Map<String, dynamic> json) {
    return FashionModel(
      id: json['id'] as int?,
      sku: json['sku'] as String?,
      name: json['name'] as String?,
      category: json['category'] as String?,
      price: json['price'] != null ? int.tryParse(json['price'].toString()) : 0,
      size: json['size'] as String?,
      color: json['color'] as String?,
      qty: json['qty'] != null ? int.tryParse(json['qty'].toString()) : 0,
      status: json['status'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
