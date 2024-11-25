class PledgedGift {
  final int? id;
  final int userId;
  final int giftId;

  PledgedGift({
    this.id,
    required this.userId,
    required this.giftId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'giftId': giftId,
    };
  }

  factory PledgedGift.fromMap(Map<String, dynamic> map) {
    return PledgedGift(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      giftId: map['giftId'] as int,
    );
  }
}
