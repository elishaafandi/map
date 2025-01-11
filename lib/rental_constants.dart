import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class RentalConstants {
  // Colors
  static const mainYellow = Color(0xFFFFD700);
  static const mainBlack = Color(0xFF000000);
  static const mainWhite = Color(0xFFFFFFFF);
  static const mainGreen = Color(0xFF4CAF50);
  static const mainRed = Color(0xFFE53935);
  static const cardBackground = Color(0xFF1A1A1A);
  static const textGrey = Color(0xFF9E9E9E);

  // Status Constants
  // Initial Booking
  static const bookingConfirmed = 'Booking Confirmed';
  
  // Deposit Payment
  static const depositPaymentCompleted = 'Deposit Payment Completed';
  static const depositPaymentConfirmed = 'Deposit Payment Confirmed';
  
  // Vehicle Delivery
  static const vehicleDelivery = 'Vehicle Delivery';
  static const vehicleDeliveryConfirmed = 'Vehicle Delivery Confirmed';
  
  // Pre-inspection
  static const preInspectionCompleted = 'Pre-Inspection Completed';
  static const preInspectionConfirmed = 'Pre-Inspection Confirmed';
  
  // In Use
  static const startUsingVehicle = 'Start Using Vehicle';
  static const useVehicleConfirmed = 'Use Vehicle Confirmed';
  
  // Return
  static const returnVehicle = 'Return Vehicle';
  static const returnVehicleConfirmed = 'Return Vehicle Confirmed';
  
  // Post-inspection
  static const postInspectionCompleted = 'Post-Inspection Completed';
  static const postInspectionConfirmed = 'Post-Inspection Confirmed';
  
  // Final Payment
  static const finalPaymentCompleted = 'Final Payment Completed';
  static const finalPaymentConfirmed = 'Final Payment Confirmed';
  
  // Completion
  static const bookingCompleted = 'Booking Completed';
  static const rated = 'Rated';
}

class RentalUtils {
  static Color getStatusColor(String status) {
    switch (status) {
      // Completed states - Green
      case RentalConstants.depositPaymentConfirmed:
      case RentalConstants.vehicleDeliveryConfirmed:
      case RentalConstants.preInspectionConfirmed:
      case RentalConstants.useVehicleConfirmed:
      case RentalConstants.returnVehicleConfirmed:
      case RentalConstants.postInspectionConfirmed:
      case RentalConstants.finalPaymentConfirmed:
      case RentalConstants.bookingCompleted:
      case RentalConstants.rated:
        return RentalConstants.mainGreen;

      // Active/In-progress states - Yellow
      case RentalConstants.depositPaymentCompleted:
      case RentalConstants.vehicleDelivery:
      case RentalConstants.preInspectionCompleted:
      case RentalConstants.startUsingVehicle:
      case RentalConstants.returnVehicle:
      case RentalConstants.postInspectionCompleted:
      case RentalConstants.finalPaymentCompleted:
        return RentalConstants.mainYellow;

      // Initial/Default states - Grey
      case RentalConstants.bookingConfirmed:
      default:
        return Colors.grey;
    }
  }

  static String formatDate(String date) {
    try {
      final DateTime parsed = DateTime.parse(date);
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }

  static String formatDatePretty(String date) {
    try {
      final DateTime parsed = DateTime.parse(date);
      return '${_getMonthName(parsed.month)} ${parsed.day}, ${parsed.year}';
    } catch (e) {
      return date;
    }
  }

  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}