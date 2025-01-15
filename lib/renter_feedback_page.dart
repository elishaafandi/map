import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'write_feedback_formrentee.dart';

class RenterFeedbackPage extends StatelessWidget {
  final String currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RenterFeedbackPage({required this.currentUserId});

  Stream<List<DocumentSnapshot>> getPendingFeedbackBookings() {
    return _firestore
        .collection('bookings')
        .where('renterId', isEqualTo: currentUserId)
        .where('booking_status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<DocumentSnapshot>> getRenterFeedback() {
    return _firestore
        .collection('feedback')
        .where('renterId', isEqualTo: currentUserId)
        .where('feedbackType', isEqualTo: 'renter')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<DocumentSnapshot>> getYourFeedback() {
    return _firestore
        .collection('feedback')
        .where('renteeId', isEqualTo: currentUserId)
        .where('feedbackType', isEqualTo: 'rentee')
        .snapshots()
        .map((snapshot) => snapshot.docs);
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
                icon: Icons.rate_review,
                title: 'WRITE A FEEDBACK',
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: getPendingFeedbackBookings(),
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

                    final bookings = snapshot.data ?? [];
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index].data() as Map<String, dynamic>;
                        return _writeFeedbackCard(booking, context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 24),

              _buildSection(
                icon: Icons.feedback,
                title: 'FEEDBACK FROM RENTEE',
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
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: feedbacks.map((feedbackDoc) {
                          final feedback =
                              feedbackDoc.data() as Map<String, dynamic>;
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
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: feedbacks.map((feedbackDoc) {
                          final feedback =
                              feedbackDoc.data() as Map<String, dynamic>;
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

  Widget _writeFeedbackCard(Map<String, dynamic> booking, BuildContext context) {
    String formattedTime = '${booking['pickupTime']} - ${booking['returnTime']}';
    String formattedDate = booking['pickupDate'];

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[700]!.withOpacity(0.3)),
      ),
      child: ListTile(
        title: Text(
          booking['location'] ?? 'Unknown Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '$formattedTime | $formattedDate',
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WriteYourFeedback(
                  bookingDetails: {
                    'bookingId': booking['bookingId'],
                    'vehicleModel': booking['vehicleModel'],
                    'dates': '$formattedTime, $formattedDate',
                    'location': booking['location'],
                    'renterId': booking['renterId'],
                    'renteeId': booking['renteeId'],
                  },
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Rate',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                feedback['vehicleName'] ?? 'Unknown Vehicle',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              _ratingStars(feedback['rating'] ?? 0),
            ],
          ),
          SizedBox(height: 8),
          Text(
            feedback['pickupDate'] ?? '',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
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