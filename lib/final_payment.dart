import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    fetchInspectionDetails();
  }

  Future<void> fetchInspectionDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('post_inspection_forms')
          .doc(widget.bookingDetails['bookingId'])
          .get();

      if (doc.exists) {
        setState(() {
          inspectionFormDetails = doc.data();
          isLoading = false;
        });
      } else {
        throw Exception('Inspection form not found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading inspection details: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildInspectionSummary() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (inspectionFormDetails == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Inspection details not available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inspection Summary',
              style: TextStyle(
                color: Colors.yellow.shade700,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            buildDetailRow(
              'Overall Condition',
              inspectionFormDetails!["carCondition"] ?? "N/A",
            ),
            buildDetailRow(
              'Exterior Condition',
              inspectionFormDetails!["Exterior Condition"] ?? "N/A",
            ),
            buildDetailRow(
              'Interior Condition',
              inspectionFormDetails!["Interior Condition"] ?? "N/A",
            ),
            buildDetailRow(
              'Fuel Level',
              inspectionFormDetails!["Fuel Level"] ?? "N/A",
            ),
            buildTechnicalChecks(),
            if (inspectionFormDetails!["inspectionComments"]?.isNotEmpty ??
                false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Additional Comments',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inspectionFormDetails!["inspectionComments"] ?? "None",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTechnicalChecks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.grey),
        const SizedBox(height: 8),
        const Text(
          'Technical Checks',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildCheckItem('Brakes', inspectionFormDetails!["Brakes"] ?? "N/A"),
        _buildCheckItem(
            'Engine Sound', inspectionFormDetails!["Engine Sound"] ?? "N/A"),
        _buildCheckItem('Lights and Signals',
            inspectionFormDetails!["Lights and Signals"] ?? "N/A"),
        _buildCheckItem('Tires', inspectionFormDetails!["Tires"] ?? "N/A"),
      ],
    );
  }

  Widget _buildCheckItem(String label, String condition) {
    IconData icon;
    Color color;

    switch (condition.toLowerCase()) {
      case 'good':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'fair':
        icon = Icons.info;
        color = Colors.yellow;
        break;
      case 'poor':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            condition,
            style: TextStyle(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  double calculateFineCharges() {
    if (inspectionFormDetails == null) return 0.0;
    double fines = 0.0;

    // Function to check condition and add fines
    void checkCondition(String? condition, double amount) {
      if (condition == null) return;
      condition = condition.toLowerCase();
      if (condition == 'fair') {
        fines += amount;
      } else if (condition == 'poor') {
        fines += amount * 2;
      }
    }

    // Check various conditions
    checkCondition(inspectionFormDetails!["Exterior Condition"], 20.0);
    checkCondition(inspectionFormDetails!["Interior Condition"], 20.0);
    checkCondition(inspectionFormDetails!["Engine Sound"], 30.0);
    checkCondition(inspectionFormDetails!["Brakes"], 30.0);
    checkCondition(inspectionFormDetails!["Tires"], 25.0);
    checkCondition(inspectionFormDetails!["Lights and Signals"], 20.0);

    return fines;
  }

  String _getFineBreakdown() {
    List<String> fineDetails = [];

    void addFineDetail(String component, String? condition, double fairAmount) {
      if (condition == null) return;
      condition = condition.toLowerCase();
      if (condition == 'fair') {
        fineDetails
            .add("$component (Fair): RM${fairAmount.toStringAsFixed(2)}");
      } else if (condition == 'poor') {
        fineDetails
            .add("$component (Poor): RM${(fairAmount * 2).toStringAsFixed(2)}");
      }
    }

    addFineDetail('Exterior Condition',
        inspectionFormDetails!["Exterior Condition"], 20.0);
    addFineDetail('Interior Condition',
        inspectionFormDetails!["Interior Condition"], 20.0);
    addFineDetail('Engine Sound', inspectionFormDetails!["Engine Sound"], 30.0);
    addFineDetail('Brakes', inspectionFormDetails!["Brakes"], 30.0);
    addFineDetail('Tires', inspectionFormDetails!["Tires"], 25.0);
    addFineDetail('Lights and Signals',
        inspectionFormDetails!["Lights and Signals"], 20.0);

    return fineDetails.isEmpty ? "No fines" : fineDetails.join('\n');
  }

  double calculateRemainingBalance() {
    double totalPrice = widget.bookingDetails["totalPrice"] ?? 0.0;
    double deposit = (totalPrice * 0.35); // 35% deposit
    double fineCharges = calculateFineCharges();
    return (totalPrice - deposit) + fineCharges;
  }

  Future<void> proceedPayment() async {
    try {
      // Create payment document data
      final paymentData = {
        'bookingId': widget.bookingDetails['bookingId'],
        'paymentMethod': selectedPaymentMethod,
        'paymentStatus': 'Completed',
        'timestamp': FieldValue.serverTimestamp(),
        'totalAmount': calculateRemainingBalance(),
        'fineCharges': calculateFineCharges(),
        'vehicleId': widget.bookingDetails['vehicleId'],
        'vehicleName': widget.bookingDetails['vehicleName'],
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('payments')
          .doc(widget.bookingDetails['bookingId'])
          .set(paymentData);

      // Update booking status
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingDetails['bookingId'])
          .update({'status': 'Completed'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment processed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              "${widget.bookingDetails['pickupDate']} ${widget.bookingDetails['pickupTime']} - "
                  "${widget.bookingDetails['returnDate']} ${widget.bookingDetails['returnTime']}",
            ),
            Divider(color: Colors.yellow.shade700),
            buildDetailRow(
              'Total Price',
              'RM ${(widget.bookingDetails["totalPrice"] ?? 0.0).toStringAsFixed(2)}',
            ),
            buildDetailRow(
              'Deposit Paid (35%)',
              'RM ${((widget.bookingDetails["totalPrice"] ?? 0.0) * 0.35).toStringAsFixed(2)}',
            ),
            if (calculateFineCharges() > 0)
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
            const Text(
              'Payment Method',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedPaymentMethod,
                isExpanded: true,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                items: const [
                  DropdownMenuItem(
                    value: "Credit/Debit",
                    child: Text("Credit/Debit Card"),
                  ),
                  DropdownMenuItem(
                    value: "Online Banking",
                    child: Text("Online Banking"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value!;
                  });
                },
              ),
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
        return buildInspectionSummary();
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
                        proceedPayment();
                      }
                    },
                    child: Text(
                      currentStep < 2 ? 'Next' : 'Proceed Payment',
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
}
