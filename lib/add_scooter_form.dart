import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddScooterForm extends StatefulWidget {
  @override
  _AddScooterFormState createState() => _AddScooterFormState();
}

class _AddScooterFormState extends State<AddScooterForm> {
  String _vehicleName = '';
  double _pricePerHour = 1.0;
  String _scooterType = 'Manual';
  bool _availability = true;

  final _scooterTypes = ['Manual', 'Electric'];

  final _formKey = GlobalKey<FormState>();

  void _saveScooter(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in. Please log in first.')),
      );
      return;
    }

    final String uid = user.uid; // Fetch the user's unique ID
    final int vehicleId = DateTime.now().millisecondsSinceEpoch;

    // Reference to the 'vehicles' collection
    DocumentReference vehicleDoc = FirebaseFirestore.instance
        .collection('vehicles') // Store in top-level vehicles collection
        .doc(vehicleId.toString());

    try {
      // Save vehicle data with user_id for relationship
      await vehicleDoc.set({
        'vehicle_id': vehicleId, // Unique ID for the vehicle
        'user_id': uid, // Foreign key to the 'users' table
        'vehicle_type': 'Scooter',
        'vehicle_name': _vehicleName,
        'price_per_hour': _pricePerHour,
        'scooter_type': _scooterType,
        'availability': _availability,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scooter saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving scooter: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellowColor = Color.fromARGB(255, 255, 204, 20);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vehicle'),
        backgroundColor: Colors.teal.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Vehicle Name Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Vehicle Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a vehicle name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _vehicleName = value!;
                  },
                ),

                SizedBox(height: 20),

                // Price per Hour Slider
                Text(
                    'Price per Hour (RM: ${_pricePerHour.toStringAsFixed(2)})'),
                Slider(
                  value: _pricePerHour,
                  min: 0.5,
                  max: 5.0,
                  divisions: 9,
                  label: 'RM ${_pricePerHour.toStringAsFixed(2)}',
                  onChanged: (value) {
                    setState(() {
                      _pricePerHour = value;
                    });
                  },
                  activeColor: yellowColor,
                  inactiveColor: Colors.grey.withOpacity(0.4),
                ),

                SizedBox(height: 20),

                // Scooter Type Choices
                Text('Scooter Type'),
                Wrap(
                  spacing: 10.0,
                  children: _scooterTypes.map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _scooterType == type,
                      onSelected: (selected) {
                        setState(() {
                          _scooterType = type;
                        });
                      },
                      selectedColor: yellowColor,
                    );
                  }).toList(),
                ),

                SizedBox(height: 20),

                // Save Button
                ElevatedButton(
                  onPressed: () => _saveScooter(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save Vehicle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
