import 'package:flutter/material.dart';
import 'package:my_pos/pages/h_page.dart';
import 'package:my_pos/pages/print_page.dart';
import 'package:my_pos/providers/ticket_provider.dart';
import 'package:provider/provider.dart';
import 'package:my_pos/models/ticket_model.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PaymentPage extends StatelessWidget {
  final Ticket ticket;

  const PaymentPage({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  // Method to get the SD card directory
  // Future<Directory?> getSdCardDirectory() async {
  //   try {
  //     // For Android devices, external storage directories usually include SD card
  //     final List<Directory>? externalDirs = await getExternalStorageDirectories();
  //
  //     if (externalDirs != null && externalDirs.length > 1) {
  //       // Typically, the second directory is the SD card
  //       return externalDirs.length > 1 ? externalDirs[1] : externalDirs.first;
  //     } else {
  //       // Fallback to external storage directory
  //       return await getExternalStorageDirectory();
  //     }
  //   } catch (e) {
  //     print('Error getting SD card directory: $e');
  //     return await getExternalStorageDirectory();
  //   }
  // }

  Future<Directory> getStorageDirectory() async {
    try {
      // For Android 10+ (API 29+), use getApplicationDocumentsDirectory
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();

      // Create a subdirectory for tickets within the app's private storage
      final Directory ticketsDir = Directory('${appDocumentsDir.path}/tickets');

      if (!await ticketsDir.exists()) {
        await ticketsDir.create(recursive: true);
      }

      print('📁 Using storage directory: ${ticketsDir.path}');
      return ticketsDir;
    } catch (e) {
      print('Error getting storage directory: $e');
      // Fallback to temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final Directory fallbackDir = Directory('${tempDir.path}/tickets');
      if (!await fallbackDir.exists()) {
        await fallbackDir.create(recursive: true);
      }
      return fallbackDir;
    }
  }

  // Method to save ticket data locally
  // Future<void> saveTicketLocally(Ticket completedTicket) async {
  //   try {
  //     final Directory? directory = await getSdCardDirectory();
  //
  //     if (directory == null) {
  //       print('Could not access storage directory');
  //       return;
  //     }
  //
  //     // Create a tickets directory if it doesn't exist
  //     final ticketsDir = Directory('${directory.path}/tickets');
  //     if (!await ticketsDir.exists()) {
  //       await ticketsDir.create(recursive: true);
  //     }
  //
  //     // Generate a unique filename using timestamp
  //     final timestamp = DateTime.now().millisecondsSinceEpoch;
  //     final file = File('${ticketsDir.path}/ticket_${completedTicket.id}_$timestamp.json');
  //
  //     // Convert ticket to JSON and save using your existing toMap() method
  //     final ticketData = {
  //       'ticket': completedTicket.toMap(),
  //       'savedTimestamp': DateTime.now().millisecondsSinceEpoch,
  //       'totalAmount': completedTicket.totalAmount,
  //     };
  //
  //     final jsonString = jsonEncode(ticketData);
  //
  //     await file.writeAsString(jsonString);
  //     print('Ticket saved successfully at: ${file.path}');
  //   } catch (e) {
  //     print('Error saving ticket locally: $e');
  //   }
  // }

  Future<void> saveTicketLocally(Ticket completedTicket) async {
    try {
      final Directory ticketsDir = await getStorageDirectory();

      // Generate a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'ticket_${completedTicket.id}_$timestamp.json';
      final file = File('${ticketsDir.path}/$filename');

      // Convert ticket to JSON and save
      final ticketData = {
        'ticket': completedTicket.toMap(),
        'savedTimestamp': DateTime.now().millisecondsSinceEpoch,
        'totalAmount': completedTicket.totalAmount,
      };

      final jsonString = jsonEncode(ticketData);
      await file.writeAsString(jsonString);

      print('✅ Ticket saved successfully at: ${file.path}');

      // Verify file was created
      final fileExists = await file.exists();
      print('🔍 File verification: $fileExists');

    } catch (e) {
      print('❌ Error saving ticket locally: $e');
    }
  }

  // Method to read all saved tickets (for verification)
  // Future<void> readSavedTickets() async {
  //   try {
  //     final Directory? directory = await getSdCardDirectory();
  //
  //     if (directory == null) {
  //       print('Could not access storage directory');
  //       return;
  //     }
  //
  //     final ticketsDir = Directory('${directory.path}/tickets');
  //     if (await ticketsDir.exists()) {
  //       final files = ticketsDir.listSync();
  //       print('Found ${files.length} saved tickets:');
  //
  //       for (var file in files) {
  //         if (file is File && file.path.endsWith('.json')) {
  //           try {
  //             final contents = await file.readAsString();
  //             final jsonData = jsonDecode(contents);
  //             print('File: ${file.path}');
  //             print('Ticket ID: ${jsonData['ticket']['id']}');
  //             print('Total Amount: ${jsonData['totalAmount']}');
  //             print('Saved: ${DateTime.fromMillisecondsSinceEpoch(jsonData['savedTimestamp'])}');
  //             print('---');
  //           } catch (e) {
  //             print('Error reading file ${file.path}: $e');
  //           }
  //         }
  //       }
  //     } else {
  //       print('No tickets directory found');
  //     }
  //   } catch (e) {
  //     print('Error reading saved tickets: $e');
  //   }
  // }

  Future<void> readSavedTickets() async {
    try {
      final Directory ticketsDir = await getStorageDirectory();

      if (await ticketsDir.exists()) {
        final files = ticketsDir.listSync();
        print('📂 Found ${files.length} saved tickets in: ${ticketsDir.path}');

        for (var file in files) {
          if (file is File && file.path.endsWith('.json')) {
            try {
              final contents = await file.readAsString();
              final jsonData = jsonDecode(contents);
              print('📄 File: ${file.uri.pathSegments.last}');
              print('   Ticket ID: ${jsonData['ticket']['id']}');
              print('   Total Amount: TK ${jsonData['totalAmount']?.toStringAsFixed(2)}');
              print('   Saved: ${DateTime.fromMillisecondsSinceEpoch(jsonData['savedTimestamp'])}');
              print('   ---');
            } catch (e) {
              print('   Error reading file: $e');
            }
          }
        }
      } else {
        print('❌ No tickets directory found');
      }
    } catch (e) {
      print('❌ Error reading saved tickets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String ticketName = ticket.name;
    return Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(ticketName),
              backgroundColor: Color(0xFF2E7D32),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _buildTotalAmountSection()),

                  const SizedBox(height: 24),

                  // Cash Received Section
                  Center(child: _buildCashReceivedSection()),

                  const SizedBox(height: 24),

                  // Divider
                  const Divider(thickness: 2),

                  const SizedBox(height: 24),

                  _buildPaymentMethodsSection(),

                  const Spacer(),

                  // Action Buttons
                  _buildActionButtons(context),
                  ElevatedButton(
                      onPressed: (){
                        print(ticketProvider.tickets);
                      },
                      child: const Text("Check state of provider")),
                  ElevatedButton(
                      onPressed: (){
                        if(ticketProvider.activeTicket?.totalAmount == null){
                          print("total amount is null");
                        }
                        print(ticketProvider.activeTicket);
                        print(ticketProvider.activeTicket?.totalAmount);
                      },
                      child: const Text("Print Active ticket")),
                  // Add a button to verify saved tickets
                  ElevatedButton(
                      onPressed: () async {
                        await readSavedTickets();
                      },
                      child: const Text("Check Saved Tickets"))
                ],
              ),
            ),
          );
        });
  }

  Widget _buildTotalAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TK ${ticket.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Total amount due',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCashReceivedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cash received',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'TK ${ticket.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
  Widget _buildPaymentMethodsSection() {
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Payment Method Options
            _buildPaymentOption('CASH', ticketProvider),
            _buildPaymentOption('CARD', ticketProvider),
            _buildPaymentOption('BKASH', ticketProvider),
            _buildPaymentOption('NAGAD', ticketProvider),
          ],
        );
      },
    );
  }


  Widget _buildPaymentOption(String method, TicketProvider ticketProvider) {
    final isSelected = ticketProvider.selectedPaymentMethod == method;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          ticketProvider.setPaymentMethod(method);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isSelected ? Colors.blue : const Color(0xFF2E7D32),
              width: isSelected ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getPaymentIcon(method),
                    size: 20,
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    method,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle,
                        size: 16, color: Colors.blue),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'CASH':
        return Icons.money;
      case 'CARD':
        return Icons.credit_card;
      case 'BKASH':
      case 'NAGAD':
        return Icons.mobile_friendly;
      default:
        return Icons.payment;
    }
  }


  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Handle payment completion
              _processPayment(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'COMPLETE PAYMENT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _processPayment(BuildContext context) async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    // Update the ticket with payment method using your existing copyWith method
    final completedTicket = ticket.copyWith(
      paymentMethod: ticketProvider.selectedPaymentMethod,
    );

    // Update the ticket in provider
    ticketProvider.setPaymentMethod(ticketProvider.selectedPaymentMethod);

    // MARK THE TICKET AS COMPLETED - Add this line
    ticketProvider.completeActiveTicket();

    // Save ticket locally
    await saveTicketLocally(completedTicket);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment of TK ${ticket.totalAmount.toStringAsFixed(2)} completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
        return HomeScreen();
      },), (Route<dynamic> route) => false
      );
    });
  }

  // void _processPayment(BuildContext context) async {
  //   final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
  //
  //   // Update the ticket with payment method using your existing copyWith method
  //   final completedTicket = ticket.copyWith(
  //     paymentMethod: ticketProvider.selectedPaymentMethod,
  //   );
  //
  //   // Update the ticket in provider
  //   ticketProvider.setPaymentMethod(ticketProvider.selectedPaymentMethod);
  //
  //   // Save ticket locally
  //   await saveTicketLocally(completedTicket);
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Payment of TK ${ticket.totalAmount.toStringAsFixed(2)} completed successfully!'),
  //       backgroundColor: Colors.green,
  //     ),
  //   );
  //
  //   Future.delayed(const Duration(seconds: 2), () {
  //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
  //       return PrintPage(ticket: completedTicket);
  //     },), (Route<dynamic> route) => false
  //     );
  //   });
  // }
}