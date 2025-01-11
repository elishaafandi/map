import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Call Page with dark theme
class CallPage extends StatefulWidget {
  final String renteeId;
  final String renteeName;

  CallPage({required this.renteeId, required this.renteeName});

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  static const primaryYellow = Color(0xFFFFD700);
  static const backgroundBlack = Color(0xFF121212);

  void _endCall() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlack,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryYellow,
                    child: Text(
                      widget.renteeName[0],
                      style: TextStyle(fontSize: 40, color: backgroundBlack),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.renteeName,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Calling...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: primaryYellow,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                    },
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.call_end, size: 32),
                    onPressed: _endCall,
                  ),
                  IconButton(
                    icon: Icon(
                      _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                      color: primaryYellow,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSpeakerOn = !_isSpeakerOn;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RenterNotificationsPage extends StatefulWidget {
  @override
  _RenterNotificationsPageState createState() =>
      _RenterNotificationsPageState();
}

class _RenterNotificationsPageState extends State<RenterNotificationsPage> {
  static const primaryYellow = Color(0xFFFFD700);
  static const backgroundBlack = Color(0xFF121212);
  static const cardGrey = Color(0xFF1E1E1E);
  static const textGrey = Color(0xFFB3B3B3);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        color: backgroundBlack,
        child: Column(
          children: [
            Container(
              color: cardGrey,
              child: TabBar(
                labelColor: primaryYellow,
                unselectedLabelColor: textGrey,
                indicatorColor: primaryYellow,
                tabs: [
                  Tab(text: 'Messages'),
                  Tab(text: 'Notifications'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ChatsList(),
                  NotificationsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatsList extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  static const primaryYellow = Color(0xFFFFD700);
  static const cardGrey = Color(0xFF1E1E1E);
  static const textGrey = Color(0xFFB3B3B3);

  // Dummy chat data
  final List<Map<String, dynamic>> dummyChats = [
    {
      'rentee_id': 'xnKKR28149XEqxJakZvxFhcblSJ3',
      'rentee_name': 'Elisha',
      'last_message': 'Hi',
      'timestamp': 'January 10, 2025 at 3:39:26 PM UTC+8',
      'user_details': {
        'address': 'KTDI',
        'contact': '0178997341',
        'course': 'SECVH',
        'email': 'elishaamila03@gmail.com',
        'matricNo': 'A22EC0156',
      }
    },
    {
      'rentee_id': 'dummy_user_1',
      'rentee_name': 'John Doe',
      'last_message': 'Hello there!',
      'timestamp': 'January 10, 2025',
    },
    {
      'rentee_id': 'dummy_user_2',
      'rentee_name': 'Sarah Smith',
      'last_message': 'Thanks for the info',
      'timestamp': 'January 9, 2025',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dummyChats.length,
      itemBuilder: (context, index) {
        final chat = dummyChats[index];
        final renteeId = chat['rentee_id'];
        final renteeName = chat['rentee_name'];

        return Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: cardGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: primaryYellow,
              child: Text(
                renteeName[0],
                style: TextStyle(color: Colors.black),
              ),
            ),
            title: Text(
              renteeName,
              style: TextStyle(color: Colors.white),
            ),
            subtitle: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc('${currentUserId}_$renteeId')
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final lastMessage =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  return Text(
                    lastMessage['text'] ?? 'No messages',
                    style: TextStyle(color: textGrey),
                  );
                }
                return Text(
                  'Start a conversation',
                  style: TextStyle(color: textGrey),
                );
              },
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.call, color: primaryYellow),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallPage(
                          renteeId: renteeId,
                          renteeName: renteeName,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              // Initialize chat document in Firestore if it doesn't exist
              final chatDocRef = FirebaseFirestore.instance
                  .collection('chats')
                  .doc('${currentUserId}_$renteeId');

              chatDocRef.get().then((doc) {
                if (!doc.exists) {
                  chatDocRef.set({
                    'renter_id': currentUserId,
                    'rentee_id': renteeId,
                    'rentee_name': renteeName,
                    'created_at': FieldValue.serverTimestamp(),
                    'last_message': '',
                    'last_message_time': FieldValue.serverTimestamp(),
                  });
                }
              });

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoom(
                    renteeId: renteeId,
                    renteeName: renteeName,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ChatRoom extends StatefulWidget {
  final String renteeId;
  final String renteeName;

  ChatRoom({required this.renteeId, required this.renteeName});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  static const primaryYellow = Color(0xFFFFD700);
  static const backgroundBlack = Color(0xFF121212);
  static const cardGrey = Color(0xFF1E1E1E);

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatRoomId = '${currentUserId}_${widget.renteeId}';
    final messageText = _messageController.text.trim();
    final timestamp = FieldValue.serverTimestamp();

    try {
      // Add message to the messages subcollection
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'text': messageText,
        'senderId': currentUserId,
        'timestamp': timestamp,
      });

      // Update the main chat document with last message info
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .update({
        'last_message': messageText,
        'last_message_time': timestamp,
      });

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomId = '${currentUserId}_${widget.renteeId}';

    return Scaffold(
      backgroundColor: backgroundBlack,
      appBar: AppBar(
        backgroundColor: cardGrey,
        title: Text(
          widget.renteeName,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: primaryYellow),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallPage(
                    renteeId: widget.renteeId,
                    renteeName: widget.renteeName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading messages',
                        style: TextStyle(color: Colors.white)),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(primaryYellow)),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMyMessage = message['senderId'] == currentUserId;

                    return Align(
                      alignment: isMyMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isMyMessage ? primaryYellow : cardGrey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          message['text'] ?? '',
                          style: TextStyle(
                            color: isMyMessage ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: cardGrey,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: backgroundBlack,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: primaryYellow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsList extends StatelessWidget {
  static const primaryYellow = Color(0xFFFFD700);
  static const cardGrey = Color(0xFF1E1E1E);
  static const textGrey = Color(0xFFB3B3B3);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('renter_notifications')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading notifications',
                  style: TextStyle(color: Colors.white)));
        }

        if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryYellow)));
        }

        final notifications = snapshot.data!.docs;

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification =
                notifications[index].data() as Map<String, dynamic>;

            return Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: cardGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: primaryYellow,
                ),
                title: Text(
                  notification['title'] ?? '',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  notification['message'] ?? '',
                  style: TextStyle(color: textGrey),
                ),
                trailing: Text(
                  notification['timestamp']?.toDate()?.toString() ?? '',
                  style: TextStyle(color: textGrey, fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
