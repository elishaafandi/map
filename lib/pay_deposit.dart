import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movease/credit_debit_card.dart';
import 'package:movease/online_banking.dart';


class PayDepositPage extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const PayDepositPage({
    Key? key,
    required this.bookingDetails,
  }) : super(key: key);

  @override
  State<PayDepositPage> createState() => _PayDepositPageState();
}

class _PayDepositPageState extends State<PayDepositPage> {
  String selectedPaymentMethod = "Online Banking";

Future<void> proceedPayment() async {
  if (selectedPaymentMethod == "Online Banking") {
    // Existing online banking flow
    final paymentSuccess = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OnlineBanking(
          amount: calculateDeposit(),
          bookingReference: widget.bookingDetails['bookingId'],
        ),
      ),
    );

    // Only proceed with Firestore update if payment was successful
    if (paymentSuccess == true) {
      try {
        // Create deposit document data
        final depositData = {
          'bookingId': widget.bookingDetails['bookingId'],
          'paymentMethod': selectedPaymentMethod,
          'paymentStatus': 'Completed',
          'pickupDate': widget.bookingDetails['pickupDate'],
          'pickupTime': widget.bookingDetails['pickupTime'],
          'returnDate': widget.bookingDetails['returnDate'],
          'returnTime': widget.bookingDetails['returnTime'],
          'timestamp': FieldValue.serverTimestamp(),
          'totalDeposit': calculateDeposit(),
          'vehicleId': widget.bookingDetails['vehicleId'],
          'vehicleName': widget.bookingDetails['vehicleName'],
        };

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('deposits')
            .doc(widget.bookingDetails['bookingId'])
            .set(depositData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deposit payment processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Return true to indicate successful payment
        Navigator.pop(context, true);
      } catch (e) {
        // Show error message if saving fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } else if (selectedPaymentMethod == "Credit/Debit Card") {
    // Navigate to Credit/Debit Card payment flow
    final paymentSuccess = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreditDebitPayment(
          amount: calculateDeposit(),
          bookingReference: widget.bookingDetails['bookingId'],
        ),
      ),
    );

    // Only proceed with Firestore update if payment was successful
    if (paymentSuccess == true) {
      try {
        // Create deposit document data
        final depositData = {
          'bookingId': widget.bookingDetails['bookingId'],
          'paymentMethod': selectedPaymentMethod,
          'paymentStatus': 'Completed',
          'pickupDate': widget.bookingDetails['pickupDate'],
          'pickupTime': widget.bookingDetails['pickupTime'],
          'returnDate': widget.bookingDetails['returnDate'],
          'returnTime': widget.bookingDetails['returnTime'],
          'timestamp': FieldValue.serverTimestamp(),
          'totalDeposit': calculateDeposit(),
          'vehicleId': widget.bookingDetails['vehicleId'],
          'vehicleName': widget.bookingDetails['vehicleName'],
        };

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('deposits')
            .doc(widget.bookingDetails['bookingId'])
            .set(depositData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deposit payment processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Return true to indicate successful payment
        Navigator.pop(context, true);
      } catch (e) {
        // Show error message if saving fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

  void cancelPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment canceled'),
        backgroundColor: Colors.grey,
      ),
    );
    // Return false to indicate cancelled payment
    Navigator.pop(context, false);
  }

  // Update the carDetails to use the bookingDetails passed from RenteeStatusTracker
  Map<String, dynamic> get carDetails {
    return {
      "car": widget.bookingDetails['vehicleName'] ?? "Not specified",
      "plateNumber": widget.bookingDetails['plateNumber'] ?? "Not specified",
      "bookingPeriod":
          "${widget.bookingDetails['pickupDate']} ${widget.bookingDetails['pickupTime']} - ${widget.bookingDetails['returnDate']} ${widget.bookingDetails['returnTime']}",
      "totalPrice": widget.bookingDetails['totalPrice'] ?? 0.0,
      "pricePerHour": widget.bookingDetails['pricePerHour'] ?? 0.0,
    };
  }

  double calculateDeposit() {
    return (carDetails["totalPrice"] as double) * 0.35; // 35% of total price
  }

  Widget buildPriceBreakdown() {
    double deposit = calculateDeposit();
    double totalPrice = carDetails["totalPrice"] as double;
    double remaining = totalPrice - deposit;

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Breakdown',
              style: TextStyle(
                color: Colors.yellow.shade700,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            buildDetailRow(
              'Total Rental Price',
              'RM ${totalPrice.toStringAsFixed(2)}',
            ),
            Divider(color: Colors.yellow.shade700),
            buildDetailRow(
              'Required Deposit (35%)',
              'RM ${deposit.toStringAsFixed(2)}',
              isBold: true,
              highlightColor: Colors.yellow.shade700,
            ),
            buildDetailRow(
              'Remaining Balance',
              'RM ${remaining.toStringAsFixed(2)}',
              isSecondary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBookingDetails() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: TextStyle(
                color: Colors.yellow.shade700,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            buildDetailRow('Car', carDetails["car"] as String),
            buildDetailRow('Plate Number', carDetails["plateNumber"] as String),
            buildDetailRow(
                'Booking Period', carDetails["bookingPeriod"] as String),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentMethod() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: TextStyle(
                color: Colors.yellow.shade700,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow.shade700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedPaymentMethod,
                isExpanded: true,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                items: const [
                  DropdownMenuItem<String>(
                    value: "Online Banking",
                    child: Text("Online Banking"),
                  ),
                  DropdownMenuItem<String>(
                    value: "Credit/Debit Card",
                    child: Text("Credit/Debit Card"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedPaymentMethod = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value,
      {bool isBold = false, bool isSecondary = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSecondary ? Colors.grey[400] : Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlightColor ??
                  (isSecondary ? Colors.grey[400] : Colors.white),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Pay Deposit',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.yellow.shade700,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildBookingDetails(),
              const SizedBox(height: 16),
              buildPriceBreakdown(),
              const SizedBox(height: 16),
              buildPaymentMethod(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: proceedPayment,
                        child: const Text(
                          'Pay Deposit',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: cancelPayment,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}