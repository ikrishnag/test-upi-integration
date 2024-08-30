import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';
import 'dart:developer';

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

  // TextStyle for headers in the app
  TextStyle header = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // TextStyle for values in the app
  TextStyle value = const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  @override
  void initState() {
    // Fetches available UPI apps on the device when the widget is initialized
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value; // Updates the list of UPI apps
      });
    }).catchError((e) {
      apps = []; // Sets apps to an empty list in case of an error
    });
    super.initState();
  }

  // Function to initiate a UPI transaction using a selected app
  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app, // UPI app selected by the user
      receiverUpiId: "9078600498@ybl", // UPI ID of the receiver
      receiverName: 'Md Azharuddin', // Name of the receiver
      transactionRefId:
          'TestingUpiIndiaPlugin', // Reference ID for the transaction
      transactionNote:
          'Not actual. Just an example.', // Note for the transaction
      amount: 1.00, // Amount to be transferred
    );
  }

  // Function to display available UPI apps to the user
  Widget displayUpiApps() {
    if (apps == null) {
      // If the list of apps is null, show a loading indicator
      return const Center(child: CircularProgressIndicator());
    } else if (apps!.isEmpty) {
      // If no apps are found, show a message
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    } else {
      // If apps are found, display them in a grid layout
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  // Initiates the transaction when an app is tapped
                  _transaction = initiateTransaction(app);
                  setState(() {}); // Updates the UI
                },
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Displays the app icon and name
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  // Function to handle errors during UPI transactions
  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device.';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction.';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response.';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction.';
      default:
        return 'An Unknown error has occurred';
    }
  }

  // Function to log the status of the UPI transaction
  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        log('Transaction Successful'); // Logs success message
        break;
      case UpiPaymentStatus.SUBMITTED:
        log('Transaction Submitted'); // Logs submission message
        break;
      case UpiPaymentStatus.FAILURE:
        log('Transaction Failed'); // Logs failure message
        break;
      default:
        log('Received an Unknown transaction status'); // Logs unknown status message
    }
  }

  // Function to display transaction data in a row format
  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header), // Displays the title
          Flexible(
              child: Text(
            body,
            style: value, // Displays the transaction data
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Builds the UI for the HomePage
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing UPI Integration'), // AppBar title
        centerTitle: true, // Centers the title
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 50, // Adds space at the top
          ),
          Expanded(
            child: displayUpiApps(), // Displays the available UPI apps
          ),
          Expanded(
            child: FutureBuilder(
              future: _transaction, // The future to be awaited
              builder:
                  (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    // Displays error message if transaction fails
                    return Center(
                      child: Text(
                        _upiErrorHandler(snapshot.error.runtimeType),
                        style: header,
                      ),
                    );
                  }

                  UpiResponse upiResponse =
                      snapshot.data!; // Retrieves transaction response

                  // Extracts transaction details, defaults to 'N/A' if null
                  String txnId = upiResponse.transactionId ?? 'N/A';
                  String resCode = upiResponse.responseCode ?? 'N/A';
                  String txnRef = upiResponse.transactionRefId ?? 'N/A';
                  String status = upiResponse.status ?? 'N/A';
                  String approvalRef = upiResponse.approvalRefNo ?? 'N/A';
                  _checkTxnStatus(status); // Logs the status of the transaction

                  // Displays the transaction details
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        displayTransactionData(
                            'Transaction Id', txnId), // Displays transaction ID
                        displayTransactionData(
                            'Response Code', resCode), // Displays response code
                        displayTransactionData(
                            'Reference Id', txnRef), // Displays reference ID
                        displayTransactionData(
                            'Status',
                            status
                                .toUpperCase()), // Displays status in uppercase
                        displayTransactionData('Approval No',
                            approvalRef), // Displays approval number
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                        ''), // Displays empty widget while awaiting transaction
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
