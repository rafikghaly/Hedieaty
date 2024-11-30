import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/friend.dart';
import '../models/gift.dart';
import '../models/pledged_gift.dart';
import 'user_controller.dart';
import 'event_controller.dart';
import 'friend_controller.dart';
import 'gift_controller.dart';
import 'pledged_gift_controller.dart';

class Repository {
  final UserController _userController = UserController();
  final EventController _eventController = EventController();
  final FriendController _friendController = FriendController();
  final GiftController _giftController = GiftController();
  final PledgedGiftController _pledgedGiftController = PledgedGiftController();

  Future<bool> _isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult[0] != ConnectivityResult.none;
  }

  // User methods
  Future<void> registerUser(
      String email, String password, String name, String preferences) async {
    await _userController.registerUser(email, password, name, preferences);
  }

  Future<User?> authenticateUser(String email, String password) async {
    return await _userController.authenticateUser(email, password);
  }

  Future<User?> getUserByEmail(String email) async {
    if (await _isOnline()) {
      return await _userController.getUserByEmailFirestore(email);
    } else {
      return await _userController.getUserByEmailLocal(email);
    }
  }

  Future<User?> getUserById(int id) async {
    if (await _isOnline()) {
      return await _userController.getUserByIdFirestore(id);
    } else {
      return await _userController.getUserByIdLocal(id);
    }
  }

  Future<User?> getUserByFirebaseUid(String firebaseUid) async {
    if (await _isOnline()) {
      return await _userController.getUserByFirebaseUidFirestore(firebaseUid);
    } else {
      return await _userController.getUserByFirebaseUidLocal(firebaseUid);
    }
  }

  Future<void> updateUser(User user) async {
    await _userController.updateUserLocal(user);
    if (await _isOnline()) {
      await _userController.updateUserFirestore(user);
    }
  }

  Future<void> deleteUser(String firebaseUid) async {
    if (await _isOnline()) {
      await _userController.deleteUserByFirebaseUidFirestore(firebaseUid);
    }
    await _userController.deleteUserLocal(firebaseUid.hashCode);
  }

  Future<List<User>> getUsers() async {
    if (await _isOnline()) {
      return await _userController.usersFirestore();
    } else {
      return await _userController.usersLocal();
    }
  }

  // Event methods
  Future<void> insertEvent(Event event) async {
    // Insert event locally to get auto-generated ID
    int localId = await _eventController.insertEventLocal(event);

    // If online, insert event to Firestore and set Firestore doc ID as event ID
    if (await _isOnline()) {
      event.id = localId; // Ensure the ID is reset before setting it again
      await _eventController.insertEventFirestore(event);
    } else {
      event.id = localId; // Assign the local ID if offline
    }
  }

  Future<Event?> getEventById(int id) async {
    if (await _isOnline()) {
      return await _eventController.getEventByIdFirestore(id);
    } else {
      return await _eventController.getEventByIdLocal(id);
    }
  }

  Future<List<Event>> getEvents({required int userId}) async {
    if (await _isOnline()) {
      return await _eventController.eventsFirestore(userId: userId);
    } else {
      return await _eventController.eventsLocal(userId: userId);
    }
  }

  Future<void> updateEvent(Event event) async {
    await _eventController.updateEventLocal(event);
    if (await _isOnline()) {
      await _eventController.updateEventFirestore(event);
    }
  }

  Future<void> deleteEvent(String id) async {
    if (await _isOnline()) {
      await _eventController.deleteEventFirestore(id);
    }
    //TODO await _eventController.deleteEventLocal(id as int); //TODO Change the id delete into string
  }

  // Friend methods
  Future<void> insertFriend(Friend friend) async {
    if (await _isOnline()) {
      await _friendController.insertFriendLocal(friend);
      await _friendController.insertFriendFirestore(friend);
    } else {
      throw Exception("Cannot add friend while offline.");
    }
  }

  Future<void> addMutualFriends(
      int userId1, int userId2, String userName1, String userName2) async {
    if (await _isOnline()) {
      await _friendController.addMutualFriendsLocal(
          userId1, userId2, userName1, userName2);
      await _friendController.addMutualFriendsFirestore(
          userId1, userId2, userName1, userName2);
    } else {
      throw Exception("Cannot add mutual friends while offline.");
    }
  }

  Future<List<Friend>> getFriends(int userId) async {
    if (await _isOnline()) {
      return await _friendController.friendsFirestore(userId);
    } else {
      return await _friendController.friendsLocal(userId);
    }
  }

  Future<void> updateFriend(Friend friend) async {
    if (await _isOnline()) {
      await _friendController.updateFriendLocal(friend);
      await _friendController.updateFriendFirestore(friend);
    } else {
      throw Exception("Cannot update friend while offline.");
    }
  }

  Future<void> deleteFriend(int id) async {
    if (await _isOnline()) {
      await _friendController.deleteFriendLocal(id);
      await _friendController.deleteFriendFirestore(id);
    } else {
      throw Exception("Cannot delete friend while offline.");
    }
  }

  // Gift methods
  Future<void> insertGift(Gift gift) async {
    await _giftController.insertGiftLocal(gift);
    if (await _isOnline()) {
      await _giftController.insertGiftFirestore(gift);
    }
  }

  Future<List<Gift>> getGifts(int eventId) async {
    if (await _isOnline()) {
      return await _giftController.giftsFirestore(eventId);
    } else {
      return await _giftController.giftsLocal(eventId);
    }
  }

  Future<Gift?> getGiftById(String id) async {
    if (await _isOnline()) {
      return await _giftController.getGiftByIdFirestore(id);
    } else {
      //TODO return await _giftController.getGiftByIdLocal(id);//TODO Change the id into string
    }
    return null;
  }

  Future<Gift?> getGiftById_For_pledged_Firestore(int id) async {
    return await _giftController.getGiftById_for_pledged_Firestore(id);
  }

  Future<void> updateGift(Gift gift) async {
    await _giftController.updateGiftLocal(gift);
    if (await _isOnline()) {
      await _giftController.updateGiftFirestore(gift);
    }
  }

  Future<void> deleteGift(String id) async {
    if (await _isOnline()) {
      await _giftController.deleteGiftFirestore(id);
    }
    //TODO await _giftController.deleteGiftLocal(id);//TODO Change the id into string
  }

  // PledgedGift methods
  Future<void> insertPledgedGift(PledgedGift pledgedGift) async {
    await _pledgedGiftController.insertPledgedGiftLocal(
        pledgedGift); //TODO check for null id (check offline functionality)
    if (await _isOnline()) {
      await _pledgedGiftController.insertPledgedGiftFirestore(pledgedGift);
    }
  }

  Future<List<PledgedGift>> getPledgedGiftsForUser(int userId) async {
    if (await _isOnline()) {
      return await _pledgedGiftController.getPledgedGiftsForUserFirestore(userId);
    } else {
      return await _pledgedGiftController.getPledgedGiftsForUserLocal(userId);
    }
  }

  Future<List<PledgedGift>> getPledgedGiftsForEvent(int eventId) async {
    if (await _isOnline()) {
      return await _pledgedGiftController
          .getPledgedGiftsForEventFirestore(eventId);
    } else {
      return await _pledgedGiftController.getPledgedGiftsForEventLocal(eventId);
    }
  }

  Future<void> deletePledgedGift(String id) async {
    if (await _isOnline()) {
      await _pledgedGiftController.deletePledgedGiftFirestore(id);
    }
    //TODO await _pledgedGiftController.deletePledgedGiftLocal(id);//TODO Change the id delete into string
  }
}
