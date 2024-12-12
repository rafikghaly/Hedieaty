import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/repository.dart';
import '../models/notification.dart' as app_model;

class NotificationPage extends StatelessWidget {
  final int userId;
  final Repository _repository = Repository();

  NotificationPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.amber[500],
        elevation: 10.0,
        shadowColor: Colors.black,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xFFFE6B8B), Color(0xFFFF8E53)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId.toString())
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data!.docs.map((doc) => app_model.Notification.fromMap(doc.data() as Map<String, dynamic>)).toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Dismissible(
                    key: Key(notification.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return false;
                    },
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (details.primaryDelta! < -10) {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                color: Colors.red,
                                child: ListTile(
                                  leading: const Icon(Icons.delete, color: Colors.white),
                                  title: const Text('Delete', style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    _repository.deleteNotification(notification.id);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${notification.title} deleted')));
                                  },
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.notifications, color: Colors.white),
                        ),
                        title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(notification.message),
                        trailing: notification.isRead ? null : const Icon(Icons.new_releases, color: Colors.red),
                        onTap: () {
                          _repository.updateNotification(notification.id);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
