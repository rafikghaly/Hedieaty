class PledgedGift {
  final int? id;
  final int eventId;
  final int userId;
  final int giftId;
  final String friendName;
  final String dueDate;

  PledgedGift({
    this.id,
    required this.eventId,
    required this.userId,
    required this.giftId,
    required this.friendName,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'giftId': giftId,
      'friendName': friendName,
      'dueDate': dueDate,
    };
  }

  factory PledgedGift.fromMap(Map<String, dynamic> map) {
    return PledgedGift(
      id: map['id'] as int?,
      eventId: map['eventId'] as int,
      userId: map['userId'] as int,
      giftId: map['giftId'] as int,
      friendName: map['friendName'] as String,
      dueDate: map['dueDate'] as String,
    );
  }
}
