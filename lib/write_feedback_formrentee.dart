import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WriteYourFeedback extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const WriteYourFeedback({
    Key? key,
    required this.bookingDetails,
  }) : super(key: key);

  @override
  _WriteYourFeedbackState createState() => _WriteYourFeedbackState();
}

class _WriteYourFeedbackState extends State<WriteYourFeedback> {
  int _rating = 0;
  bool _showFeedbackForm = false;
  String _feedbackType = '';
  Map<String, bool> _selectedFeedback = {};
  bool _isSubmitting = false;
  String _vehicleName = '';
  String _vehicleModel = '';

  @override
  void initState() {
    super.initState();
    _fetchVehicleDetails();
  }

  Map<String, dynamic> get safeBookingDetails {
    return {
      'vehicleId': widget.bookingDetails['vehicleId'] ?? '',
      'location': widget.bookingDetails['location'] ?? 'No location specified',
      'pickupDate': widget.bookingDetails['pickupDate'] ?? 'Not specified',
      'pickupTime': widget.bookingDetails['pickupTime'] ?? 'Not specified',
      'returnDate': widget.bookingDetails['returnDate'] ?? 'Not specified',
      'returnTime': widget.bookingDetails['returnTime'] ?? 'Not specified',
      'bookingId': widget.bookingDetails['bookingId'] ?? '',
      'renterId': widget.bookingDetails['renterId'] ?? '',
      'renteeId': widget.bookingDetails['renteeId'] ?? '',
    };
  }

  Future<void> _fetchVehicleDetails() async {
    try {
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('vehicle_id', isEqualTo: widget.bookingDetails['vehicleId'])
          .get();

      if (vehicleDoc.docs.isNotEmpty) {
        setState(() {
          _vehicleName = vehicleDoc.docs.first['vehicle_name'];
          _vehicleModel = vehicleDoc.docs.first['vehicle_model'];
        });
      }
    } catch (e) {
      print('Error fetching vehicle details: $e');
    }
  }

  final Map<String, List<String>> _renterFeedbackOptions = {
    'Communication': [
      'Very responsive and professional',
      'Good communication overall',
      'Delayed responses',
      'Poor communication'
    ],
    'Car Care': [
      'Returned car in perfect condition',
      'Car was mostly clean',
      'Minor cleanliness issues',
      'Car was not well maintained'
    ],
    'Punctuality': [
      'Perfect timing for pickup/return',
      'Minor delays',
      'Significant delays',
      'Missed scheduled times'
    ],
  };

  final Map<String, List<String>> _renteeFeedbackOptions = {
    'Car Condition': [
      'Car was exactly as advertised',
      'Minor issues but acceptable',
      'Several maintenance issues',
      'Major problems with the car'
    ],
    'Service': [
      'Excellent service experience',
      'Good overall experience',
      'Service needs improvement',
      'Poor service quality'
    ],
    'Value': [
      'Great value for money',
      'Reasonable pricing',
      'Somewhat overpriced',
      'Not worth the price'
    ],
  };

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      Map<String, dynamic> feedbackData = {
        'bookingId': widget.bookingDetails['bookingId'],
        'vehicleId': widget.bookingDetails['vehicleId'],
        'vehicleName': _vehicleName,
        'vehicleModel': _vehicleModel,
        'feedbackType': _feedbackType,
        'rating': _rating,
        'selectedFeedback': _getSelectedFeedbackList(),
        'timestamp': FieldValue.serverTimestamp(),
        'renterId': widget.bookingDetails['renterId'],
        'renteeId': widget.bookingDetails['renteeId'],
        'pickupDate': widget.bookingDetails['pickupDate'],
        'returnDate': widget.bookingDetails['returnDate'],
        'pickupTime': widget.bookingDetails['pickupTime'],
        'returnTime': widget.bookingDetails['returnTime'],
        'location': widget.bookingDetails['location'],
      };

      await FirebaseFirestore.instance.collection('feedback').add(feedbackData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting feedback: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  List<String> _getSelectedFeedbackList() {
    return _selectedFeedback.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key.split('-')[1])
        .toList();
  }

  Widget _buildFeedbackSection(String category, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.yellow[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: options.map((option) {
              String key = '$category-$option';
              return CheckboxListTile(
                title: Text(
                  option,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                value: _selectedFeedback[key] ?? false,
                activeColor: Colors.yellow[700],
                checkColor: Colors.black,
                onChanged: (bool? value) {
                  setState(() {
                    _selectedFeedback[key] = value ?? false;
                  });
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: Colors.yellow[700],
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Write Your Feedback'),
          backgroundColor: Colors.yellow[700],
          foregroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Card(
                  elevation: 8,
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.directions_car,
                                color: Colors.yellow[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Booking Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Vehicle', _vehicleName),
                        _buildDetailRow(
                            'Location', widget.bookingDetails['location']),
                        _buildDetailRow('Pickup',
                            '${widget.bookingDetails['pickupDate']} ${widget.bookingDetails['pickupTime']}'),
                        _buildDetailRow('Return',
                            '${widget.bookingDetails['returnDate']} ${widget.bookingDetails['returnTime']}'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!_showFeedbackForm) ...[
                Text(
                  'Who would you like to rate?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[700],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAnimatedButton(
                        'Rate Renter',
                        () => setState(() {
                          _feedbackType = 'renter';
                          _showFeedbackForm = true;
                        }),
                        Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAnimatedButton(
                        'Rate Rentee',
                        () => setState(() {
                          _feedbackType = 'rentee';
                          _showFeedbackForm = true;
                        }),
                        Icons.car_rental,
                      ),
                    ),
                  ],
                ),
              ],
              if (_showFeedbackForm) ...[
                Row(
                  children: [
                    Icon(
                      _feedbackType == 'renter'
                          ? Icons.person
                          : Icons.car_rental,
                      color: Colors.yellow[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rate your ${_feedbackType == 'renter' ? 'Renter' : 'Rentee'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow[700],
                          size: 32,
                        ),
                        onPressed: () => setState(() => _rating = index + 1),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                ..._feedbackType == 'renter'
                    ? _renterFeedbackOptions.entries
                        .map((e) => _buildFeedbackSection(e.key, e.value))
                    : _renteeFeedbackOptions.entries
                        .map((e) => _buildFeedbackSection(e.key, e.value)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Text(
                            'Submit Feedback',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.yellow[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(
      String text, VoidCallback onPressed, IconData icon) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
