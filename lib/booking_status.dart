import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'rentee_status_tracker.dart';
import 'string_extensions.dart';

class BookingStatus extends StatefulWidget {
  @override
  _BookingStatusState createState() => _BookingStatusState();
}

class _BookingStatusState extends State<BookingStatus> {
  static const mainYellow = Color(0xFFFFD700);
  static const mainBlack = Color(0xFF000000);
  static const mainWhite = Color(0xFFFFFFFF);

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('renteeId', isEqualTo: user.uid)
          .where('booking_status', isEqualTo: 'approved')
          .get();

      if (bookingsQuery.docs.isEmpty) return [];

      List<Map<String, dynamic>> bookingsWithDetails = [];

      for (var bookingDoc in bookingsQuery.docs) {
        final bookingData = bookingDoc.data();
        final vehicleId = bookingData['vehicleId'];
        final vehicleDetails = await _findVehicleDetails(vehicleId);

        if (vehicleDetails != null) {
          // Format vehicle details to match what RenteeStatusTracker expects
          final formattedVehicleDetails = {
            'name': vehicleDetails['vehicle_name'] ?? 'Unnamed Vehicle',
            'plateNo': vehicleDetails['plate_number'] ?? 'Unknown',
            'pricePerHour': vehicleDetails['price_per_hour'] ?? 0.0,
          };

          bookingsWithDetails.add({
            ...bookingData,
            'bookingId': bookingDoc.id,
            'vehicleName': _getVehicleName(vehicleDetails),
            'vehicleType': vehicleDetails['vehicle_type'] ?? 'Unknown Type',
            'vehicleDetails':
                formattedVehicleDetails, // Add formatted vehicle details
          });
        }
      }
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
        return {
          'collection': 'vehicles',
          ...vehicleDoc.data()!,
        };
      }
    } catch (e) {
      print('Error fetching vehicle details: $e');
    }
    return null;
  }

  String _getVehicleName(Map<String, dynamic> vehicleDetails) {
    return vehicleDetails['vehicle_name'] ?? 'Unnamed Vehicle';
  }

  Color _getCurrentStatusColor(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'booking confirmed':
        return Colors.green[400]!;
      case 'deposit required':
        return Colors.purple;
      case 'deposit paid':
        return Colors.blue;
      case 'car delivery':
        return Colors.indigo;
      case 'pre-inspection required':
        return Colors.cyan;
      case 'pre-inspection completed':
        return Colors.teal;
      case 'vehicle usage':
        return Colors.green;
      case 'return pending':
        return Colors.amber;
      case 'final payment required':
        return Colors.deepOrange;
      case 'completed':
        return mainYellow;
      case 'rated':
        return Colors.green[700]!;
      default:
        return Colors.grey;
    }
  }

  String _getCurrentStatusEmoji(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'booking confirmed':
        return '✅';
      case 'deposit required':
        return '💰';
      case 'deposit paid':
        return '✨';
      case 'car delivery':
        return '🚗';
      case 'pre-inspection required':
        return '🔍';
      case 'pre-inspection completed':
        return '📝';
      case 'vehicle usage':
        return '🚘';
      case 'return pending':
        return '↩️';
      case 'final payment required':
        return '💳';
      case 'completed':
        return '🎉';
      case 'rated':
        return '⭐';
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
          'APPROVED BOOKINGS',
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
                    'No approved bookings found',
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
              final currentStatus =
                  booking['current_status'] ?? 'booking confirmed';

              return Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: mainBlack,
                  border: Border.all(
                    color: _getCurrentStatusColor(currentStatus),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getCurrentStatusColor(currentStatus)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RenteeStatusTracker(
                            bookingDetails: {
                              ...booking,
                              'name': booking['vehicleDetails']['name'],
                              'plateNo': booking['vehicleDetails']['plateNo'],
                              'pricePerHour': booking['vehicleDetails']
                                  ['pricePerHour'],
                            },
                          ),
                        ),
                      );
                    },
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
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCurrentStatusColor(currentStatus)
                                      .withOpacity(0.1),
                                  border: Border.all(
                                    color:
                                        _getCurrentStatusColor(currentStatus),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getCurrentStatusEmoji(currentStatus),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      currentStatus[0].toUpperCase() +
                                          currentStatus
                                              .substring(1)
                                              .toLowerCase(),
                                      style: TextStyle(
                                        color: _getCurrentStatusColor(
                                            currentStatus),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: mainYellow,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                booking['location'],
                                style: TextStyle(
                                  color: mainWhite,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
