import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movease/deposit_confirm.dart';
import 'package:movease/final_payment_confirm.dart';
import 'package:movease/post_inspection_form.dart';
import 'package:movease/pre_inspection_confirm.dart';
import 'package:movease/rental_status_handler.dart';
import 'package:movease/write_feedback_formrentee.dart';
import 'rental_constants.dart';
import 'car_delivery.dart';

class RenterStatusTracker extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  RenterStatusTracker({required this.bookingDetails});

  @override
  _RenterStatusTrackerState createState() => _RenterStatusTrackerState();
}

class _RenterStatusTrackerState extends State<RenterStatusTracker> {
  List<Map<String, dynamic>> statusSteps = [];
  bool isLoading = false;
  Map<String, dynamic>? vehicleDetails;
  late Map<String, dynamic> currentBookingDetails;
  late StreamSubscription<DocumentSnapshot> _bookingSubscription;

  @override
  void initState() {
    super.initState();
    currentBookingDetails = Map<String, dynamic>.from(widget.bookingDetails);
    initializeRenterStatusSteps();
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
          initializeRenterStatusSteps(); // Reinitialize steps with new data
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

      if (action == 'CONFIRM_DEPOSIT_PAYMENT') {
        // Navigate to DepositConfirmPage and await result
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DepositConfirmPage(
              bookingId: currentBookingDetails['bookingId'],
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

        // Only update local state if confirmation was successful
        if (result == true) {
          await RentalStatusHandler.updateStatus(
            bookingId: currentBookingDetails['bookingId'],
            action: action,
            currentRenterStatus: currentBookingDetails['renterStatus'],
            currentRenteeStatus: currentBookingDetails['renteeStatus'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deposit payment confirmed successfully'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      } else if (action == 'MAKE_DELIVERY') {
        // Handle delivery navigation
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewDeliveryDetails(
              bookingId: currentBookingDetails['bookingId'],
              bookingDetails: currentBookingDetails,
            ),
          ),
        );

        // Only update if delivery was confirmed
        if (result == true) {
          await RentalStatusHandler.updateStatus(
            bookingId: currentBookingDetails['bookingId'],
            action: action,
            currentRenterStatus: currentBookingDetails['renterStatus'],
            currentRenteeStatus: currentBookingDetails['renteeStatus'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delivery status updated successfully'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      } else if (action == 'CONFIRM_PRE_INSPECTION') {
        //copy daari sini
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreInspectionConfirmation(
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
          await RentalStatusHandler.updateStatus(
            bookingId: currentBookingDetails['bookingId'],
            action: action,
            currentRenterStatus: currentBookingDetails['renterStatus'],
            currentRenteeStatus: currentBookingDetails['renteeStatus'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pre-inspection confirmation successful'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      } else if (action == 'FILL_POST_INSPECTION') {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostInspectionForm(
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
              content: Text('Post-inspection submitted successful'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      } else if (action == 'CONFIRM_FINAL_PAYMENT') {
        // Navigate to DepositConfirmPage and await result
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FinalPaymentConfirmPage(
              bookingId: currentBookingDetails['bookingId'],
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

        // Only update local state if confirmation was successful
        if (result == true) {
          await RentalStatusHandler.updateStatus(
            bookingId: currentBookingDetails['bookingId'],
            action: action,
            currentRenterStatus: currentBookingDetails['renterStatus'],
            currentRenteeStatus: currentBookingDetails['renteeStatus'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deposit payment confirmed successfully'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      } else if (action == 'RENTEE_RATE_COMPLETED') {
        // Navigate to DepositConfirmPage and await result
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WriteYourFeedback(
              bookingDetails: currentBookingDetails,
            ),
          ),
        );

        // Only update local state if confirmation was successful
        if (result == true) {
          await RentalStatusHandler.updateStatus(
            bookingId: currentBookingDetails['bookingId'],
            action: action,
            currentRenterStatus: currentBookingDetails['renterStatus'],
            currentRenteeStatus: currentBookingDetails['renteeStatus'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deposit payment confirmed successfully'),
              backgroundColor: RentalConstants.mainGreen,
            ),
          );
        }
      } else {
        //potong sini
        // Handle other status updates
        await RentalStatusHandler.updateStatus(
          bookingId: currentBookingDetails['bookingId'],
          action: action,
          currentRenterStatus: currentBookingDetails['renterStatus'],
          currentRenteeStatus: currentBookingDetails['renteeStatus'],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated successfully'),
            backgroundColor: RentalConstants.mainGreen,
          ),
        );
      }
    } catch (e) {
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

  void initializeRenterStatusSteps() {
    final currentStatus = currentBookingDetails['renterStatus'];
    final renteeStatus = currentBookingDetails['renteeStatus'];

    statusSteps = [
      {
        "title": "Booking Confirmed",
        "description": currentStatus == "deposit_payment_completed" &&
                renteeStatus == "deposit_payment_completed"
            ? "Confirm deposit payment"
            : "Waiting for deposit payment",
        "buttonText": currentStatus == "deposit_payment_completed" &&
                renteeStatus == "deposit_payment_completed"
            ? "CONFIRM DEPOSIT PAYMENT"
            : null,
        "isCompleted": currentStatus != "booking_confirmed" &&
            currentStatus != "deposit_payment_completed",
        "isActive": currentStatus == "deposit_payment_completed" &&
            renteeStatus == "deposit_payment_completed",
        "icon": Icons.check_circle,
      },
      {
        "title": "Vehicle Delivery",
        "description": currentStatus == "deposit_payment_confirmed"
            ? "Start vehicle delivery process"
            : "Waiting for delivery confirmation",
        "buttonText": currentStatus == "deposit_payment_confirmed"
            ? "MAKE DELIVERY"
            : null,
        "isCompleted": currentStatus == "vehicle_delivery" ||
            currentStatus == "vehicle_delivery_confirmed" ||
            currentStatus == "pre_inspection_completed" ||
            currentStatus == "use_vehicle_confirmed" ||
            currentStatus == "return_vehicle" ||
            currentStatus == "post_inspection_completed" ||
            currentStatus == "post_inspection_confirmed" ||
            currentStatus == "final_payment_confirmed" ||
            currentStatus == "booking_completed" ||
            currentStatus == "rentee_rated",
        "isActive": currentStatus == "deposit_payment_confirmed",
        "icon": Icons.local_shipping,
      },
      {
        "title": "Pre-inspection Form",
        "description": renteeStatus == "pre_inspection_completed" &&
                currentStatus == "pre_inspection_completed"
            ? "Waiting for pre-inspection completion"
            : "Pre-Inspection Form Confirmed",
        "buttonText": renteeStatus == "pre_inspection_completed" &&
                currentStatus == "pre_inspection_completed"
            ? "CONFIRM PRE-INSPECTION"
            : null,
        "isCompleted": currentStatus == "pre_inspection_confirmed" ||
            currentStatus == "use_vehicle_confirmed" ||
            currentStatus == "return_vehicle_confirmed" ||
            currentStatus == "post_inspection_completed" ||
            currentStatus == "post_inspection_confirmed" ||
            currentStatus == "final_payment_confirmed" ||
            currentStatus == "booking_completed" ||
            currentStatus == "rentee_rated",
        "isActive": renteeStatus == "pre_inspection_completed" &&
            currentStatus == "pre_inspection_completed",
        "icon": Icons.assignment,
      },
      {
        "title": "Return Vehicle Confirmation",
        "description": renteeStatus == "return_vehicle"
            ? "Waiting for return request"
            : "Confirm vehicle return",
        "buttonText": renteeStatus == "return_vehicle" &&
                currentStatus == "return_vehicle"
            ? "CONFIRM RETURN"
            : null,
        "isCompleted": currentStatus == "return_vehicle_confirmed" ||
            currentStatus == "post_inspection_completed" ||
            currentStatus == "post_inspection_confirmed" ||
            currentStatus == "final_payment_confirmed" ||
            currentStatus == "booking_completed" ||
            currentStatus == "rentee_rated",
        "isActive": renteeStatus == "return_vehicle" &&
            currentStatus == "return_vehicle",
        "icon": Icons.assignment_return,
      },
      {
        "title": "Post-inspection Form",
        "description": currentStatus == "return_vehicle_confirmed"
            ? "Waiting for post-inspection"
            : "Complete post-inspection form",
        "buttonText": currentStatus == "return_vehicle_confirmed"
            ? "FILL POST-INSPECTION"
            : null,
        "isCompleted": currentStatus == "post_inspection_completed" ||
            currentStatus == "final_payment_confirmed" ||
            currentStatus == "booking_completed" ||
            currentStatus == "rentee_rated",
        "isActive": currentStatus == "return_vehicle_confirmed",
        "icon": Icons.fact_check,
      },
      {
        "title": "Final Payment",
        "description": renteeStatus == "final_payment_completed"
            ? "Confirm final payment"
            : "Waiting for final payment",
        "buttonText": renteeStatus == "final_payment_completed" &&
                currentStatus == "final_payment_completed"
            ? "CONFIRM FINAL PAYMENT"
            : null,
        "isCompleted": currentStatus == "final_payment_confirmed" ||
            currentStatus == "booking_completed" ||
            currentStatus == "rentee_rated",
        "isActive": renteeStatus == "final_payment_completed" &&
            currentStatus == "final_payment_completed",
        "icon": Icons.payment,
      },
      {
        "title": "Complete Booking",
        "description": currentStatus == "final_payment_confirmed"
            ? "Rate rentee"
            : "Booking completed successfully",
        "buttonText": currentStatus == "final_payment_confirmed"
            ? "COMPLETE BOOKING"
            : null,
        "isCompleted": currentStatus == "booking_completed" ||
            currentStatus == "rentee_rated",
        "isActive": currentStatus == "final_payment_confirmed",
        "icon": Icons.star,
      },
      {
        "title": "Booking Completed",
        "description": renteeStatus == "renteerated"
            ? "Rentee has completed their rating"
            : currentStatus == "booking_completed"
                ? "Rate rentee"
                : "Booking completed successfully",
        "buttonText": currentStatus == "booking_completed" &&
                renteeStatus != "renteerated"
            ? "RATE RENTEE"
            : null,
        "isCompleted": currentStatus == "rentee_rated",
        "isActive": currentStatus == "booking_completed" ||
            renteeStatus == "renteerated",
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
                            widget.bookingDetails['renterStatus'];
                            switch (step['buttonText']) {
                              case 'CONFIRM DEPOSIT PAYMENT':
                                action = 'CONFIRM_DEPOSIT_PAYMENT';
                                break;
                              case 'MAKE DELIVERY':
                                action = 'MAKE_DELIVERY';
                                break;
                              case 'CONFIRM PRE-INSPECTION':
                                action = 'CONFIRM_PRE_INSPECTION';
                                break;
                              case 'CONFIRM USE VEHICLE':
                                action = 'START_USING';
                                break;
                              case 'CONFIRM RETURN':
                                action = 'CONFIRM_RETURN';
                                break;
                              case 'FILL POST-INSPECTION':
                                action = 'FILL_POST_INSPECTION';
                                break;
                              case 'CONFIRM FINAL PAYMENT':
                                action = 'CONFIRM_FINAL_PAYMENT';
                                break;
                              case 'COMPLETE BOOKING':
                                action = 'COMPLETE_BOOKING';
                                break;
                              case 'RATE RENTEE':
                                action = 'RENTEE_RATE_COMPLETED';
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
