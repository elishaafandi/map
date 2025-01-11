import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FinalPaymentConfirmPage extends StatelessWidget {
  final String bookingId;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const FinalPaymentConfirmPage({
    Key? key,
    required this.bookingId,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1e1e1e),
      appBar: AppBar(
        title: const Text(
          'Final Payment Confirmation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.05),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .doc(bookingId)
            .snapshots(),
        builder: (context, paymentSnapshot) {
          if (paymentSnapshot.hasError) {
            return Center(child: Text('Error: ${paymentSnapshot.error}'));
          }

          if (!paymentSnapshot.hasData || !paymentSnapshot.data!.exists) {
            return const Center(
              child: Text(
                'No payment information found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final paymentData =
              paymentSnapshot.data!.data() as Map<String, dynamic>? ?? {};

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade700,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking #${paymentData['bookingId'] ?? bookingId}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Payment Status: ${paymentData['paymentStatus'] ?? 'Pending'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildCard(
                        'Vehicle Details',
                        [
                          _buildDetailRow(
                            'Vehicle',
                            paymentData['vehicleName'] ?? 'Not specified',
                          ),
                          _buildDetailRow(
                            'Vehicle ID',
                            paymentData['vehicleId'] ?? 'Not specified',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildCard(
                        'Payment Information',
                        [
                          _buildDetailRow(
                            'Total Amount',
                            'RM ${(paymentData['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
                          ),
                          if (paymentData['fineCharges'] != null && paymentData['fineCharges'] > 0)
                            _buildDetailRow(
                              'Fine Charges',
                              'RM ${(paymentData['fineCharges'] ?? 0.0).toStringAsFixed(2)}',
                            ),
                          _buildDetailRow(
                            'Payment Method',
                            paymentData['paymentMethod'] ?? 'Not specified',
                          ),
                          _buildDetailRow(
                            'Payment Status',
                            paymentData['paymentStatus'] ?? 'Pending',
                          ),
                          if (paymentData['timestamp'] != null)
                            _buildDetailRow(
                              'Payment Time',
                              (paymentData['timestamp'] as Timestamp)
                                  .toDate()
                                  .toString(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: paymentData['paymentStatus'] == 'Completed'
                                  ? onConfirm
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Confirm Payment",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onCancel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}