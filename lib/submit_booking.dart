import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppTheme {
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color backgroundBlack = Color(0xFF1E1E1E);
  static const Color cardBlack = Color(0xFF2A2A2A);
  static const Color textGrey = Color(0xFF8E8E8E);
  static const Color successGreen = Color(0xFF4CAF50);
}

class BookingSubmissionPage extends StatefulWidget {
  final String vehicleId;
  final Map<String, String> bookingDetails;

  const BookingSubmissionPage({
    required this.vehicleId,
    required this.bookingDetails,
  });

  @override
  _BookingSubmissionPageState createState() => _BookingSubmissionPageState();
}

class _BookingSubmissionPageState extends State<BookingSubmissionPage> {
  Map<String, dynamic> userDetails = {};
  Map<String, dynamic> vehicleDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .get();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          vehicleDetails = vehicleDoc.data() ?? {};
          userDetails = userDoc.data() ?? {};
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> submitBooking() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // First get the renter's ID from the vehicles collection
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .get();

      if (!vehicleDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle not found')),
        );
        return;
      }

      final renterId = vehicleDoc.data()?['user_id'];
      if (renterId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle owner information not found')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('bookings').add({
        'renteeId': user.uid, // renamed from userId to renteeId
        'renterId': renterId, // vehicle owner's ID
        'vehicleId': widget.vehicleId,
        'location': widget.bookingDetails['location'],
        'pickupDate': widget.bookingDetails['pickupDate'],
        'pickupTime': widget.bookingDetails['pickupTime'],
        'returnDate': widget.bookingDetails['returnDate'],
        'returnTime': widget.bookingDetails['returnTime'],
        'booking_status': 'pending',
        'renteeStatus': 'not processed',
        'renterStatus': 'not processed',
        'createdAt': Timestamp.now(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SubmissionSuccessPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildDetailSection(String title, List<Map<String, dynamic>> details) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBlack.withOpacity(0.8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: AppTheme.primaryYellow, width: 1),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.primaryYellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: details.map((detail) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        detail['label']!,
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        detail['value']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundBlack,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryYellow),
        ),
      );
    }

    final vehicleDetails = [
      {'label': 'Brand', 'value': this.vehicleDetails['vehicle_brand'] ?? ''},
      {'label': 'Model', 'value': this.vehicleDetails['vehicle_model'] ?? ''},
      {
        'label': 'Plate Number',
        'value': this.vehicleDetails['plate_number'] ?? ''
      },
      {
        'label': 'Transmission',
        'value': this.vehicleDetails['transmission_type'] ?? ''
      },
    ];

    final bookingDetails = [
      {'label': 'Location', 'value': widget.bookingDetails['location'] ?? ''},
      {
        'label': 'Pickup',
        'value':
            '${widget.bookingDetails['pickupDate']} at ${widget.bookingDetails['pickupTime']}'
      },
      {
        'label': 'Return',
        'value':
            '${widget.bookingDetails['returnDate']} at ${widget.bookingDetails['returnTime']}'
      },
    ];

    final userDetails = [
      {'label': 'Name', 'value': this.userDetails['username'] ?? ''},
      {'label': 'Matric No', 'value': this.userDetails['matricNo'] ?? ''},
      {'label': 'Course', 'value': this.userDetails['course'] ?? ''},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBlack,
        elevation: 0,
        title: Text(
          'Booking Details',
          style: TextStyle(
            color: AppTheme.primaryYellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection('Vehicle Details', vehicleDetails),
            _buildDetailSection('Booking Details', bookingDetails),
            _buildDetailSection('User Details', userDetails),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: submitBooking,
                    child: Text(
                      'CONFIRM',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SubmissionSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.successGreen,
                size: 80,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Booking Submitted Successfully!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Add navigation to status page
                print('Navigate to status page');
              },
              child: Text(
                'VIEW STATUS',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
