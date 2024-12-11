import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'notification_controller.dart';

class Repository {
  final UserController _userController = UserController();
  final EventController _eventController = EventController();
  final FriendController _friendController = FriendController();
  final GiftController _giftController = GiftController();
  final PledgedGiftController _pledgedGiftController = PledgedGiftController();
  final NotificationController _notificationController = NotificationController();

  Future<bool> _isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult[0] != ConnectivityResult.none;
  }

  // User methods
  Future<void> registerUser(String email, String password, String name, String preferences, String phoneNumber) async {
    if (await _isOnline()) {
      try {
        await _userController.registerUser(email, password, name, preferences, phoneNumber);
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception("Cannot register user while offline.");
    }
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


  Future<String> getFriendNameByIdLocal(int id) async {
    return await _userController.getFriendNameByIdLocal(id);
  }
  Future<User?> getUserByFirebaseUid(String firebaseUid) async {
    if (await _isOnline()) {
      return await _userController.getUserByFirebaseUidFirestore(firebaseUid);
    } else {
      return await _userController.getUserByFirebaseUidLocal(firebaseUid);
    }
  }

  Future<void> updateUser(User user) async {
    if (await _isOnline()) {
      await _userController.updateUserFirestore(user);
    } else {
      throw Exception("Cannot update user while offline.");
    }
  }

  Future<void> deleteUser(String firebaseUid) async {
    if (await _isOnline()) {
      await _userController.deleteUserByFirebaseUidFirestore(firebaseUid);
    } else {
      throw Exception("Cannot delete user while offline.");
    }
  }

  Future<List<User>> getUsers() async {
    if (await _isOnline()) {
      return await _userController.usersFirestore();
    } else {
      return await _userController.usersLocal();
    }
  }
  Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    if (await _isOnline()) {
      return await _userController.getUserByPhoneNumber(phoneNumber);
    } else{
      throw Exception("Cannot get user while offline.");
    }
    return null;
  }

  // Event methods
  Future<void> insertEvent(Event event) async {
    //TODO Use it when making an offline list of Events
    // // Insert event locally to get auto-generated ID
    // int localId = await _eventController.insertEventLocal(event);
    //
    // // If online, insert event to Firestore and set Firestore doc ID as event ID
    // event.id = localId; // Ensure the ID is reset before setting it again
    if (await _isOnline()) {
      await _eventController.insertEventFirestore(event);
    } else {
      throw Exception("Cannot insert event while offline.");
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
    if (await _isOnline()) {
      await _eventController.updateEventFirestore(event);
    } else {
      throw Exception("Cannot update event while offline.");
    }
  }

  Future<void> deleteEvent(String id) async {
    if (await _isOnline()) {
      await _eventController.deleteEventFirestore(id);
    } else {
      throw Exception("Cannot delete event while offline.");
    }
  }

  /// THIS IS ONLY FOR LOCAL_EVENTS TABLE ////////////////////////////////
  Future<void> insertLocalEventTable(Event event) async {
    await _eventController.insertLocalEventTable(event);
  }

  Future<void> updateLocalEventTable(Event event) async {
    await _eventController.updateLocalEventTable(event);
  }

  Future<List<Event>> getLocalEventsTable(int userId) async {
    return await _eventController.getLocalEventsTable(userId: userId);
  }

  Future<void> deleteLocalEventTable(int id) async {
    await _eventController.deleteLocalEventTable(id);
  }

  Future<void> publishEventTable(Event event) async {
    if (await _isOnline()) {
      await _eventController.publishLocalEventTable(event);
    } else {
      throw Exception("Cannot publish event while offline.");
    }
  }

//////////////////////////////////////////////////////////////////////


  /// THIS IS ONLY FOR LOCAL_GIFTS TABLE ////////////////////////////////

  // Insert local gift
  Future<void> insertLocalGift(Gift gift) async {
    await _giftController.insertGiftLocalTABLE(gift);
  }
  // Get local gifts for an event
  Future<List<Gift>> getLocalGifts(int eventId) async {
    return await _giftController.getGiftsLocalTABLE(eventId);
  }
  // Update local gift
  Future<void> updateLocalGiftTable(Gift gift) async {
    await _giftController.updateGiftLocalTABLE(gift); //--------------------->
  }
  // Delete local gift
  Future<void> deleteLocalGiftTable(int giftId) async {
    await _giftController.deleteGiftLocalTABLE(giftId); //--------------------->
  }
/////////////////////////////////////////////////////////////////////////


  // Friend methods
  Future<void> insertFriend(Friend friend) async {
    if (await _isOnline()) {
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
      await _friendController.updateFriendFirestore(friend);
    } else {
      throw Exception("Cannot update friend while offline.");
    }
  }

  Future<void> deleteFriend(int id) async {
    if (await _isOnline()) {
      await _friendController.deleteFriendFirestore(id);
    } else {
      throw Exception("Cannot delete friend while offline.");
    }
  }

  // Gift methods
  Future<void> insertGift(Gift gift) async {
    //TODO Use it when making an offline list of Events
    // await _giftController.insertGiftLocal(gift);
    if (await _isOnline()) {
      await _giftController.insertGiftFirestore(gift);
    } else {
      throw Exception("Cannot insert gift while offline.");
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
    if (await _isOnline()) {
      await _giftController.updateGiftFirestore(gift);
    } else {
      throw Exception("Cannot update gift while offline.");
    }
  }

  Future<void> markGiftAsPurchased(String? giftId) async {
    if (await _isOnline()) {
      await _giftController.markGiftAsPurchased(giftId);
    } else {
      throw Exception("Cannot purchase gift while offline.");
    }
  }

  Future<void> deleteGift(String id) async {
    if (await _isOnline()) {
      await _giftController.deleteGiftFirestore(id);
    } else {
      throw Exception("Cannot delete gift while offline.");
    }
    //TODO await _giftController.deleteGiftLocal(id);//TODO Change the id into string
  }

  // PledgedGift methods
  Future<void> insertPledgedGift(PledgedGift pledgedGift) async {
    if (await _isOnline()) {
      await _pledgedGiftController.insertPledgedGiftFirestore(pledgedGift);
    } else {
      throw Exception("Cannot insert pledged gift while offline.");
    }
  }

  Future<List<PledgedGift>> getPledgedGiftsForUser(int userId) async {
    if (await _isOnline()) {
      return await _pledgedGiftController
          .getPledgedGiftsForUserFirestore(userId);
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
    } else {
      throw Exception("Cannot delete pledged gift while offline.");
    }
    //TODO await _pledgedGiftController.deletePledgedGiftLocal(id);//TODO Change the id delete into string
  }

  Future<void> saveImageToSharedPrefs(String firebaseUid) async{
    if (await _isOnline()) {
      await _userController.retrieveAndSaveProfileImage(firebaseUid);
    } else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageBase64', "null");
    }
  }

  Future<String?> getUserProfileImage(int userId) async {
    if (await _isOnline()) {
      return await _userController.getUserProfileImage(userId);
    }
    return null;
  }

  Future<String?> pickAndConvertImageToBase64() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    }
    return null;
  }

  // Notifications
  Future<void> makeNotificationPledge(int eventId, String pledgerName, String giftName) async {
    User? user = await _userController.getUserByEventId(eventId);
    _notificationController.createNotification(
      userId: user!.id.toString(),
      title: 'New Pledge!',
      message: '$pledgerName has pledged to buy the gift: $giftName.',
    );
  }

  Future<void> makeNotificationPurchase(int eventId, String purchaserName, String giftName) async {
    User? user = await _userController.getUserByEventId(eventId);
    _notificationController.createNotification(
      userId: user!.id.toString(),
      title: 'A Purchase!',
      message: '$purchaserName has Purchased the gift: $giftName.',
    );
  }

  Future<void> updateNotification(String notificationId ) async {
    await _notificationController.updateNotification(notificationId);
  }

  Future<void> deleteNotification(String notificationId ) async {
    await _notificationController.deleteNotification(notificationId);
  }
}
