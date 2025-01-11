// rental_status_handler.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RentalStatusHandler {
  static Future<void> updateStatus({
    required String bookingId,
    required String action,
    required String currentRenterStatus,
    required String currentRenteeStatus,
  }) async {
    Map<String, String> newStatuses = _getNewStatuses(
      action: action,
      currentRenterStatus: currentRenterStatus,
      currentRenteeStatus: currentRenteeStatus,
    );

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({
      'renterStatus': newStatuses['renterStatus'],
      'renteeStatus': newStatuses['renteeStatus'],
    });
  }

  static Map<String, String> _getNewStatuses({
    required String action,
    required String currentRenterStatus,
    required String currentRenteeStatus,
  }) {
    switch (action) {
      // Initial booking confirmation
      case 'BOOKING_CONFIRMED':
        return {
          'renterStatus': 'booking_confirmed',
          'renteeStatus': 'booking_confirmed',
        };

      // Deposit payment flow
      case 'MAKE_DEPOSIT_PAYMENT':
        return {
          'renterStatus': 'deposit_payment_completed',
          'renteeStatus': 'deposit_payment_completed',
        };
      case 'CONFIRM_DEPOSIT_PAYMENT':
        return {
          'renterStatus': 'deposit_payment_confirmed',
          'renteeStatus': 'deposit_payment_confirmed',
        };

      // Vehicle delivery flow
      case 'MAKE_DELIVERY':
        return {
          'renterStatus': 'vehicle_delivery',
          'renteeStatus': 'vehicle_delivery',
        };
      case 'CONFIRM_DELIVERY':
        return {
          'renterStatus': 'vehicle_delivery_confirmed',
          'renteeStatus': 'vehicle_delivery_confirmed',
        };

      // Pre-inspection flow
      case 'FILL_PRE_INSPECTION':
        return {
          'renterStatus': 'pre_inspection_completed',
          'renteeStatus': 'pre_inspection_completed',
        };
      case 'CONFIRM_PRE_INSPECTION':
        return {
          'renterStatus': 'pre_inspection_confirmed',
          'renteeStatus': 'pre_inspection_confirmed',
        };

      // Vehicle usage flow
      case 'START_USING':
        return {
          'renterStatus': 'use_vehicle_confirmed',
          'renteeStatus': 'use_vehicle_confirmed',
        };

      // Return vehicle flow
      case 'REQUEST_RETURN':
        return {
          'renterStatus': 'return_vehicle',
          'renteeStatus': 'return_vehicle',
        };
      case 'CONFIRM_RETURN':
        return {
          'renterStatus': 'return_vehicle_confirmed',
          'renteeStatus': 'return_vehicle_confirmed',
        };

      // Post-inspection flow
      case 'FILL_POST_INSPECTION':
        return {
          'renterStatus': 'post_inspection_completed',
          'renteeStatus': 'post_inspection_completed',
        };
      case 'CONFIRM_POST_INSPECTION':
        return {
          'renterStatus': 'post_inspection_confirmed',
          'renteeStatus': 'post_inspection_confirmed',
        };

      // Final payment flow
      case 'MAKE_FINAL_PAYMENT':
        return {
          'renterStatus': 'final_payment_completed',
          'renteeStatus': 'final_payment_completed',
        };
      case 'CONFIRM_FINAL_PAYMENT':
        return {
          'renterStatus': 'final_payment_confirmed',
          'renteeStatus': 'final_payment_confirmed',
        };

      // Booking completion flow
      case 'COMPLETE_BOOKING':
        return {
          'renterStatus': 'booking_completed',
          'renteeStatus': 'booking_completed',
        };
      case 'RENTEE_RATE_COMPLETED':
        return {
          'renterStatus': 'renteerated',
          'renteeStatus': 'renteerated',
        };
      case 'RENTER_RATE_COMPLETED':
        return {
          'renteeStatus': 'renterrated',
          'renterStatus': 'renterrated',
        };

      default:
        return {
          'renterStatus': currentRenterStatus,
          'renteeStatus': currentRenteeStatus,
        };
    }
  }
}
