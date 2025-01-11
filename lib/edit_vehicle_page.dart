import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditVehiclePage extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  EditVehiclePage({required this.vehicle});

  @override
  _EditVehiclePageState createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  late String _vehicleName;
  late String _vehicleBrand;
  late String _vehicleModel;
  late String _plateNo;
  late double _pricePerHour;
  late String _transmissionType;
  late String _fuelType;
  late String _seaterType;
  late String _motorcycleType;
  late String _scooterType;
  late String _bicycleType;
  late bool _availability;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _vehicleName = widget.vehicle['vehicle_name'] ?? '';
    _pricePerHour = (widget.vehicle['price_per_hour'] ?? 5.0).toDouble();
    _pricePerHour = _pricePerHour < 5.0 ? 5.0 : _pricePerHour;
    _pricePerHour = _pricePerHour > 30.0 ? 30.0 : _pricePerHour;
    _availability = widget.vehicle['availability'] ?? true;

    switch (widget.vehicle['type'].toLowerCase()) {
      case 'car':
        _vehicleBrand = widget.vehicle['vehicle_brand'] ?? '';
        _vehicleModel = widget.vehicle['vehicle_model'] ?? '';
        _plateNo = widget.vehicle['plate_number'] ?? '';
        _transmissionType = widget.vehicle['transmission_type'] ?? 'Automatic';
        _fuelType = widget.vehicle['fuel_type'] ?? 'Petrol';
        _seaterType = widget.vehicle['seater_type'] ?? '4';
        break;
      case 'motorcycle':
        _vehicleBrand = widget.vehicle['vehicle_brand'] ?? '';
        _vehicleModel = widget.vehicle['vehicle_model'] ?? '';
        _plateNo = widget.vehicle['plate_number'] ?? '';
        _motorcycleType = widget.vehicle['motorcycle_type'] ?? 'Standard';
        break;
      case 'scooter':
        _scooterType = widget.vehicle['scooter_type'] ?? 'Electric';
        break;
      case 'bicycle':
        _bicycleType = widget.vehicle['bicycle_type'] ?? 'Mountain';
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.yellow[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    Map<String, dynamic> vehicleData = {
      'vehicle_name': _vehicleName,
      'price_per_hour': _pricePerHour,
      'availability': _availability,
    };

    switch (widget.vehicle['type'].toLowerCase()) {
      case 'car':
        vehicleData.addAll({
          'vehicle_brand': _vehicleBrand,
          'vehicle_model': _vehicleModel,
          'plate_number': _plateNo,
          'transmission_type': _transmissionType,
          'fuel_type': _fuelType,
          'seater_type': _seaterType,
        });
        break;
      case 'motorcycle':
        vehicleData.addAll({
          'vehicle_brand': _vehicleBrand,
          'vehicle_model': _vehicleModel,
          'plate_number': _plateNo,
          'motorcycle_type': _motorcycleType,
        });
        break;
      case 'scooter':
        vehicleData.addAll({
          'scooter_type': _scooterType,
        });
        break;
      case 'bicycle':
        vehicleData.addAll({
          'bicycle_type': _bicycleType,
        });
        break;
    }

    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicle['id'])
          .update(vehicleData);
      _showSnackBar('Vehicle updated successfully');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error updating vehicle: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2A2A2A),
      appBar: AppBar(
        title: Text('Edit ${widget.vehicle['type']}',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.yellow[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/renter.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_road, size: 60, color: Colors.yellow[700]),
                    SizedBox(height: 16),
                    Text(
                      'Edit Your ${widget.vehicle['type']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Common Fields
                    _buildSection(
                      icon: Icons.directions_car,
                      title: 'Vehicle Details',
                      children: [
                        _buildTextField(
                          label: 'Vehicle Name',
                          hint: 'Enter vehicle name',
                          initialValue: _vehicleName,
                          icon: Icons.drive_file_rename_outline,
                          onSaved: (value) => _vehicleName = value!,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    
                    // Vehicle Type Specific Fields
                    if (widget.vehicle['type'].toLowerCase() == 'car' ||
                        widget.vehicle['type'].toLowerCase() == 'motorcycle')
                      ...[
                        _buildSection(
                          icon: Icons.info,
                          title: 'Vehicle Information',
                          children: [
                            _buildTextField(
                              label: 'Brand',
                              hint: 'Enter brand',
                              initialValue: _vehicleBrand,
                              icon: Icons.branding_watermark,
                              onSaved: (value) => _vehicleBrand = value!,
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              label: 'Model',
                              hint: 'Enter model',
                              initialValue: _vehicleModel,
                              icon: Icons.model_training,
                              onSaved: (value) => _vehicleModel = value!,
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              label: 'Plate Number',
                              hint: 'Enter plate number',
                              initialValue: _plateNo,
                              icon: Icons.credit_card,
                              onSaved: (value) => _plateNo = value!,
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                      ],

                    // Vehicle Specific Options
                    if (widget.vehicle['type'].toLowerCase() == 'car')
                      _buildSection(
                        icon: Icons.settings,
                        title: 'Car Specifications',
                        children: [
                          _buildChipSection(
                            icon: Icons.settings_applications,
                            title: 'Transmission',
                            options: ['Manual', 'Automatic'],
                            selectedValue: _transmissionType,
                            onSelected: (value) =>
                                setState(() => _transmissionType = value),
                          ),
                          SizedBox(height: 20),
                          _buildChipSection(
                            icon: Icons.local_gas_station,
                            title: 'Fuel Type',
                            options: ['Petrol', 'Diesel', 'Electric', 'Hybrid'],
                            selectedValue: _fuelType,
                            onSelected: (value) =>
                                setState(() => _fuelType = value),
                          ),
                          SizedBox(height: 20),
                          _buildChipSection(
                            icon: Icons.airline_seat_recline_normal,
                            title: 'Seater Type',
                            options: ['2', '4', '5', '7', '8'],
                            selectedValue: _seaterType,
                            onSelected: (value) =>
                                setState(() => _seaterType = value),
                          ),
                        ],
                      )
                    else if (widget.vehicle['type'].toLowerCase() == 'motorcycle')
                      _buildSection(
                        icon: Icons.motorcycle,
                        title: 'Motorcycle Type',
                        children: [
                          _buildChipSection(
                            icon: Icons.two_wheeler,
                            title: 'Type',
                            options: ['Standard', 'Sport', 'Cruiser', 'Off-road'],
                            selectedValue: _motorcycleType,
                            onSelected: (value) =>
                                setState(() => _motorcycleType = value),
                          ),
                        ],
                      )
                    else if (widget.vehicle['type'].toLowerCase() == 'scooter')
                      _buildSection(
                        icon: Icons.electric_scooter,
                        title: 'Scooter Type',
                        children: [
                          _buildChipSection(
                            icon: Icons.electric_moped,
                            title: 'Type',
                            options: ['Electric', 'Kick', 'Gas'],
                            selectedValue: _scooterType,
                            onSelected: (value) =>
                                setState(() => _scooterType = value),
                          ),
                        ],
                      )
                    else if (widget.vehicle['type'].toLowerCase() == 'bicycle')
                      _buildSection(
                        icon: Icons.pedal_bike,
                        title: 'Bicycle Type',
                        children: [
                          _buildChipSection(
                            icon: Icons.directions_bike,
                            title: 'Type',
                            options: ['Mountain', 'Road', 'Hybrid', 'Electric'],
                            selectedValue: _bicycleType,
                            onSelected: (value) =>
                                setState(() => _bicycleType = value),
                          ),
                        ],
                      ),

                    SizedBox(height: 24),
                    _buildSection(
                      icon: Icons.attach_money,
                      title: 'Pricing',
                      children: [_buildPriceSlider()],
                    ),
                    SizedBox(height: 24),
                    _buildSection(
                      icon: Icons.check_circle,
                      title: 'Availability',
                      children: [_buildAvailabilitySwitch()],
                    ),
                    SizedBox(height: 32),
                    _buildSaveButton(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String initialValue,
    required IconData icon,
    required void Function(String?) onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.yellow[700]),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.yellow[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.yellow[700]!.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.yellow[700]!.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.yellow[700]!),
        ),
        filled: true,
        fillColor: Color(0xFF2A2A2A),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Please enter a $label' : null,
      onSaved: onSaved,
    );
  }

  Widget _buildPriceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price per Hour',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'RM ${_pricePerHour.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.yellow[700],
            inactiveTrackColor: Colors.grey[800],
            thumbColor: Colors.yellow[700],
            overlayColor: Colors.yellow[700]!.withOpacity(0.2),
            valueIndicatorColor: Colors.yellow[700],
            valueIndicatorTextStyle: TextStyle(color: Colors.black),
          ),
          child: Slider(
            value: _pricePerHour.clamp(5.0, 30.0),
            min: 5.0,
            max: 30.0,
            divisions: 25,
            label: 'RM ${_pricePerHour.toStringAsFixed(2)}',
            onChanged: (value) => setState(() => _pricePerHour = value),
          ),
        ),
      ],
    );
  }

  Widget _buildChipSection({
    required IconData icon,
    required String title,
    required List<String> options,
    required String selectedValue,
    required void Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.yellow[700]),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              backgroundColor: Color(0xFF2A2A2A),
              selectedColor: Colors.yellow[700],
              checkmarkColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[300],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 20,
              color: Colors.yellow[700],
            ),
            SizedBox(width: 8),
            Text(
              'Available for Rent',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
              ),
            ),
          ],
        ),
        Switch(
          value: _availability,
          onChanged: (value) => setState(() => _availability = value),
          activeColor: Colors.yellow[700],
          inactiveTrackColor: Colors.grey[800],
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.yellow[700]!.withOpacity(0.5);
            }
            return Colors.grey[800];
          }),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveVehicle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}