import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movease/renter_status_tracker.dart';

class PostInspectionConfirmation extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PostInspectionConfirmation({
    Key? key,
    required this.bookingDetails,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PostInspectionConfirmation> createState() =>
      _PostInspectionConfirmationState();
}

class _PostInspectionConfirmationState
    extends State<PostInspectionConfirmation> {
  bool isLoading = true;
  Map<String, dynamic>? inspectionFormDetails;

  void onConfirm() async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingDetails['bookingId'])
          .update({
        'renteeStatus': 'post_inspection_confirmed',
      });

      widget.onConfirm();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RenterStatusTracker(
            bookingDetails: widget.bookingDetails,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchInspectionFormDetails();
  }

  Future<void> _fetchInspectionFormDetails() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('post_inspection_forms')
          .where('bookingId', isEqualTo: widget.bookingDetails['bookingId'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          inspectionFormDetails = querySnapshot.docs.first.data();
          isLoading = false;
        });
      } else {
        throw Exception('No inspection form found for this booking');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading inspection form: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xff1e1e1e),
        appBar: AppBar(
          title: const Text(
            'Inspection Form',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white.withOpacity(0.05),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.yellow,
          ),
        ),
      );
    }

    if (inspectionFormDetails == null) {
      return Scaffold(
        backgroundColor: const Color(0xff1e1e1e),
        appBar: AppBar(
          title: const Text(
            'Post Inspection Form',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white.withOpacity(0.05),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'No inspection form found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Rest of your UI code remains the same as before
    return Scaffold(
      backgroundColor: const Color(0xff1e1e1e),
      appBar: AppBar(
        title: const Text(
          'Post Inspection Form',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.05),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade700,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle Inspection Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inspection details submitted by renter',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildCard(
                      'Vehicle Information',
                      [
                        _buildDetailRow(
                          'Vehicle Name',
                          inspectionFormDetails!['vehicleName'] ?? 'N/A',
                          Icons.directions_car,
                        ),
                        _buildDetailRow(
                          'Vehicle ID',
                          inspectionFormDetails!['vehicleId'] ?? 'N/A',
                          Icons.confirmation_number,
                        ),
                        _buildDetailRow(
                          'Pickup Date',
                          inspectionFormDetails!['pickupDate'] ?? 'N/A',
                          Icons.calendar_today,
                        ),
                        _buildDetailRow(
                          'Return Date',
                          inspectionFormDetails!['returnDate'] ?? 'N/A',
                          Icons.calendar_view_day,
                        ),
                        _buildDetailRow(
                          'Price per Hour',
                          'RM ${inspectionFormDetails!['pricePerHour'].toString()}',
                          Icons.attach_money,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      'Inspection Details',
                      [
                        _buildDetailRow(
                          'Car Condition',
                          inspectionFormDetails!['carCondition'] ?? 'N/A',
                          Icons.car_repair,
                        ),
                        _buildDetailRow(
                          'Exterior Condition',
                          inspectionFormDetails!['Exterior Condition'] ?? 'N/A',
                          Icons.car_crash,
                        ),
                        _buildDetailRow(
                          'Interior Condition',
                          inspectionFormDetails!['Interior Condition'] ?? 'N/A',
                          Icons.airline_seat_recline_normal,
                        ),
                        _buildDetailRow(
                          'Tires',
                          inspectionFormDetails!['Tires'] ?? 'N/A',
                          Icons.tire_repair,
                        ),
                        _buildDetailRow(
                          'Fuel Level',
                          inspectionFormDetails!['Fuel Level'] ?? 'N/A',
                          Icons.local_gas_station,
                        ),
                        _buildDetailRow(
                          'Lights and Signals',
                          inspectionFormDetails!['Lights and Signals'] ?? 'N/A',
                          Icons.light,
                        ),
                        _buildDetailRow(
                          'Engine Sound',
                          inspectionFormDetails!['Engine Sound'] ?? 'N/A',
                          Icons.engineering,
                        ),
                        _buildDetailRow(
                          'Brakes',
                          inspectionFormDetails!['Brakes'] ?? 'N/A',
                          Icons.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildNotesCard(
                      'Additional Comments',
                      inspectionFormDetails!['inspectionComments'] ?? 'N/A',
                    ),
                    const SizedBox(height: 100), // Space for buttons
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff1e1e1e),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          inspectionFormDetails != null ? onConfirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Your existing helper widget methods (_buildCard, _buildDetailRow, _buildNotesCard) remain the same
  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.yellow.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(String title, String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_alt_outlined,
                color: Colors.yellow.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            notes,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
