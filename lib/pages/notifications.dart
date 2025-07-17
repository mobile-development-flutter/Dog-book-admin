import 'package:admin/components/bottom_nav_two.dart';
import 'package:admin/components/custom_appbar2.dart';
import 'package:admin/components/custom_shop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String? _adminName;
  String? _currentlyReplyingTo;
  final Map<String, TextEditingController> _replyControllers = {};
  late Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
    _messagesStream = FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _replyControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchAdminData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();

        if (adminDoc.exists) {
          setState(() {
            _adminName = adminDoc['name']?.toString() ?? 'Admin';
          });
          return;
        }

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc['isAdmin'] == true) {
          setState(() {
            _adminName = userDoc['name']?.toString() ?? 'Admin';
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching admin data: $e");
      setState(() {
        _adminName = 'Admin';
      });
    }
  }

  Future<void> _sendReply(String messageId, String? senderId) async {
    if (senderId == null || senderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot reply - message has no valid sender'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final controller = _replyControllers[messageId];
    if (controller == null || controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reply message'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    try {
      // Add reply to Firestore
      await FirebaseFirestore.instance.collection('message_replies').add({
        'messageId': messageId,
        'reply': controller.text,
        'adminName': _adminName ?? 'Admin',
        'senderId': senderId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mark original message as replied
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(messageId)
          .update({'hasReply': true});

      // Create notification for the sender
      await FirebaseFirestore.instance
          .collection('user_notifications')
          .doc(senderId)
          .collection('notifications')
          .add({
            'type': 'message_reply',
            'message': 'Admin replied to your message',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
            'relatedMessageId': messageId,
          });

      // Clear and reset UI
      controller.clear();
      setState(() {
        _currentlyReplyingTo = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply sent successfully'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reply: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleReply(String messageId) {
    setState(() {
      if (_currentlyReplyingTo == messageId) {
        _currentlyReplyingTo = null;
      } else {
        _currentlyReplyingTo = messageId;
        _replyControllers.putIfAbsent(messageId, () => TextEditingController());
      }
    });
  }

  void showAddShopForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ShopForm(onShopAdded: () {}, onPetAdded: null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar2(
        title: _adminName != null
            ? "Admin, ${_adminName!.split(' ').first}"
            : "Admin",
        showBackButton: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: Text(
                "Notifications",
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B2B2B),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.poppins(),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet",
                      style: GoogleFonts.poppins(fontSize: 16.sp),
                    ),
                  );
                }

                final messages = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {
                    'id': doc.id,
                    'message': data['message']?.toString() ?? 'No message',
                    'senderName': data['senderName']?.toString() ?? 'Unknown',
                    'senderId': data['senderId']?.toString() ?? '',
                    'timestamp': data['timestamp'] ?? Timestamp.now(),
                    'read': data['read'] ?? false,
                    'hasReply': data['hasReply'] ?? false,
                  };
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final date = DateFormat(
                      'MMM dd, yyyy - hh:mm a',
                    ).format((message['timestamp'] as Timestamp).toDate());

                    return Card(
                      margin: EdgeInsets.only(bottom: 16.h),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  message['senderName'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(width: 15.w),
                                if (message['hasReply'] == true)
                                  const Icon(
                                    Icons.check_circle_outline_outlined,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(
                                    _currentlyReplyingTo == message['id']
                                        ? Icons.close
                                        : Icons.reply,
                                  ),
                                  onPressed: () => _toggleReply(message['id']),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(message['message']),
                            SizedBox(height: 8.h),
                            Text(
                              date,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            if (_currentlyReplyingTo == message['id']) ...[
                              SizedBox(height: 16.h),
                              TextField(
                                controller: _replyControllers[message['id']],
                                decoration: InputDecoration(
                                  hintText: 'Type your reply...',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () => _sendReply(
                                      message['id'],
                                      message['senderId'],
                                    ),
                                  ),
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavTwo(
        onPlusPressed: () => showAddShopForm(context),
      ),
    );
  }
}
