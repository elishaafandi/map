import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingRequest extends StatefulWidget {
  @override
  _BookingRequest createState() => _BookingRequest();
}

class _BookingRequest extends State<BookingRequest> {
  String _selectedStatus = 'All';

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      Query bookingsQuery = FirebaseFirestore.instance.collection('bookings');

      if (_selectedStatus != 'All') {
        bookingsQuery = bookingsQuery.where('booking_status',
            isEqualTo: _selectedStatus.toLowerCase());
      }

      final bookingsSnapshot = await bookingsQuery.get();
      List<Map<String, dynamic>> bookingsWithDetails = [];

      for (var bookingDoc in bookingsSnapshot.docs) {
        final bookingData = bookingDoc.data() as Map<String, dynamic>;
        final vehicleId = bookingData['vehicleId'];

        // Convert Timestamp to formatted string
        if (bookingData['createdAt'] is Timestamp) {
          Timestamp timestamp = bookingData['createdAt'] as Timestamp;
          DateTime dateTime = timestamp.toDate();
          bookingData['createdAt'] = dateTime.toString(); // Or format as needed
        }

        // Fetch vehicle details
        final vehicleDetails = await _fetchVehicleDetails(vehicleId);

        if (vehicleDetails != null) {
          bookingsWithDetails.add({
            ...bookingData,
            'bookingId': bookingDoc.id,
            'vehicleName': vehicleDetails['vehicle_name'],
            'plateNumber': vehicleDetails['plate_number'],
          });
        }
      }

      return bookingsWithDetails;
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _fetchVehicleDetails(String vehicleId) async {
    try {
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicleId)
          .get();

      if (vehicleDoc.exists) {
        return vehicleDoc.data();
      }
      return null;
    } catch (e) {
      print('Error fetching vehicle details: $e');
      return null;
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      Map<String, dynamic> updateData = {
        'booking_status': newStatus,
      };

      // If status is approved, update renter and rentee status
      if (newStatus == 'approved') {
        updateData['renterStatus'] = 'booking_confirmed';
        updateData['renteeStatus'] = 'booking_confirmed';
      }

      // Update the booking document
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update(updateData);

      setState(() {}); // Refresh the list

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking status updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update booking status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Booking List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildStatusFilter('All'),
                SizedBox(width: 8),
                _buildStatusFilter('Pending'),
                SizedBox(width: 8),
                _buildStatusFilter('Approved'),
                SizedBox(width: 8),
                _buildStatusFilter('Rejected'),
                SizedBox(width: 8),
                _buildStatusFilter('Cancelled'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No bookings found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final booking = snapshot.data![index];
                    return _buildBookingCard(booking);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(String status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = (booking['booking_status'] ?? '').toString().toLowerCase();
    final isPending = status == 'pending';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['vehicleName'] ?? 'Unknown Vehicle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        booking['plateNumber'] ?? 'No plate number',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              booking['createdAt'] ?? 'No date',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow(
                Icons.location_on, booking['location'] ?? 'No location'),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              'Pickup: ${booking['pickupDate'] ?? 'N/A'} at ${booking['pickupTime'] ?? 'N/A'}',
            ),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'Return: ${booking['returnDate'] ?? 'N/A'} at ${booking['returnTime'] ?? 'N/A'}',
            ),
            if (isPending) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    'Accept',
                    Color(0xFF4CAF50),
                    () =>
                        _updateBookingStatus(booking['bookingId'], 'approved'),
                  ),
                  SizedBox(width: 12),
                  _buildActionButton(
                    'Reject',
                    Color(0xFFE53935),
                    () =>
                        _updateBookingStatus(booking['bookingId'], 'rejected'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.yellow,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
