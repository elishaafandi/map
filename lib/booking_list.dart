import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingList extends StatefulWidget {
  @override
  _BookingListState createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> {
  static const mainYellow = Color(0xFFFFD700);
  static const mainBlack = Color(0xFF000000);
  static const mainWhite = Color(0xFFFFFFFF);

  Future<void> _updateBookingStatus(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'booking_status': 'approved',
        'renteeStatus': 'booking confirmed',
      });

      // Refresh the page after updating
      setState(() {});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking approved successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update booking status'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('renteeId', isEqualTo: user.uid)
          .get();

      if (bookingsQuery.docs.isEmpty) return [];

      List<Map<String, dynamic>> bookingsWithDetails = [];

      for (var bookingDoc in bookingsQuery.docs) {
        final bookingData = bookingDoc.data();
        final vehicleId = bookingData['vehicleId'];
        final vehicleDetails = await _findVehicleDetails(vehicleId);

        if (vehicleDetails != null) {
          bookingsWithDetails.add({
            ...bookingData,
            'bookingId': bookingDoc.id,
            'vehicleName': vehicleDetails['vehicle_name'] ?? 'Unknown Vehicle',
            'vehicleType': vehicleDetails['vehicle_type'] ?? 'Unknown Type',
          });
        }
      }

      // Sort bookings: Pending first, then Approved, then Rejected
      bookingsWithDetails.sort((a, b) {
        final statusPriority = {
          'pending': 0,
          'approved': 1,
          'rejected': 2,
        };
        final statusA = (a['booking_status'] ?? 'pending').toLowerCase();
        final statusB = (b['booking_status'] ?? 'pending').toLowerCase();
        return (statusPriority[statusA] ?? 3)
            .compareTo(statusPriority[statusB] ?? 3);
      });

      return bookingsWithDetails;
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _findVehicleDetails(String vehicleId) async {
    try {
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicleId)
          .get();

      if (vehicleDoc.exists) {
        return vehicleDoc.data();
      }
    } catch (e) {
      print('Error fetching vehicle details: $e');
    }
    return null;
  }

  Color _getBookingStatusColor(String bookingStatus) {
    switch (bookingStatus.toLowerCase()) {
      case 'approved':
        return Colors.green[400]!;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return '✅';
      case 'pending':
        return '⏳';
      case 'rejected':
        return '❌';
      default:
        return '📋';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBlack,
      appBar: AppBar(
        backgroundColor: mainBlack,
        title: Text(
          'BOOKING LIST',
          style: TextStyle(
            color: mainYellow,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: mainYellow));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching bookings',
                style: TextStyle(color: mainWhite),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.car_rental, size: 64, color: mainYellow),
                  SizedBox(height: 16),
                  Text(
                    'No bookings found',
                    style: TextStyle(
                      color: mainWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final bookingStatus = booking['booking_status'] ?? 'pending';

              return Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: mainBlack,
                  border: Border.all(
                    color: _getBookingStatusColor(bookingStatus),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getBookingStatusColor(bookingStatus)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              booking['vehicleName'],
                              style: TextStyle(
                                color: mainYellow,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              if (bookingStatus.toLowerCase() == 'pending')
                                IconButton(
                                  icon: Icon(Icons.check_circle_outline,
                                      color: Colors.green),
                                  onPressed: () => _updateBookingStatus(
                                      booking['bookingId']),
                                  tooltip: 'Approve Booking',
                                ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getBookingStatusColor(bookingStatus)
                                      .withOpacity(0.1),
                                  border: Border.all(
                                    color:
                                        _getBookingStatusColor(bookingStatus),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getStatusEmoji(bookingStatus),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      bookingStatus[0].toUpperCase() +
                                          bookingStatus
                                              .substring(1)
                                              .toLowerCase(),
                                      style: TextStyle(
                                        color: _getBookingStatusColor(
                                            bookingStatus),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        booking['vehicleType'],
                        style: TextStyle(
                          color: mainWhite.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PICKUP',
                                  style: TextStyle(
                                    color: mainWhite.withOpacity(0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${booking['pickupDate']}\n${booking['pickupTime']}',
                                  style: TextStyle(
                                    color: mainWhite,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RETURN',
                                  style: TextStyle(
                                    color: mainWhite.withOpacity(0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${booking['returnDate']}\n${booking['returnTime']}',
                                  style: TextStyle(
                                    color: mainWhite,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
