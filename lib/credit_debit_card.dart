import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class CreditDebitPayment extends StatefulWidget {
  final double amount;
  final String bookingReference;

  const CreditDebitPayment({
    Key? key,
    required this.amount,
    required this.bookingReference,
  }) : super(key: key);

  @override
  _CreditDebitPaymentState createState() => _CreditDebitPaymentState();
}

class _CreditDebitPaymentState extends State<CreditDebitPayment> {
  final List<String> cardTypes = ['Visa', 'Mastercard', 'American Express'];
  String? selectedCardType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Credit/Debit Card',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.yellow.shade700,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Card Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.yellow.shade700,
              ),
            ),
            SizedBox(height: 20),
            ...cardTypes.map((type) => Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  padding: EdgeInsets.all(16.0),
                ),
                onPressed: () {
                  setState(() => selectedCardType = type);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardDetailsPage(
                        cardType: type,
                        amount: widget.amount,
                        bookingReference: widget.bookingReference,
                      ),
                    ),
                  );
                },
                child: Text(
                  type,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}

class CardDetailsPage extends StatefulWidget {
  final String cardType;
  final double amount;
  final String bookingReference;

  const CardDetailsPage({
    required this.cardType,
    required this.amount,
    required this.bookingReference,
  });

  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Enter Card Details',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.yellow.shade700,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        decoration: InputDecoration(
                          labelText: 'MM/YY',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _cardHolderController,
                  decoration: InputDecoration(
                    labelText: 'Card Holder Name',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card holder name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow.shade700,
                    padding: EdgeInsets.all(16.0),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardTransactionDetailsPage(
                            cardType: widget.cardType,
                            amount: widget.amount,
                            bookingReference: widget.bookingReference,
                            lastFourDigits: _cardNumberController.text.length >= 4 
                                ? _cardNumberController.text.substring(_cardNumberController.text.length - 4) 
                                : '****',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Continue',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardTransactionDetailsPage extends StatelessWidget {
  final String cardType;
  final double amount;
  final String bookingReference;
  final String lastFourDigits;

  const CardTransactionDetailsPage({
    required this.cardType,
    required this.amount,
    required this.bookingReference,
    required this.lastFourDigits,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Confirm Payment',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.yellow.shade700,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow.shade700,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Card Type: $cardType',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Card Number: ****-****-****-$lastFourDigits',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Amount: RM ${amount.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Reference: $bookingReference',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Date: ${DateTime.now().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade700,
                padding: EdgeInsets.all(16.0),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardOTPVerificationPage(
                      amount: amount,
                      bookingReference: bookingReference,
                    ),
                  ),
                );
              },
              child: Text(
                'Confirm Payment',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardOTPVerificationPage extends StatefulWidget {
  final double amount;
  final String bookingReference;

  const CardOTPVerificationPage({
    required this.amount,
    required this.bookingReference,
  });

  @override
  _CardOTPVerificationPageState createState() => _CardOTPVerificationPageState();
}

class _CardOTPVerificationPageState extends State<CardOTPVerificationPage> {
  final _otpController = TextEditingController();
  final String generatedOTP = Random().nextInt(900000 + 100000).toString();
  bool showSuccessDialog = false;
  int countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // In a real app, this would be sent via SMS/email
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your OTP is: $generatedOTP')),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void startCountdown() {
    setState(() {
      showSuccessDialog = true;
      countdown = 5;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (countdown > 0) {
            countdown--;
          } else {
            timer.cancel();
            // Navigate back through all pages with success result
            Navigator.of(context).pop(true); // Pop CardOTPVerificationPage
            Navigator.of(context).pop(); // Pop CardTransactionDetailsPage
            Navigator.of(context).pop(); // Pop CardDetailsPage
            Navigator.of(context).pop(true); // Pop CreditDebitPayment with success result
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showSuccessDialog) {
          return false; // Prevent back button during success dialog
        }
        return true;
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: Text(
                'OTP Verification',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.yellow.shade700,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter OTP',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter 6-digit OTP',
                      hintStyle: TextStyle(color: Colors.grey),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      padding: EdgeInsets.all(16.0),
                    ),
                    onPressed: () {
                      if (_otpController.text == generatedOTP) {
                        startCountdown();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invalid OTP. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Verify OTP',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showSuccessDialog)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.yellow.shade700,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                         child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Payment Successful!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Amount: RM ${widget.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Redirecting in $countdown seconds...',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}