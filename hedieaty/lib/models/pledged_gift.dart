class PledgedGift {
  late int? id;
  late String? docId;
  final int eventId;
  final int userId;
  final int giftId;
  final String friendName;
  final String dueDate;

  PledgedGift({
    this.id,
    required this.docId,
    required this.eventId,
    required this.userId,
    required this.giftId,
    required this.friendName,
    required this.dueDate,
  });

  factory PledgedGift.fromMap(Map<String, dynamic> map) {
    return PledgedGift(
      id: map['id'],
      docId: map['docId'],
      eventId: map['eventId'],
      userId: map['userId'],
      giftId: map['giftId'],
      friendName: map['friendName'],
      dueDate: map['dueDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'docId': docId,
      'eventId': eventId,
      'userId': userId,
      'giftId': giftId,
      'friendName': friendName,
      'dueDate': dueDate,
    };
  }
}
