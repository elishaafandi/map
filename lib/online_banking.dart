// onlinebanking.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class OnlineBanking extends StatefulWidget {
  final double amount;
  final String bookingReference;

  const OnlineBanking({
    Key? key,
    required this.amount,
    required this.bookingReference,
  }) : super(key: key);

  @override
  _OnlineBankingState createState() => _OnlineBankingState();
}

class _OnlineBankingState extends State<OnlineBanking> {
  final List<String> banks = ['Maybank', 'CIMB Bank', 'Bank Islam'];
  String? selectedBank;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Online Banking',
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
              'Select Your Bank',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.yellow.shade700,
              ),
            ),
            SizedBox(height: 20),
            ...banks.map((bank) => Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  padding: EdgeInsets.all(16.0),
                ),
                onPressed: () {
                  setState(() => selectedBank = bank);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BankLoginPage(
                        bankName: bank,
                        amount: widget.amount,
                        bookingReference: widget.bookingReference,
                      ),
                    ),
                  );
                },
                child: Text(
                  bank,
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

class BankLoginPage extends StatefulWidget {
  final String bankName;
  final double amount;
  final String bookingReference;

  const BankLoginPage({
    required this.bankName,
    required this.amount,
    required this.bookingReference,
  });

  @override
  _BankLoginPageState createState() => _BankLoginPageState();
}

class _BankLoginPageState extends State<BankLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '${widget.bankName} Login',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.yellow.shade700,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
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
                        builder: (context) => TransactionDetailsPage(
                          bankName: widget.bankName,
                          amount: widget.amount,
                          bookingReference: widget.bookingReference,
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionDetailsPage extends StatelessWidget {
  final String bankName;
  final double amount;
  final String bookingReference;

  const TransactionDetailsPage({
    required this.bankName,
    required this.amount,
    required this.bookingReference,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Transaction Details',
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
                      'Bank: $bankName',
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
                    builder: (context) => OTPVerificationPage(
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

class OTPVerificationPage extends StatefulWidget {
  final double amount;
  final String bookingReference;

  const OTPVerificationPage({
    required this.amount,
    required this.bookingReference,
  });

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
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
            Navigator.of(context).pop(true); // Pop OTPVerificationPage
            Navigator.of(context).pop(); // Pop TransactionDetailsPage
            Navigator.of(context).pop(); // Pop BankLoginPage
            Navigator.of(context).pop(true); // Pop OnlineBanking with success result
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