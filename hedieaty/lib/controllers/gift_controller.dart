import '../models/gift.dart';

class GiftController {
  static final GiftController _instance = GiftController._internal();
  final GiftService _giftService = GiftService();

  factory GiftController() => _instance;
  GiftController._internal();

  Future<void> insertGiftFirestore(Gift gift) async {
    await _giftService.insertGiftFirestore(gift);
  }

  Future<List<Gift>> giftsLocal(int eventId) async {
    return await _giftService.giftsLocal(eventId);
  }

  Future<List<Gift>> giftsFirestore(int eventId) async {
    return await _giftService.giftsFirestore(eventId);
  }

  Future<Gift?> getGiftByIdLocal(int id) async {
    return await _giftService.getGiftByIdLocal(id);
  }

  Future<Gift?> getGiftByIdFirestore(String docId) async {
    return await _giftService.getGiftByIdFirestore(docId);
  }

  Future<Gift?> getGiftByIdForPledgedFirestore(int id) async {
    return await _giftService.getGiftByIdForPledgedFirestore(id);
  }

  Future<void> updateGiftLocal(Gift gift) async {
    await _giftService.updateGiftLocal(gift);
  }

  Future<void> updateGiftFirestore(Gift gift) async {
    await _giftService.updateGiftFirestore(gift);
  }

  Future<void> deleteGiftLocal(int id) async {
    await _giftService.deleteGiftLocal(id);
  }

  Future<void> deleteGiftFirestore(String docId) async {
    await _giftService.deleteGiftFirestore(docId);
  }

  Future<void> markGiftAsPurchased(String? giftId) async {
    await _giftService.markGiftAsPurchased(giftId);
  }

  ///THIS IS ONLY FOR LOCAL_GIFTS TABLE
  Future<int> insertGiftLocalTABLE(Gift gift) async {
    return await _giftService.insertGiftLocalTABLE(gift);
  }

  Future<List<Gift>> getGiftsLocalTABLE(int eventId) async {
    return await _giftService.getGiftsLocalTABLE(eventId);
  }

  Future<void> deleteGiftsForEventLocalTABLE(int eventId) async {
    await _giftService.deleteGiftsForEventLocalTABLE(eventId);
  }

  Future<void> updateGiftLocalTABLE(Gift gift) async {
    await _giftService.updateGiftLocalTABLE(gift);
  }

  Future<void> deleteGiftLocalTABLE(int giftId) async {
    await _giftService.deleteGiftLocalTABLE(giftId);
  }

///////////////////////////////////////////////////////////////////////////////
}
