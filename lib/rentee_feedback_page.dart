import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RenteeFeedbackPage extends StatelessWidget {
  final String currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RenteeFeedbackPage({required this.currentUserId});

  Stream<List<DocumentSnapshot>> getRenterFeedback() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('feedback')
        .where('renteeId', isEqualTo: user.uid)
        .where('feedbackType', isEqualTo: 'rentee')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<DocumentSnapshot>> getYourFeedback() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('feedback')
        .where('renterId', isEqualTo: user.uid)
        .where('feedbackType', isEqualTo: 'renter')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

   ImageProvider? _getImageProvider(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }
    try {
      return MemoryImage(base64Decode(base64String));
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2A2A2A),
      appBar: AppBar(
        title: Text('Feedback', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.yellow[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                icon: Icons.feedback,
                title: 'FEEDBACK FROM RENTER',
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: getRenterFeedback(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              color: Colors.yellow[700]));
                    }

                    final feedbacks = snapshot.data ?? [];
                    if (feedbacks.isEmpty) {
                      return Text(
                        "No feedback found",
                        style: TextStyle(color: Colors.white),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: feedbacks.map((feedbackDoc) {
                          final feedback = feedbackDoc.data() as Map<String, dynamic>? ?? {};
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _feedbackCard(feedback),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              _buildSection(
                icon: Icons.comment,
                title: 'YOUR FEEDBACK',
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: getYourFeedback(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              color: Colors.yellow[700]));
                    }

                    final feedbacks = snapshot.data ?? [];
                    if (feedbacks.isEmpty) {
                      return Text(
                        "No feedback found",
                        style: TextStyle(color: Colors.white),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: feedbacks.map((feedbackDoc) {
                          final feedback = feedbackDoc.data() as Map<String, dynamic>? ?? {};
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _feedbackCard(feedback),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow[700]!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.yellow[700], size: 24),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

   Widget _feedbackCard(Map<String, dynamic> feedback) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[700]!.withOpacity(0.3)),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(feedback['renterId'] ?? feedback['renteeId'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[800],
                      child: Icon(Icons.person, color: Colors.grey[600]),
                    );
                  }

                  final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                  final profilePhoto = userData['profilePhoto'];
                  final imageProvider = _getImageProvider(profilePhoto);
                  
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? Icon(Icons.person, color: Colors.grey[600])
                            : null,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['username'] ?? 'Anonymous User',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            feedback['pickupDate'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              Spacer(),
              _ratingStars(feedback['rating'] ?? 0),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: Colors.grey[800]),
          SizedBox(height: 16),
          
          if (feedback['selectedFeedback'] != null) ...[
            ...List<String>.from(feedback['selectedFeedback']).map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            )),
            SizedBox(height: 8),
          ],
          
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.yellow[700]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_car,
                  size: 16,
                  color: Colors.yellow[700],
                ),
                SizedBox(width: 8),
                Text(
                  feedback['vehicleName'] ?? 'Unknown Vehicle',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.yellow[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _ratingStars(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          Icons.star,
          color: index < rating ? Colors.yellow[700] : Colors.grey[800],
          size: 20,
        ),
      ),
    );
  }
}
