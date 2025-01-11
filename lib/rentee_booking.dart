import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'submit_booking.dart';

class AppTheme {
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color backgroundBlack = Color(0xFF1E1E1E);
  static const Color cardBlack = Color(0xFF2A2A2A);
  static const Color textGrey = Color(0xFF8E8E8E);
}

extension StringCapitalization on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class RenteeBook extends StatefulWidget {
  final String vehicleId;
  RenteeBook({required this.vehicleId});
  @override
  _RenteeBookState createState() => _RenteeBookState();
}

class _RenteeBookState extends State<RenteeBook> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _pickupTimeController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _returnTimeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _vehicleDetails;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchVehicleDetails();
  }

  void _fetchVehicleDetails() async {
    try {
      print('Fetching vehicle with ID: ${widget.vehicleId}');

      // Query the vehicles collection
      final vehicleRef = FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId);
      final vehicleSnapshot = await vehicleRef.get();

      if (vehicleSnapshot.exists) {
        Map<String, dynamic> vehicleData = vehicleSnapshot.data()!;
        String userId = vehicleData['user_id'];

        // Query users collection using the user_id directly
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userSnapshot.exists) {
          Map<String, dynamic> userData = userSnapshot.data()!;
          print('User data found: $userData'); // Debug log

          setState(() {
            _vehicleDetails = {
              'id': widget.vehicleId,
              ...vehicleData,
              ...userData, // This will include all user fields
            };
          });
        } else {
          print('No user found for ID: $userId');
        }

        print('Final vehicle details: $_vehicleDetails'); // Debug log
      }
    } catch (e) {
      print('Error fetching details: $e');
    }
  }

  Widget _buildRenterDetailsCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Renter Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildRenterDetailRow('Name', _vehicleDetails!['username']),
          _buildRenterDetailRow('Contact', _vehicleDetails!['contact']),
          _buildRenterDetailRow('Email', _vehicleDetails!['email']),
        ],
      ),
    );
  }

  void _logVehicleDetails(Map<String, dynamic> data, String collection) {
    print("Vehicle Details for $collection:");

    // Get the vehicle type from the data
    final vehicleType = data['vehicle_type'];

    // Common fields for all vehicle types
    print('Vehicle Type: ${data['vehicle_type']}');
    print('Availability: ${data['availability']}');
    print('Price per Hour: ${data['price_per_hour']}');
    print('User ID: ${data['user_id']}');

    // Specific fields based on vehicle type
    switch (vehicleType) {
      case 'Car':
        print('Vehicle Name: ${data['vehicle_name']}');
        print('Vehicle Brand: ${data['vehicle_brand']}');
        print('Vehicle Model: ${data['vehicle_model']}');
        print('Plate Number: ${data['plate_number']}');
        print('Transmission: ${data['transmission_type']}');
        print('Fuel Type: ${data['fuel_type']}');
        print('Seater Type: ${data['seater_type']}');
        break;

      case 'Motorcycle':
        print('Vehicle Name: ${data['vehicle_name']}');
        print('Vehicle Brand: ${data['vehicle_brand']}');
        print('Vehicle Model: ${data['vehicle_model']}');
        print('Plate Number: ${data['plate_number']}');
        print('Motorcycle Type: ${data['motorcycle_type']}');
        break;

      case 'Bicycle':
        print('Vehicle Name: ${data['vehicle_name']}');
        print('Bicycle Type: ${data['bicycle_type']}');
        break;

      case 'Scooter':
        print('Vehicle Name: ${data['vehicle_name']}');
        print('Scooter Type: ${data['scooter_type']}');
        break;

      default:
        print('Unknown vehicle type');
        break;
    }
  }

  Widget _buildVehicleDetails() {
    if (_vehicleDetails == null) {
      return Center(
          child: CircularProgressIndicator(color: AppTheme.primaryYellow));
    }

    return Container(
      color: AppTheme.backgroundBlack,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: Image.asset(
                'assets/images/${_vehicleDetails!['vehicle_name'].toString().toLowerCase()}.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.directions_car,
                  size: 100,
                  color: AppTheme.primaryYellow,
                ),
              ),
            ),

            // Vehicle name and specs
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _vehicleDetails!['vehicle_name'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Specifications grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSpecBox('Transmission',
                          _vehicleDetails!['transmission_type']),
                      _buildSpecBox('Fuel', _vehicleDetails!['fuel_type']),
                      _buildSpecBox('Seats', _vehicleDetails!['seater_type']),
                    ],
                  ),

                  SizedBox(height: 20),
                  // Price section
                  _buildPriceSection(),

                  SizedBox(height: 20),
                  // Renter details
                  _buildRenterDetailsCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecBox(String title, String value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final hourlyRate = _vehicleDetails!['price_per_hour'];
    final dayRate = hourlyRate * 24;
    final weekRate = dayRate * 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRateBox('Day Rate', dayRate),
            _buildRateBox('Week Rate', weekRate),
          ],
        ),
      ],
    );
  }

  Widget _buildRateBox(String title, double amount) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenterDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textGrey)),
          Text(value ?? 'N/A', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSpecificationsGrid() {
    List<Map<String, String>> specs = _getVehicleSpecs();

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8, // Reduced from 12
        mainAxisSpacing: 8, // Reduced from 12
        childAspectRatio: 1.8, // Adjusted from 2.5 to give more height to boxes
      ),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(4), // Reduced padding from 8
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                specs[index]['title'] ?? '',
                style: TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 11), // Reduced font size
              ),
              SizedBox(height: 2), // Reduced from 4
              Text(
                specs[index]['value'] ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Added to center text
                overflow: TextOverflow.ellipsis, // Handle long text
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, String>> _getVehicleSpecs() {
    final vehicleType = _vehicleDetails!['vehicle_type'];
    List<Map<String, String>> specs = [];

    switch (vehicleType) {
      case 'Car':
        specs = [
          {
            'title': 'Transmission',
            'value': _vehicleDetails!['transmission_type']
          },
          {'title': 'Fuel', 'value': _vehicleDetails!['fuel_type']},
          {'title': 'Seats', 'value': _vehicleDetails!['seater_type']},
        ];
        break;
      case 'Motorcycle':
        specs = [
          {'title': 'Brand', 'value': _vehicleDetails!['vehicle_brand']},
          {'title': 'Type', 'value': _vehicleDetails!['motorcycle_type']},
          {'title': 'Model', 'value': _vehicleDetails!['vehicle_model']},
        ];
        break;
      default:
        specs = [
          {'title': 'Type', 'value': vehicleType},
          {'title': 'Status', 'value': _vehicleDetails!['availability']},
        ];
    }
    return specs;
  }

  void _showBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => _buildBookingForm(),
      ),
    );
  }

  Widget _buildBookingForm() {
    return Container(
      color: AppTheme.backgroundBlack,
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildStyledFormField(
                      controller: _locationController,
                      label: 'Pickup Location',
                      icon: Icons.location_on,
                      onIconPressed: _showLocationSuggestions,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStyledFormField(
                            controller: _pickupDateController,
                            label: 'Pickup Date',
                            icon: Icons.calendar_today,
                            onIconPressed: () =>
                                _selectDate(_pickupDateController),
                            readOnly: true,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildStyledFormField(
                            controller: _pickupTimeController,
                            label: 'Pickup Time',
                            icon: Icons.access_time,
                            onIconPressed: () =>
                                _selectTime(_pickupTimeController),
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStyledFormField(
                            controller: _returnDateController,
                            label: 'Return Date',
                            icon: Icons.calendar_today,
                            onIconPressed: () =>
                                _selectDate(_returnDateController),
                            readOnly: true,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildStyledFormField(
                            controller: _returnTimeController,
                            label: 'Return Time',
                            icon: Icons.access_time,
                            onIconPressed: () =>
                                _selectTime(_returnTimeController),
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'SUBMIT BOOKING',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _validateBookingDates() &&
        _validateBookingTimes()) {
      Map<String, String> bookingDetails = {
        'location': _locationController.text,
        'pickupDate': _pickupDateController.text,
        'pickupTime': _pickupTimeController.text,
        'returnDate': _returnDateController.text,
        'returnTime': _returnTimeController.text,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSubmissionPage(
            vehicleId: widget.vehicleId,
            bookingDetails: bookingDetails,
          ),
        ),
      );
    }
  }

  Widget _buildStyledFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function() onIconPressed,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textGrey),
        suffixIcon: IconButton(
          icon: Icon(icon, color: AppTheme.primaryYellow),
          onPressed: onIconPressed,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.textGrey),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primaryYellow),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppTheme.cardBlack,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  static const List<Widget> _pages = [
    Center(child: Text('Booking Status', style: TextStyle(fontSize: 20))),
    Center(child: Text('Feedback', style: TextStyle(fontSize: 20))),
    Center(child: Text('Notifications', style: TextStyle(fontSize: 20))),
    Center(child: Text('Profile', style: TextStyle(fontSize: 20))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLocationSuggestions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Select Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(color: AppTheme.textGrey),
              Expanded(
                child: ListView(
                  children: ['KTDI', 'KTHO', 'KDSE']
                      .map((location) => ListTile(
                            title: Text(
                              location,
                              style: TextStyle(color: Colors.white),
                            ),
                            tileColor: AppTheme.cardBlack,
                            hoverColor: AppTheme.primaryYellow.withOpacity(0.1),
                            onTap: () {
                              setState(() {
                                _locationController.text = location;
                              });
                              Navigator.pop(context);
                            },
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    // Get current date
    DateTime now = DateTime.now();

    // Calculate minimum allowed date (2 days from now)
    DateTime minDate = now.add(Duration(days: 2));

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: minDate,
      firstDate: minDate,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryYellow,
              onPrimary: Colors.black,
              surface: AppTheme.cardBlack,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppTheme.backgroundBlack,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryYellow,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  // Add these constants at the top of the class
  final TimeOfDay _openingTime = TimeOfDay(hour: 8, minute: 0); // 8 AM
  final TimeOfDay _closingTime = TimeOfDay(hour: 22, minute: 0); // 10 PM

// Helper method to convert TimeOfDay to comparable double
  double _timeToDouble(TimeOfDay time) => time.hour + time.minute / 60.0;

// Updated time selection method that enforces hourly selections
  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay initialTime = _getValidInitialTime();

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.backgroundBlack,
              hourMinuteTextColor: Colors.white,
              dialBackgroundColor: AppTheme.cardBlack,
              dialHandColor: AppTheme.primaryYellow,
              dialTextColor: Colors.white,
              entryModeIconColor: AppTheme.primaryYellow,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryYellow,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Force the minutes to 00 to ensure hourly selections only
      picked = TimeOfDay(hour: picked.hour, minute: 0);

      // Validate if selected time is within operating hours
      if (_timeToDouble(picked) < _timeToDouble(_openingTime) ||
          _timeToDouble(picked) > _timeToDouble(_closingTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a time between 8 AM and 10 PM'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // For return time, validate minimum 1 hour difference
      if (controller == _returnTimeController &&
          _pickupTimeController.text.isNotEmpty) {
        TimeOfDay pickupTime = _parseTimeString(_pickupTimeController.text);
        if (_timeToDouble(picked) <= _timeToDouble(pickupTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Return time must be at least 1 hour after pickup time'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      setState(() {
        // Format time to show only hours, ensuring 2-digit format
        String hour = picked!.hour.toString().padLeft(2, '0');
        controller.text = '$hour:00';
      });
    }
  }

// Helper method to get valid initial time
  TimeOfDay _getValidInitialTime() {
    final now = TimeOfDay.now();

    // If current time is before opening, return opening time
    if (_timeToDouble(now) < _timeToDouble(_openingTime)) {
      return _openingTime;
    }

    // If current time is after closing, return opening time for next day
    if (_timeToDouble(now) > _timeToDouble(_closingTime)) {
      return _openingTime;
    }

    // Round current time to next hour
    return TimeOfDay(
      hour: now.hour + 1,
      minute: 0,
    );
  }

// Helper method to parse time string back to TimeOfDay
  TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

// Update the validation function to include time validation
  bool _validateBookingTimes() {
    if (_pickupTimeController.text.isEmpty ||
        _returnTimeController.text.isEmpty) {
      return false;
    }

    TimeOfDay pickupTime = _parseTimeString(_pickupTimeController.text);
    TimeOfDay returnTime = _parseTimeString(_returnTimeController.text);

    // Validate pickup time is within operating hours
    if (_timeToDouble(pickupTime) < _timeToDouble(_openingTime) ||
        _timeToDouble(pickupTime) > _timeToDouble(_closingTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pickup time must be between 8 AM and 10 PM'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate return time is within operating hours
    if (_timeToDouble(returnTime) < _timeToDouble(_openingTime) ||
        _timeToDouble(returnTime) > _timeToDouble(_closingTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Return time must be between 8 AM and 10 PM'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate minimum 1 hour difference
    if (_timeToDouble(returnTime) <= _timeToDouble(pickupTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Return time must be at least 1 hour after pickup time'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  bool _validateBookingDates() {
    if (_pickupDateController.text.isEmpty ||
        _returnDateController.text.isEmpty) {
      return false;
    }

    DateTime now = DateTime.now();
    DateTime minBookingDate = now.add(Duration(days: 2));
    DateTime pickupDate = DateTime.parse(_pickupDateController.text);
    DateTime returnDate = DateTime.parse(_returnDateController.text);

    // Check if pickup date is at least 2 days from now
    if (pickupDate.isBefore(minBookingDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking must be made at least 2 days in advance'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check if return date is after pickup date
    if (returnDate.isBefore(pickupDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Return date must be after pickup date'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryYellow),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Book Vehicle',
          style: TextStyle(
            color: AppTheme.primaryYellow,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.cardBlack,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildVehicleDetails(),
                // Add padding at bottom to prevent content from being hidden behind the price bar
                SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBlack,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Price per hour',
                        style: TextStyle(color: AppTheme.textGrey),
                      ),
                      Text(
                        '\$${_vehicleDetails?['price_per_hour'].toStringAsFixed(2)}/hr',
                        style: TextStyle(
                          color: AppTheme.primaryYellow,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _showBookingSheet(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
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
}
