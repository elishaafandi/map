import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movease/car_delivery_rentee.dart';
import 'package:movease/final_payment.dart';
import 'package:movease/post_inspection_confirm.dart';
import 'package:movease/rental_status_handler.dart';
import 'package:movease/write_feedback_formrentee.dart';
import 'rental_constants.dart';
import 'package:movease/pay_deposit.dart';
import 'package:movease/pre_inspection_form.dart';
import 'dart:async';

class RenteeStatusTracker extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  RenteeStatusTracker({required this.bookingDetails});

  @override
  _RenteeStatusTrackerState createState() => _RenteeStatusTrackerState();
}

class _RenteeStatusTrackerState extends State<RenteeStatusTracker> {
  List<Map<String, dynamic>> statusSteps = [];
  bool isLoading = false;
  Map<String, dynamic>? vehicleDetails;
  late Map<String, dynamic> currentBookingDetails;
  late StreamSubscription<DocumentSnapshot> _bookingSubscription;

  @override
  void initState() {
    super.initState();
    currentBookingDetails = Map<String, dynamic>.from(widget.bookingDetails);
    initializeRenteeStatusSteps();
    fetchVehicleDetails();
    _setupBookingListener();
  }

  Future<void> fetchVehicleDetails() async {
    try {
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.bookingDetails['vehicleId'])
          .get();

      if (vehicleDoc.exists) {
        setState(() {
          vehicleDetails = vehicleDoc.data();
        });
      }
    } catch (e) {
      print('Error fetching vehicle details: $e');
    }
  }

  double _calculateTotalHours() {
    final pickupDate = DateTime.parse(widget.bookingDetails['pickupDate']);
    final returnDate = DateTime.parse(widget.bookingDetails['returnDate']);
    final pickupTime = widget.bookingDetails['pickupTime'].split(':');
    final returnTime = widget.bookingDetails['returnTime'].split(':');

    final start = DateTime(
      pickupDate.year,
      pickupDate.month,
      pickupDate.day,
      int.parse(pickupTime[0]),
      int.parse(pickupTime[1]),
    );

    final end = DateTime(
      returnDate.year,
      returnDate.month,
      returnDate.day,
      int.parse(returnTime[0]),
      int.parse(returnTime[1]),
    );

    return end.difference(start).inHours.toDouble();
  }

  void _setupBookingListener() {
    // Set up a real-time listener for the booking document
    _bookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingDetails['bookingId'])
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          // Update the current booking details with the latest data
          currentBookingDetails = {
            ...currentBookingDetails,
            ...snapshot.data()!,
          };
          initializeRenteeStatusSteps(); // Reinitialize steps with new data
        });
      }
    });
  }

  @override
  void dispose() {
    _bookingSubscription.cancel(); // Clean up the listener
    super.dispose();
  }

  Future<void> handleStatusUpdate(String action) async {
    try {
      setState(() => isLoading = true);

      // Helper function to safely create booking details map
      Map<String, dynamic> createBookingDetailsMap() {
        // Debug prints
        print("Current Booking Details: $currentBookingDetails");

        // Safely access nested values with fallbacks
        final vehicleDetails = currentBookingDetails['vehicleDetails'] ?? {};
        final directDetails = currentBookingDetails;

        return {
          'vehicleId': vehicleDetails['vehicleId'] ??
              directDetails['vehicleId'] ??
              'Unknown Vehicle ID',
          'vehicleName': vehicleDetails['name'] ??
              directDetails['name'] ??
              'Unknown Vehicle',
          'plateNumber': vehicleDetails['plateNo'] ??
              directDetails['plateNo'] ??
              'Unknown Plate',
          'pricePerHour': vehicleDetails['pricePerHour'] ??
              directDetails['pricePerHour'] ??
              0.0,
          'totalPrice': (vehicleDetails['pricePerHour'] ??
                  directDetails['pricePerHour'] ??
                  0.0) *
              _calculateTotalHours(),
          'pickupDate': directDetails['pickupDate'],
          'pickupTime': directDetails['pickupTime'],
          'returnDate': directDetails['returnDate'],
          'returnTime': directDetails['returnTime'],
          'bookingId': directDetails['bookingId'],
        };
      }

      if (action == 'MAKE_DEPOSIT_PAYMENT') {
        final bookingDetailsMap = createBookingDetailsMap();

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PayDepositPage(
              bookingDetails: bookingDetailsMap,
            ),
          ),
        );

        if (result == true) {
          await RentalStatusHandler.updateStatus(
            bookingId: currentBookingDetails['bookingId'],
            action: action,
            currentRenterStatus: currentBookingDetails['renterStatus'],
            currentRenteeStatus: currentBookingDetails['renteeStatus'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deposit payment completed successfully'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      } else if (action == 'CONFIRM_DELIVERY') {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewDeliveryRentee(
              bookingId: currentBookingDetails['bookingId'],
              bookingDetails: currentBookingDetails,
            ),
          ),
        );

        if (result == true) {
          await RentalStatusHandler.updateStatus(
            bookingId: currentBookingDetails['bookingId'],
            action: action,
            currentRenterStatus: currentBookingDetails['renterStatus'],
            currentRenteeStatus: currentBookingDetails['renteeStatus'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delivery status confirmed updated successfully'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      } else if (action == 'FILL_PRE_INSPECTION') {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreInspectionForm(
              bookingId: currentBookingDetails['bookingId'],
              bookingDetails: currentBookingDetails,
            ),
          ),
        );

        if (result == true) {
          await RentalStatusHandler.updateStatus(
            bookingId: currentBookingDetails['bookingId'],
            action: action,
            currentRenterStatus: currentBookingDetails['renterStatus'],
            currentRenteeStatus: currentBookingDetails['renteeStatus'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pre-inspection form submitted successfully'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      } else if (action == 'CONFIRM_POST_INSPECTION') {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostInspectionConfirmation(
              bookingDetails: currentBookingDetails,
              onConfirm: () async {
                await RentalStatusHandler.updateStatus(
                  bookingId: currentBookingDetails['bookingId'],
                  action: action,
                  currentRenterStatus: currentBookingDetails['renterStatus'],
                  currentRenteeStatus: currentBookingDetails['renteeStatus'],
                );
                Navigator.pop(context, true);
              },
              onCancel: () {
                Navigator.pop(context, false);
              },
            ),
          ),
        );

        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Post-inspection confirmed'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      } else if (action == 'MAKE_FINAL_PAYMENT') {
        final bookingDetailsMap = createBookingDetailsMap();

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FinalPaymentPage(
              bookingDetails: bookingDetailsMap,
            ),
          ),
        );

        if (result == true) {
          await RentalStatusHandler.updateStatus(
            bookingId: currentBookingDetails['bookingId'],
            action: action,
            currentRenterStatus: currentBookingDetails['renterStatus'],
            currentRenteeStatus: currentBookingDetails['renteeStatus'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Final payment completed successfully'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      } else if (action == 'START_USING') {
        await RentalStatusHandler.updateStatus(
          bookingId: currentBookingDetails['bookingId'],
          action: action,
          currentRenterStatus: currentBookingDetails['renterStatus'],
          currentRenteeStatus: currentBookingDetails['renteeStatus'],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vehicle usage started'),
            backgroundColor: RentalConstants.mainGreen,
          ),
        );
      } else if (action == 'REQUEST_RETURN') {
        await RentalStatusHandler.updateStatus(
          bookingId: currentBookingDetails['bookingId'],
          action: action,
          currentRenterStatus: currentBookingDetails['renterStatus'],
          currentRenteeStatus: currentBookingDetails['renteeStatus'],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Return request submitted'),
            backgroundColor: RentalConstants.mainGreen,
          ),
        );
      } else if (action == 'RENTER_RATE_COMPLETED') {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WriteYourFeedback(
              bookingDetails: currentBookingDetails,
            ),
          ),
        );
        if (result == true) {
          await RentalStatusHandler.updateStatus(
            bookingId: currentBookingDetails['bookingId'],
            action: action,
            currentRenterStatus: currentBookingDetails['renterStatus'],
            currentRenteeStatus: currentBookingDetails['renteeStatus'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rating submitted successfully'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      }
    } catch (e) {
      print('Error in handleStatusUpdate: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${e.toString()}'),
          backgroundColor: RentalConstants.mainRed,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void initializeRenteeStatusSteps() {
    final currentStatus = currentBookingDetails['renteeStatus'];
    final renterStatus = currentBookingDetails['renterStatus'];

    statusSteps = [
      {
        "title": "Booking Confirmed",
        "description": currentStatus == "booking_confirmed"
            ? "Make deposit payment"
            : "Deposit payment in process",
        "buttonText":
            currentStatus == "booking_confirmed" ? "MAKE PAYMENT" : null,
        "isCompleted": currentStatus != "booking_confirmed",
        "isActive": currentStatus == "booking_confirmed",
        "icon": Icons.check_circle,
      },
      {
        "title": "Vehicle Delivery Confirmation",
        "description": currentStatus == "vehicle_delivery" &&
                renterStatus == "vehicle_delivery"
            ? "Confirm vehicle delivery"
            : "Waiting for vehicle delivery",
        "buttonText":
            currentStatus == "vehicle_delivery" ? "CONFIRM DELIVERY" : null,
        "isCompleted": currentStatus == 'vehicle_delivery_confirmed' ||
            currentStatus == 'pre_inspection_completed' ||
            currentStatus == 'use_vehicle_confirmed' ||
            currentStatus == 'return_vehicle' ||
            currentStatus == "post_inspection_confirmed" ||
            currentStatus == 'final_payment_completed' ||
            currentStatus == 'booking_completed' ||
            currentStatus == 'renter_rated',
        "isActive": (currentStatus == "vehicle_delivery" &&
            renterStatus == "vehicle_delivery"),
        "icon": Icons.local_shipping,
      },
      {
        "title": "Pre-inspection Form",
        "description": currentStatus == "vehicle_delivery_confirmed" &&
                renterStatus == "vehicle_delivery_confirmed"
            ? "Fill pre-inspection form"
            : "Waiting for pre-inspection",
        "buttonText": currentStatus == "vehicle_delivery_confirmed"
            ? "FILL PRE-INSPECTION"
            : null,
        "isCompleted": currentStatus == 'pre_inspection_completed' ||
            currentStatus == 'use_vehicle_confirmed' ||
            currentStatus == 'return_vehicle' ||
            currentStatus == "post_inspection_confirmed" ||
            currentStatus == 'final_payment_completed' ||
            currentStatus == 'booking_completed' ||
            currentStatus == 'renter_rated',
        "isActive": (currentStatus == "vehicle_delivery_confirmed" &&
            renterStatus == "vehicle_delivery_confirmed"),
        "icon": Icons.assignment,
      },
      {
        "title": "Start Usage",
        "description": currentStatus == "pre_inspection_confirmed" &&
                renterStatus == "pre_inspection_confirmed"
            ? "Complete pre-inspection first"
            : "Start using vehicle",
        "buttonText": currentStatus == "pre_inspection_confirmed" &&
                renterStatus == "pre_inspection_confirmed"
            ? "START USING"
            : null,
        "isCompleted": currentStatus == "use_vehicle_confirmed" ||
            currentStatus == "return_vehicle" ||
            currentStatus == "post_inspection_completed" ||
            currentStatus == "post_inspection_confirmed" ||
            currentStatus == "final_payment_confirmed" ||
            currentStatus == "booking_completed" ||
            currentStatus == "renter_rated",
        "isActive": currentStatus == "pre_inspection_confirmed" &&
            renterStatus == "pre_inspection_confirmed",
        "icon": Icons.drive_eta,
      },
      {
        "title": "Return Vehicle",
        "description": currentStatus == "use_vehicle_confirmed"
            ? "Request vehicle return"
            : "Waiting Vehicle Return Confirmation",
        "buttonText":
            currentStatus == "use_vehicle_confirmed" ? "RETURN VEHICLE" : null,
        "isCompleted": currentStatus == "return_vehicle" ||
            currentStatus == "post_inspection_confirmed" ||
            currentStatus == "final_payment_confirmed" ||
            currentStatus == "booking_completed" ||
            currentStatus == "rated",
        "isActive": renterStatus == "use_vehicle_confirmed" &&
            currentStatus == "use_vehicle_confirmed",
        "icon": Icons.assignment_return,
      },
      {
        "title": "Post-inspection Form",
        "description": renterStatus == "post_inspection_completed"
            ? "Confirm post-inspection form"
            : "Waiting for post-inspection",
        "buttonText": renterStatus == "post_inspection_completed" &&
                currentStatus == "post_inspection_completed"
            ? "CONFIRM POST-INSPECTION"
            : null,
        "isCompleted": currentStatus == "post_inspection_confirmed" ||
            currentStatus == "final_payment_completed" ||
            currentStatus == "booking_completed" ||
            currentStatus == "renter_rated",
        "isActive": renterStatus == "post_inspection_completed" &&
            currentStatus == "post_inspection_completed",
        "icon": Icons.fact_check,
      },
      {
        "title": "Final Payment",
        "description": currentStatus == "post_inspection_confirmed"
            ? "Make final payment"
            : "Waiting for payment status",
        "buttonText": currentStatus == "post_inspection_confirmed"
            ? "MAKE FINAL PAYMENT"
            : null,
        "isCompleted": currentStatus == "final_payment_completed" ||
            currentStatus == "booking_completed" ||
            currentStatus == "renter_rated",
        "isActive": currentStatus == "post_inspection_confirmed",
        "icon": Icons.payment,
      },
      {
        "title": "Final Payment",
        "description": currentStatus == "post_inspection_confirmed"
            ? "Make final payment"
            : "Waiting for payment status",
        "buttonText": currentStatus == "post_inspection_confirmed"
            ? "MAKE FINAL PAYMENT"
            : null,
        "isCompleted": currentStatus == "booking_completed" ||
            currentStatus == "renter_rated",
        "isActive": currentStatus == "post_inspection_confirmed",
        "icon": Icons.payment,
      },
      {
        "title": "Booking Complete",
        "description": currentStatus == 'rentee_rated'
            ? "Rate renter"
            : "Booking completed successfully",
        "buttonText": currentStatus == 'rentee_rated' ? "RATE RENTER" : null,
        "isCompleted": currentStatus == "renter_rated",
        "isActive": currentStatus == 'rentee_rated',
        "icon": Icons.star,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RentalConstants.mainBlack,
      appBar: AppBar(
        backgroundColor: RentalConstants.mainBlack,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: RentalConstants.mainWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'RENTAL STATUS',
          style: TextStyle(
            color: RentalConstants.mainYellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: RentalConstants.mainYellow))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildBookingDetails(),
                  _buildStatusSteps(),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RentalConstants.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[850]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${currentBookingDetails['name']} (${currentBookingDetails['plateNo']})',
            style: TextStyle(
              color: RentalConstants.mainWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          if (currentBookingDetails['pricePerHour'] != null)
            Text(
              'Price per Hour: RM${(currentBookingDetails['pricePerHour'] ?? 0.0).toStringAsFixed(2)}',
              style: TextStyle(color: RentalConstants.mainWhite),
            ),
          SizedBox(height: 12),
          Text(
            'Pickup: ${RentalUtils.formatDate(currentBookingDetails['pickupDate'])} ${currentBookingDetails['pickupTime']}',
            style: TextStyle(color: RentalConstants.mainWhite),
          ),
          Text(
            'Return: ${RentalUtils.formatDate(currentBookingDetails['returnDate'])} ${currentBookingDetails['returnTime']}',
            style: TextStyle(color: RentalConstants.mainWhite),
          ),
          Text(
            'Location: ${currentBookingDetails['location']}',
            style: TextStyle(color: RentalConstants.mainWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSteps() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: statusSteps.length,
      itemBuilder: (context, index) {
        final step = statusSteps[index];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: RentalConstants.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: step['isActive']
                  ? RentalConstants.mainYellow
                  : Colors.grey[850]!,
              width: step['isActive'] ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Icon(
              step['icon'],
              color: step['isCompleted']
                  ? RentalConstants.mainGreen
                  : step['isActive']
                      ? RentalConstants.mainYellow
                      : Colors.grey,
              size: 28,
            ),
            title: Text(
              step['title'],
              style: TextStyle(
                color: RentalConstants.mainWhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              step['description'],
              style: TextStyle(color: RentalConstants.textGrey),
            ),
            trailing: step['buttonText'] != null
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RentalConstants.mainYellow,
                      foregroundColor: RentalConstants.mainBlack,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: step['isActive']
                        ? () {
                            String action;
                            currentBookingDetails['renteeStatus'];
                            switch (step['buttonText']) {
                              case 'MAKE PAYMENT':
                                action = 'MAKE_DEPOSIT_PAYMENT';
                                break;
                              case 'CONFIRM DELIVERY':
                                action = 'CONFIRM_DELIVERY';
                                break;
                              case 'FILL PRE-INSPECTION':
                                action = 'FILL_PRE_INSPECTION';
                                break;
                              case 'START USING':
                                action = 'START_USING';
                                break;
                              case 'RETURN VEHICLE':
                                action = 'REQUEST_RETURN';
                                break;
                              case 'CONFIRM POST-INSPECTION':
                                action = 'CONFIRM_POST_INSPECTION';
                                break;
                              case 'MAKE FINAL PAYMENT':
                                action = 'MAKE_FINAL_PAYMENT';
                                break;
                              case 'RATE RENTER':
                                action = 'RENTER_RATE_COMPLETED';
                                break;
                              default:
                                return;
                            }
                            handleStatusUpdate(action);
                          }
                        : null,
                    child: Text(
                      step['buttonText']!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
