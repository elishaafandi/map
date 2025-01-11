import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ViewDeliveryRentee extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingDetails;

  const ViewDeliveryRentee({
    Key? key,
    required this.bookingId,
    required this.bookingDetails,
  }) : super(key: key);

  @override
  _ViewDeliveryRenteeState createState() => _ViewDeliveryRenteeState();
}

class _ViewDeliveryRenteeState extends State<ViewDeliveryRentee> {
  Timer? _timer;
  DateTime? _pickupDateTime;
  Duration _remainingTime = Duration.zero;
  bool _isExpired = false;
  Map<String, dynamic>? _renteeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final pickupDate = widget.bookingDetails['pickupDate'];
      final pickupTime = widget.bookingDetails['pickupTime'];

      // Debug print to check the incoming values
      print('Pickup Date: $pickupDate');
      print('Pickup Time: $pickupTime');

      // Split the time properly handling AM/PM
      final timeStr = pickupTime.toString().toUpperCase();
      final isPM = timeStr.contains('PM');
      final timeComponents =
          timeStr.replaceAll(RegExp(r'[APM]'), '').trim().split(':');

      var hours = int.parse(timeComponents[0]);
      final minutes = int.parse(timeComponents[1]);

      // Convert to 24-hour format if PM
      if (isPM && hours != 12) {
        hours += 12;
      } else if (!isPM && hours == 12) {
        hours = 0;
      }

      // Format hours and minutes properly
      final formattedHours = hours.toString().padLeft(2, '0');
      final formattedMinutes = minutes.toString().padLeft(2, '0');

      // Combine date and time
      _pickupDateTime =
          DateTime.parse('$pickupDate $formattedHours:$formattedMinutes:00');

      print('Parsed DateTime: $_pickupDateTime');

      // Start timer immediately
      _updateRemainingTime();
      _startTimer();

      // Fetch rentee data
      await _fetchRenteeData();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error initializing data: $e');
      print('Stack trace: ${e.toString()}');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchRenteeData() async {
    try {
      final renteeDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: widget.bookingDetails['renteeId'])
          .get();

      if (renteeDoc.docs.isNotEmpty && mounted) {
        setState(() => _renteeData = renteeDoc.docs.first.data());
      }
    } catch (e) {
      print('Error fetching rentee data: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    // Update every second with precise timing
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateRemainingTime();
      }
    });
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    final remaining = _pickupDateTime!.difference(now);

    setState(() {
      _remainingTime = remaining;
      _isExpired = remaining.isNegative;
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00:00:00";

    final days = duration.inDays;
    final hours = (duration.inHours % 24);
    final minutes = (duration.inMinutes % 60);
    final seconds = (duration.inSeconds % 60);

    return "${days.toString().padLeft(2, '0')}:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Widget _buildTimerDisplay() {
    final formattedTime = _formatDuration(_remainingTime);
    final parts = formattedTime.split(':');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeUnit(parts[0], 'Days'),
        _buildTimeSeparator(),
        _buildTimeUnit(parts[1], 'Hours'),
        _buildTimeSeparator(),
        _buildTimeUnit(parts[2], 'Mins'),
        _buildTimeSeparator(),
        _buildTimeUnit(parts[3], 'Secs'),
      ],
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black)),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.black.withOpacity(0.5),
        ),
      ),
    );
  }

  Future<void> _handleArrival() async {
    try {
      setState(() => _isLoading = true);

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'renterStatus': 'vehicle_delivery_confirmed',
        'renteeStatus': 'vehicle_delivery_confirmed',
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Delivery Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff1e1e1e),
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text('Delivery Details',
            style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.yellow[700],
              child: Column(
                children: [
                  Text(
                    _isExpired ? 'Pickup Time Passed' : 'Time Until Pickup',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTimerDisplay(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoCard(
                    'Pickup Details',
                    [
                      _buildInfoRow(
                          'Location', widget.bookingDetails['location']),
                      _buildInfoRow(
                          'Date', widget.bookingDetails['pickupDate']),
                      _buildInfoRow(
                          'Time', widget.bookingDetails['pickupTime']),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_renteeData != null)
                    _buildInfoCard(
                      'Rentee Details',
                      [
                        _buildInfoRow('Name', _renteeData!['username']),
                        _buildInfoRow('Contact', _renteeData!['contact']),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isExpired ? null : _handleArrival,
                      child: const Text('I Have Arrived'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.yellow[700]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.yellow[700]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
