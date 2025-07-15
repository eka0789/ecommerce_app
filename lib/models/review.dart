class Review {
  final int productId;
  final String userName;
  final String comment;
  final DateTime timestamp;

  Review({
    required this.productId,
    required this.userName,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'userName': userName,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      productId: json['productId'],
      userName: json['userName'],
      comment: json['comment'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}