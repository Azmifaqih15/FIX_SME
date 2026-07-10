class MarketModel {
  String? id;
  String? kategori;
  int? rekomendasiHarga;
  String? status;

  MarketModel({
    this.id,
    this.kategori,
    this.rekomendasiHarga,
    this.status,
  });

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      id: json['id']?.toString() ?? json['_id']?.toString(), // Konversi dari MongoDB
      kategori: json['kategori'] as String?,
      rekomendasiHarga: json['rekomendasi_harga'] != null 
          ? int.tryParse(json['rekomendasi_harga'].toString()) 
          : 0,
      status: json['status'] as String?,
    );
  }
}
