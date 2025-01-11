import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostInspectionForm extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingDetails;

  const PostInspectionForm({
    super.key,
    required this.bookingId,
    required this.bookingDetails,
  });

  @override
  _PostInspectionFormState createState() => _PostInspectionFormState();
}

class _PostInspectionFormState extends State<PostInspectionForm> {
  final _formKey = GlobalKey<FormState>();
  String _carCondition = '';
  String _inspectionComments = '';
  Map<String, String> dropdownSelections = {
    'Exterior Condition': '',
    'Tires': '',
    'Interior Condition': '',
    'Fuel Level': '',
    'Lights and Signals': '',
    'Engine Sound': '',
    'Brakes': '',
  };
  bool _isSubmitting = false;

  // Define constant colors to match RenteeStatusTracker theme
  static const mainBlack = Color(0xFF000000);
  static const mainYellow = Color(0xFFFFD700);
  static const mainWhite = Color(0xFFFFFFFF);
  static const cardBackground = Color(0xFF1A1A1A);
  static const textGrey = Color(0xFF9E9E9E);

  Widget _buildDropdownField(String labelText, List<String> items,
      {IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mainYellow.withOpacity(0.3)),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: textGrey),
          prefixIcon: icon != null
              ? Icon(icon, color: mainYellow.withOpacity(0.7))
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        dropdownColor: cardBackground,
        style: TextStyle(color: mainWhite),
        value: dropdownSelections[labelText]!.isEmpty
            ? null
            : dropdownSelections[labelText],
        items: [
          DropdownMenuItem<String>(
            value: null,
            child:
                Text('Select ${labelText}', style: TextStyle(color: textGrey)),
          ),
          ...items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
        ],
        onChanged: (String? newValue) {
          setState(() {
            dropdownSelections[labelText] = newValue ?? '';
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $labelText';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _saveToFirebase() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        _formKey.currentState?.save();

        // Only include non-empty selections
        final Map<String, String> nonEmptySelections = {};
        dropdownSelections.forEach((key, value) {
          if (value.isNotEmpty) {
            nonEmptySelections[key] = value;
          }
        });

        // Safely access bookingDetails with null checks
        final vehicleId = widget.bookingDetails['vehicleId']?.toString() ?? '';
        final vehicleName = widget.bookingDetails['name']?.toString() ?? '';
        final pricePerHour =
            widget.bookingDetails['pricePerHour']?.toString() ?? '';
        final pickupDate =
            widget.bookingDetails['pickupDate']?.toString() ?? '';
        final returnDate =
            widget.bookingDetails['returnDate']?.toString() ?? '';

        await FirebaseFirestore.instance
            .collection('post_inspection_forms')
            .add({
          'vehicleId': vehicleId,
          'bookingId': widget.bookingId,
          'vehicleName': vehicleName,
          'pricePerHour': pricePerHour,
          'pickupDate': pickupDate,
          'returnDate': returnDate,
          'carCondition': _carCondition,
          'inspectionComments': _inspectionComments,
          ...nonEmptySelections,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .update({
          'status': 'Post-Inspection Completed',
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        if (vehicleId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('vehicles')
              .doc(vehicleId)
              .update({
            'status': 'Post-Inspection Completed',
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post-inspection form submitted successfully!'),
            backgroundColor: mainYellow,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving form: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_formKey.currentState?.validate() ?? false) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: cardBackground,
              title:
                  Text('Discard Changes?', style: TextStyle(color: mainYellow)),
              content: Text(
                'You have unsaved changes. Are you sure you want to go back?',
                style: TextStyle(color: mainWhite),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('No', style: TextStyle(color: textGrey)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Yes', style: TextStyle(color: mainYellow)),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: mainBlack,
        appBar: AppBar(
          title: Text(
            'POST-INSPECTION FORM',
            style: TextStyle(
              color: mainYellow,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          backgroundColor: mainBlack,
          elevation: 0,
          iconTheme: IconThemeData(color: mainWhite),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildVehicleInfoCard(),
                    SizedBox(height: 24),
                    _buildInspectionSection(),
                    SizedBox(height: 24),
                    _buildConditionChecklist(),
                    SizedBox(height: 32),
                    _buildSubmitButton(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (_isSubmitting)
              Container(
                color: Colors.black87,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(mainYellow),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mainYellow.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: mainYellow.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Information',
            style: TextStyle(
              color: mainYellow,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Divider(color: mainYellow.withOpacity(0.2), height: 24),
          _buildInfoRow('Vehicle ID',
              widget.bookingDetails['vehicleId']?.toString() ?? 'N/A'),
          _buildInfoRow('Vehicle Name',
              widget.bookingDetails['name']?.toString() ?? 'N/A'),
          _buildInfoRow('Price/Hour',
              'RM${(widget.bookingDetails['pricePerHour']?.toString() ?? '0.00')}'),
          _buildInfoRow('Pickup',
              widget.bookingDetails['pickupDate']?.toString() ?? 'N/A'),
          _buildInfoRow('Return',
              widget.bookingDetails['returnDate']?.toString() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: mainWhite,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General Inspection',
          style: TextStyle(
            color: mainYellow,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 16),
        _buildTextField(
          'Car Condition',
          TextInputType.text,
          onSaved: (value) => _carCondition = value!,
          icon: Icons.directions_car,
        ),
        SizedBox(height: 16),
        _buildTextField(
          'Inspection Comments',
          TextInputType.multiline,
          onSaved: (value) => _inspectionComments = value!,
          icon: Icons.comment,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildConditionChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition Checklist',
          style: TextStyle(
            color: mainYellow,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 16),
        _buildDropdownField('Exterior Condition', ['Good', 'Not Good'],
            icon: Icons.car_repair),
        SizedBox(height: 12),
        _buildDropdownField('Tires', ['Good', 'Not Good'],
            icon: Icons.tire_repair),
        SizedBox(height: 12),
        _buildDropdownField('Interior Condition', ['Good', 'Not Good'],
            icon: Icons.airline_seat_recline_normal),
        SizedBox(height: 12),
        _buildDropdownField('Fuel Level', ['Full', '¾', '½', '¼', 'Empty'],
            icon: Icons.local_gas_station),
        SizedBox(height: 12),
        _buildDropdownField('Lights and Signals', ['Good', 'Not Good'],
            icon: Icons.highlight),
        SizedBox(height: 12),
        _buildDropdownField('Engine Sound', ['Good', 'Not Good'],
            icon: Icons.engineering),
        SizedBox(height: 12),
        _buildDropdownField('Brakes', ['Good', 'Not Good'],
            icon: Icons.warning),
      ],
    );
  }

  Widget _buildTextField(
    String labelText,
    TextInputType inputType, {
    String? initialValue,
    Function(String?)? onSaved,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mainYellow.withOpacity(0.3)),
      ),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: textGrey),
          prefixIcon: icon != null
              ? Icon(icon, color: mainYellow.withOpacity(0.7))
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: TextStyle(color: mainWhite),
        keyboardType: inputType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _saveToFirebase,
      style: ElevatedButton.styleFrom(
        backgroundColor: mainYellow,
        foregroundColor: mainBlack,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isSubmitting)
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(mainBlack),
                ),
              ),
            ),
          Text(
            _isSubmitting ? 'Submitting...' : 'Submit Inspection',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
