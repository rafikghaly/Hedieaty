import '../models/pledged_gift.dart';

class PledgedGiftController {
  static final PledgedGiftController _instance = PledgedGiftController._internal();
  final PledgedGiftService _pledgedGiftService = PledgedGiftService();

  factory PledgedGiftController() => _instance;
  PledgedGiftController._internal();

  Future<int> insertPledgedGiftLocal(PledgedGift pledgedGift) async {
    return await _pledgedGiftService.insertPledgedGiftLocal(pledgedGift);
  }

  Future<void> insertPledgedGiftFirestore(PledgedGift pledgedGift) async {
    await _pledgedGiftService.insertPledgedGiftFirestore(pledgedGift);
  }

  Future<PledgedGift?> getPledgedGiftByIdLocal(int id) async {
    return await _pledgedGiftService.getPledgedGiftByIdLocal(id);
  }

  Future<PledgedGift?> getPledgedGiftByIdFirestore(String docId) async {
    return await _pledgedGiftService.getPledgedGiftByIdFirestore(docId);
  }

  Future<List<PledgedGift>> getPledgedGiftsForEventLocal(int eventId) async {
    return await _pledgedGiftService.getPledgedGiftsForEventLocal(eventId);
  }

  Future<List<PledgedGift>> getPledgedGiftsForEventFirestore(
      int eventId) async {
    return await _pledgedGiftService.getPledgedGiftsForEventFirestore(eventId);
  }

  Future<void> updatePledgedGiftLocal(PledgedGift pledgedGift) async {
    await _pledgedGiftService.updatePledgedGiftLocal(pledgedGift);
  }

  Future<void> updatePledgedGiftFirestore(PledgedGift pledgedGift) async {
    await _pledgedGiftService.updatePledgedGiftFirestore(pledgedGift);
  }

  Future<void> deletePledgedGiftLocal(int id) async {
    await _pledgedGiftService.deletePledgedGiftLocal(id);
  }

  Future<void> deletePledgedGiftFirestore(String docId) async {
    await _pledgedGiftService.deletePledgedGiftFirestore(docId);
  }

  Future<List<PledgedGift>> getPledgedGiftsForUserLocal(int userId) async {
    return await _pledgedGiftService.getPledgedGiftsForUserLocal(userId);
  }

  Future<List<PledgedGift>> getPledgedGiftsForUserFirestore(int userId) async {
    return await _pledgedGiftService.getPledgedGiftsForUserFirestore(userId);
  }
}
