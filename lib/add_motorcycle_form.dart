import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMotorcycleForm extends StatefulWidget {
  @override
  _AddMotorcycleFormState createState() => _AddMotorcycleFormState();
}

class _AddMotorcycleFormState extends State<AddMotorcycleForm> {
  final _formKey = GlobalKey<FormState>();

  String _vehicleBrand = '';
  String _vehicleModel = '';
  String _plateNo = '';
  double _pricePerHour = 1.0;
  String _motorcycleType = 'Cruiser';
  bool _availability = true;

  final _vehicleBrands = {
    'Yamaha': ['YZF-R15', 'MT-15'],
    'Honda': ['CBR500R', 'Rebel 500'],
    'Suzuki': ['GSX-R750', 'SV650'],
    'Kawasaki': ['Ninja ZX-6R', 'Z650'],
  };

  final _motorcycleTypes = ['Standard', 'Cruiser', 'Sport', 'Adventure'];

  String get _vehicleName => '$_vehicleBrand $_vehicleModel';

  void _saveVehicle(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnackBar(context, 'User not logged in. Please log in first.');
      return;
    }

    final vehicleId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicleId)
          .set({
        'vehicle_id': vehicleId,
        'user_id': user.uid,
        'vehicle_type': 'Motorcycle',
        'vehicle_name': _vehicleName,
        'vehicle_brand': _vehicleBrand,
        'vehicle_model': _vehicleModel,
        'plate_number': _plateNo,
        'price_per_hour': _pricePerHour,
        'motorcycle_type': _motorcycleType,
        'availability': _availability,
      });
      _showSnackBar(context, 'Motorcycle saved successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar(context, 'Error saving motorcycle: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.yellow[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2A2A2A),
      appBar: AppBar(
        title: Text('Add Motorcycle',
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
                  image: AssetImage('assets/images/motorcycle.png'),
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
                    Icon(Icons.motorcycle, size: 60, color: Colors.yellow[700]),
                    SizedBox(height: 16),
                    Text(
                      'List Your Motorcycle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enter your motorcycle details below',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
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
                    _buildSection(
                      icon: Icons.motorcycle,
                      title: 'Vehicle Details',
                      children: [
                        _buildDropdown(
                          label: 'Brand',
                          hint: 'Select motorcycle brand',
                          value: _vehicleBrand.isEmpty ? null : _vehicleBrand,
                          items: _vehicleBrands.keys.toList(),
                          onChanged: (value) {
                            setState(() {
                              _vehicleBrand = value!;
                              _vehicleModel = '';
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        if (_vehicleBrand.isNotEmpty)
                          _buildDropdown(
                            label: 'Model',
                            hint: 'Select motorcycle model',
                            value: _vehicleModel.isEmpty ? null : _vehicleModel,
                            items: _vehicleBrands[_vehicleBrand]!,
                            onChanged: (value) =>
                                setState(() => _vehicleModel = value!),
                          ),
                        SizedBox(height: 16),
                        _buildTextField(
                          label: 'Plate Number',
                          hint: 'Enter plate number',
                          icon: Icons.credit_card,
                          onSaved: (value) => _plateNo = value!,
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
                      icon: Icons.category,
                      title: 'Motorcycle Type',
                      children: [
                        _buildChipSection(
                          icon: Icons.two_wheeler,
                          title: 'Type',
                          options: _motorcycleTypes,
                          selectedValue: _motorcycleType,
                          onSelected: (value) =>
                              setState(() => _motorcycleType = value),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildSection(
                      icon: Icons.check_circle,
                      title: 'Availability',
                      children: [_buildAvailabilitySwitch()],
                    ),
                    SizedBox(height: 32),
                    _buildSaveButton(context),
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

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[700]!.withOpacity(0.3)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint, style: TextStyle(color: Colors.grey[400])),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: TextStyle(color: Colors.white)),
                ))
            .toList(),
        onChanged: onChanged,
        dropdownColor: Color(0xFF3A3A3A),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.yellow[700]),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: InputBorder.none,
        ),
        validator: (value) => value == null ? 'Please select a $label' : null,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required void Function(String?) onSaved,
  }) {
    return TextFormField(
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
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter a $label' : null,
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
            value: _pricePerHour,
            min: 0.5,
            max: 10.0,
            divisions: 19,
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
          inactiveThumbColor: Colors.grey[400],
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _saveVehicle(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Motorcycle',
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
