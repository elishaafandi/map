import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movease/credit_debit_card.dart';
import 'package:movease/online_banking.dart';

class FinalPaymentPage extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const FinalPaymentPage({
    Key? key,
    required this.bookingDetails,
  }) : super(key: key);

  @override
  _FinalPaymentPageState createState() => _FinalPaymentPageState();
}

class _FinalPaymentPageState extends State<FinalPaymentPage> {
  int currentStep = 0;
  String selectedPaymentMethod = "Credit/Debit";
  Map<String, dynamic>? inspectionFormDetails;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchInspectionDetails();
  }

  Future<void> fetchInspectionDetails() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('post_inspection_forms')
          .where('bookingId', isEqualTo: widget.bookingDetails['bookingId'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          inspectionFormDetails = querySnapshot.docs.first.data() as Map<String, dynamic>;
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Inspection form not found. Please complete the inspection first.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error loading inspection details: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildFineBreakdown() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    List<Widget> fineDetails = [];
    double totalFines = 0.0;

    void addFineDetail(String component, String? condition, double fairAmount) {
      if (condition == null) return;
      condition = condition.toLowerCase();
      if (condition == 'not good') {
        double fineAmount = fairAmount;
        totalFines += fineAmount;
        fineDetails.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$component (Not Good)',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'RM${fineAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (inspectionFormDetails != null) {
      addFineDetail('Exterior Condition',
          inspectionFormDetails!["Exterior Condition"], 20.0);
      addFineDetail('Interior Condition',
          inspectionFormDetails!["Interior Condition"], 20.0);
      addFineDetail('Engine Sound', inspectionFormDetails!["Engine Sound"], 30.0);
      addFineDetail('Brakes', inspectionFormDetails!["Brakes"], 30.0);
      addFineDetail('Tires', inspectionFormDetails!["Tires"], 25.0);
      addFineDetail('Lights and Signals',
          inspectionFormDetails!["Lights and Signals"], 20.0);
    }

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fine Breakdown',
              style: TextStyle(
                color: Colors.yellow.shade700,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...fineDetails,
            if (fineDetails.isEmpty)
              const Text(
                'No fines applicable',
                style: TextStyle(color: Colors.green),
              ),
            if (fineDetails.isNotEmpty) ...[
              const Divider(color: Colors.grey),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Fines',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'RM${totalFines.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void navigateToPaymentMethod() async {
    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = calculateRemainingBalance();
    final bookingReference = widget.bookingDetails['bookingId'] ?? '';
    
    Widget paymentPage = selectedPaymentMethod == "Credit/Debit"
        ? CreditDebitPayment(
            amount: amount,
            bookingReference: bookingReference,
          )
        : OnlineBanking(
            amount: amount,
            bookingReference: bookingReference,
          );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => paymentPage),
    );

    if (result == true) {
      Navigator.of(context).pop(true);
    }
  }

  double calculateRemainingBalance() {
    double totalPrice = widget.bookingDetails["totalPrice"]?.toDouble() ?? 0.0;
    double deposit = (totalPrice * 0.35);
    double fineCharges = calculateFineCharges();
    return (totalPrice - deposit) + fineCharges;
  }

  double calculateFineCharges() {
    if (inspectionFormDetails == null || hasError) return 0.0;
    double fines = 0.0;

    void checkCondition(String? condition, double amount) {
      if (condition == null) return;
      if (condition.toLowerCase() == 'not good') {
        fines += amount;
      }
    }

    checkCondition(inspectionFormDetails!["Exterior Condition"], 20.0);
    checkCondition(inspectionFormDetails!["Interior Condition"], 20.0);
    checkCondition(inspectionFormDetails!["Engine Sound"], 30.0);
    checkCondition(inspectionFormDetails!["Brakes"], 30.0);
    checkCondition(inspectionFormDetails!["Tires"], 25.0);
    checkCondition(inspectionFormDetails!["Lights and Signals"], 20.0);

    return fines;
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
            buildDetailRow(
                'Car', widget.bookingDetails["vehicleName"] ?? "N/A"),
            buildDetailRow(
                'Plate Number', widget.bookingDetails["plateNumber"] ?? "N/A"),
            buildDetailRow(
              'Booking Period',
              "${widget.bookingDetails['pickupDate'] ?? 'N/A'} ${widget.bookingDetails['pickupTime'] ?? ''} - "
                  "${widget.bookingDetails['returnDate'] ?? 'N/A'} ${widget.bookingDetails['returnTime'] ?? ''}",
            ),
            Divider(color: Colors.yellow.shade700),
            buildDetailRow(
              'Total Price',
              'RM ${(widget.bookingDetails["totalPrice"]?.toDouble() ?? 0.0).toStringAsFixed(2)}',
            ),
            buildDetailRow(
              'Deposit Paid (35%)',
              'RM ${((widget.bookingDetails["totalPrice"]?.toDouble() ?? 0.0) * 0.35).toStringAsFixed(2)}',
            ),
            if (!hasError && calculateFineCharges() > 0)
              buildDetailRow(
                'Fine Charges',
                'RM ${calculateFineCharges().toStringAsFixed(2)}',
                isWarning: true,
              ),
            Divider(color: Colors.yellow.shade700),
            buildDetailRow(
              'Remaining Balance',
              'RM ${calculateRemainingBalance().toStringAsFixed(2)}',
              isBold: true,
            ),
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
              'Select Payment Method',
              style: TextStyle(
                color: Colors.yellow.shade700,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView(
              shrinkWrap: true,
              children: [
                _buildPaymentOption(
                  'Credit/Debit Card',
                  Icons.credit_card,
                  'Credit/Debit',
                ),
                const SizedBox(height: 12),
                _buildPaymentOption(
                  'Online Banking',
                  Icons.account_balance,
                  'Online Banking',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, String value) {
    bool isSelected = selectedPaymentMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.yellow.shade700 : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.yellow.shade700 : Colors.grey,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.yellow.shade700,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value,
      {bool isWarning = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isWarning ? Colors.red : Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return buildBookingDetails();
      case 1:
        return buildFineBreakdown();
      case 2:
        return buildPaymentMethod();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Final Payment',
          style: TextStyle(color: Colors.yellow.shade700),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.yellow.shade700),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildStepIndicator(),
              const SizedBox(height: 24),
              buildCurrentStep(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (currentStep > 0)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                      child: const Text('Previous',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    onPressed: () {
                      if (currentStep < 2) {
                        setState(() {
                          currentStep++;
                        });
                      } else {
                        navigateToPaymentMethod();
                      }
                    },
                    child: Text(
                      currentStep < 2 ? 'Next' : 'Proceed to Payment',
                      style: const TextStyle(color: Colors.black),
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

  Widget buildStepIndicator() {
    return Row(
      children: List.generate(3, (index) {
        bool isActive = index <= currentStep;
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    color: index == 0
                        ? Colors.transparent
                        : isActive
                            ? Colors.yellow[600]
                            : Colors.grey[300],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? Colors.yellow[600] : Colors.grey[300],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 4,
                    color: index == 2
                        ? Colors.transparent
                        : isActive
                            ? Colors.yellow[600]
                            : Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}