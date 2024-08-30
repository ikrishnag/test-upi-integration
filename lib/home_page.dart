import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';
import 'dart:developer';

// HomePage widget that contains the main UI and logic
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // Future to handle UPI transaction
  Future<UpiResponse>? _transaction;

  // Instance of UpiIndia to handle UPI operations
  final UpiIndia _upiIndia = UpiIndia();

  // List to store available UPI apps on the device
  List<UpiApp>? apps;

  // Controllers for input fields
  final TextEditingController _receiverUpiIdController =
      TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch available UPI apps when the widget is initialized
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = []; // Set apps to an empty list in case of an error
    });
  }

  // Function to initiate a UPI transaction using a selected app
  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: _receiverUpiIdController.text,
      receiverName: _receiverNameController.text,
      transactionRefId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      transactionNote: _noteController.text,
      amount: double.parse(_amountController.text),
    );
  }

  // Widget to display available UPI apps
  Widget displayUpiApps() {
    if (apps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (apps!.isEmpty) {
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    } else {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
        ),
        itemCount: apps!.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              _transaction = initiateTransaction(apps![index]);
              setState(() {}); // Trigger UI update
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                color: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.memory(
                      apps![index].icon,
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      apps![index].name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  // Function to handle errors during UPI transactions
  String _upiErrorHandler(error) {
    if (error is UpiIndiaAppNotInstalledException) {
      return 'Requested app not installed on device.';
    } else if (error is UpiIndiaUserCancelledException) {
      return 'You cancelled the transaction.';
    } else if (error is UpiIndiaNullResponseException) {
      return 'Requested app didn\'t return any response.';
    } else if (error is UpiIndiaInvalidParametersException) {
      return 'Requested app cannot handle the transaction.';
    } else {
      return 'An Unknown error has occurred';
    }
  }

  // Function to log the status of the UPI transaction
  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        log('Transaction Successful.');
        break;
      case UpiPaymentStatus.SUBMITTED:
        log('Transaction Submitted.');
        break;
      case UpiPaymentStatus.FAILURE:
        log('Transaction Failed.');
        break;
      default:
        log('Received an Unknown transaction status.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        surfaceTintColor: Colors.white,
        shadowColor: const Color.fromARGB(255, 88, 88, 88),
        title: const Text('Test UPI Payment'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 24),
                // Card for input fields
                Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Receiver UPI ID input
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextField(
                            controller: _receiverUpiIdController,
                            decoration: const InputDecoration(
                              labelText: ' Receiver UPI ID',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Receiver Name input
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextField(
                            controller: _receiverNameController,
                            decoration: const InputDecoration(
                              labelText: ' Receiver Name',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Amount input
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: ' Amount',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Note input
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: ' Note',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // UPI App selection section
                Text(
                  'Select Payment App',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: displayUpiApps(),
                ),
                const SizedBox(height: 24),
                // Transaction result display
                if (_transaction != null)
                  FutureBuilder(
                    future: _transaction,
                    builder: (BuildContext context,
                        AsyncSnapshot<UpiResponse> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Card(
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                _upiErrorHandler(snapshot.error.runtimeType),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        }
                        UpiResponse upiResponse = snapshot.data!;
                        String txnId = upiResponse.transactionId ?? 'N/A';
                        String resCode = upiResponse.responseCode ?? 'N/A';
                        String txnRef = upiResponse.transactionRefId ?? 'N/A';
                        String status = upiResponse.status ?? 'N/A';
                        String approvalRef = upiResponse.approvalRefNo ?? 'N/A';
                        _checkTxnStatus(status);

                        return Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Transaction Details',
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 16),
                                Text('Transaction ID: $txnId'),
                                Text('Response Code: $resCode'),
                                Text('Reference ID: $txnRef'),
                                Text('Status: ${status.toUpperCase()}'),
                                Text('Approval Ref: $approvalRef'),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
