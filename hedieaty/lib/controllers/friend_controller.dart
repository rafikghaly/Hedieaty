import '../models/friend.dart';

class FriendController {
  static final FriendController _instance = FriendController._internal();
  final FriendService _friendService = FriendService();

  factory FriendController() => _instance;
  FriendController._internal();

  Future<void> insertFriendLocal(Friend friend) async {
    await _friendService.insertFriendLocal(friend);
  }

  Future<void> insertFriendFirestore(Friend friend) async {
    await _friendService.insertFriendFirestore(friend);
  }

  Future<void> addMutualFriendsLocal(
      int userId1, int userId2, String userName1, String userName2) async {
    await _friendService.addMutualFriendsLocal(
        userId1, userId2, userName1, userName2);
  }

  Future<void> addMutualFriendsFirestore(
      int userId1, int userId2, String userName1, String userName2) async {
    await _friendService.addMutualFriendsFirestore(
        userId1, userId2, userName1, userName2);
  }

  Future<List<Friend>> friendsLocal(int userId) async {
    return await _friendService.friendsLocal(userId);
  }

  Future<List<Friend>> friendsFirestore(int userId) async {
    return await _friendService.friendsFirestore(userId);
  }

  Future<void> updateFriendLocal(Friend friend) async {
    await _friendService.updateFriendLocal(friend);
  }

  Future<void> updateFriendFirestore(Friend friend) async {
    await _friendService.updateFriendFirestore(friend);
  }

  Future<void> deleteFriendLocal(int id) async {
    await _friendService.deleteFriendLocal(id);
  }

  Future<void> deleteFriendFirestore(int id) async {
    await _friendService.deleteFriendFirestore(id);
  }
}
