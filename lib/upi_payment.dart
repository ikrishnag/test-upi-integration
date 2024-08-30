import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UPIPayment extends StatefulWidget {
  const UPIPayment({super.key});

  @override
  _UPIPaymentState createState() => _UPIPaymentState();
}

class _UPIPaymentState extends State<UPIPayment> {
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _status = '';

  Future<void> _initiateTransaction() async {
    String upiId = _upiIdController.text;
    String amount = _amountController.text;
    String note = _noteController.text;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageName = packageInfo.packageName;

    String upiUrl =
        'upi://pay?pa=$upiId&pn=Receiver&tn=$note&am=$amount&cu=INR&mc=123456&tr=123456789';

    if (await canLaunch(upiUrl)) {
      await launch(upiUrl);
      setState(() {
        _status = 'Transaction initiated. Please check your UPI app.';
      });
    } else {
      setState(() {
        _status = 'Could not launch UPI app. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _upiIdController,
              decoration: const InputDecoration(labelText: 'UPI ID'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initiateTransaction,
              child: const Text('Pay Now'),
            ),
            const SizedBox(height: 16),
            Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
