import 'package:flutter/material.dart';
import 'package:my_pos/models/customer_model.dart';
import 'package:my_pos/pages/create_customer.dart';

class AddCustomerPage extends StatelessWidget {
  const AddCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Add Customer To Ticket'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final created = await Navigator.push<Customer?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateCustomerPage(),
                      ),
                    );

                    if (created != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text('Added "${created.name}" to this ticket.'),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    side: const BorderSide(color: Color(0xFFE3E6EF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Color(0xFF2E7D32),
                  ),
                  child: const Text(
                    'Add New Customer',
                    style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your most recent customer will show up\nhere',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          // (Space below is intentionally empty to mirror the mock.)
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}